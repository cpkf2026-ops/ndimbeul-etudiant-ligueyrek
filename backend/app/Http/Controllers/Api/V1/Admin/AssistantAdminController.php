<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Services\AuditLogger;
use App\Services\DjangoAiClient;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\Client\Response;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

/**
 * Ajout assisté par l'IA dans le back-office (établissements, actualités, offres).
 *
 * Déroulé en 3 temps, toujours avec relecture humaine :
 *   1. l'administrateur tape un nom (établissement) ou colle un lien (actualité / offre) ;
 *   2. le service IA va chercher les informations publiques et renvoie une PROPOSITION
 *      (rien n'est enregistré à cette étape) ;
 *   3. l'administrateur corrige si besoin puis publie : l'enregistrement est fait par le
 *      service IA avec le même code que la veille automatique (anti-doublon, image locale,
 *      source), donc le contenu s'affiche exactement comme ceux trouvés par l'IA.
 */
class AssistantAdminController extends Controller
{
    public function __construct(
        private readonly DjangoAiClient $django,
        private readonly AuditLogger $auditLogger,
    ) {}

    /** POST /api/v1/admin/universities/recherche {nom} */
    public function rechercherEtablissement(Request $request): JsonResponse
    {
        $donnees = $request->validate(['nom' => ['required', 'string', 'min:3', 'max:255']]);

        return $this->relayer(fn () => $this->django->rechercherEtablissement($donnees['nom']));
    }

    /** POST /api/v1/admin/contenus/analyser {url, genre: actualite|offre} */
    public function analyserLien(Request $request): JsonResponse
    {
        $donnees = $request->validate([
            'url' => ['required', 'url', 'max:500'],
            'genre' => ['required', 'in:actualite,offre'],
        ]);

        return $this->relayer(fn () => $this->django->analyserLien($donnees['url'], $donnees['genre']));
    }

    /** POST /api/v1/admin/universities | /admin/news | /admin/jobs (publication relue). */
    public function publierEtablissement(Request $request): JsonResponse
    {
        $donnees = $request->validate([
            'nom' => ['required', 'string', 'max:255'],
            'type' => ['nullable', 'in:public,prive'],
            'region' => ['nullable', 'string', 'max:100'],
            'commune' => ['nullable', 'string', 'max:100'],
            'adresse' => ['nullable', 'string', 'max:255'],
            'site_web_officiel' => ['nullable', 'url', 'max:255'],
            'description' => ['nullable', 'string', 'max:3000'],
            'image' => ['nullable', 'url', 'max:1000'],
            'sources' => ['nullable', 'array'],
            'sources.*' => ['string', 'max:1000'],
        ]);

        return $this->publier($request, 'etablissement', 'universites', $donnees);
    }

    public function publierActualite(Request $request): JsonResponse
    {
        $donnees = $request->validate([
            'titre' => ['required', 'string', 'max:255'],
            'resume' => ['required', 'string', 'max:3000'],
            'categorie' => ['required', 'in:bourse,concours,evenement,formation,general'],
            'source_url' => ['nullable', 'url', 'max:255'],
            'image' => ['nullable', 'url', 'max:1000'],
            'date_publication' => ['nullable', 'string', 'max:40'],
        ]);

        return $this->publier($request, 'actualite', 'actualites', $donnees);
    }

    public function publierOffre(Request $request): JsonResponse
    {
        $donnees = $request->validate([
            'titre' => ['required', 'string', 'max:255'],
            'source_url' => ['required', 'url', 'max:255'],
            'type' => ['required', 'in:emploi,stage,alternance,formation,bourse,concours'],
            'entreprise' => ['nullable', 'string', 'max:255'],
            'region' => ['nullable', 'string', 'max:100'],
            'resume' => ['nullable', 'string', 'max:3000'],
            'date_limite' => ['nullable', 'date'],
            'date_publication' => ['nullable', 'string', 'max:40'],
        ]);

        return $this->publier($request, 'offre', 'offres_emploi', $donnees);
    }

    private function publier(Request $request, string $genre, string $table, array $donnees): JsonResponse
    {
        $reponse = $this->relayer(fn () => $this->django->publier($genre, $donnees));
        if ($reponse->getStatusCode() === 201) {
            $cree = $reponse->getData(true);
            $this->auditLogger->log($request->user(), 'create', $table, $cree['id'] ?? null, null, $donnees);
            Cache::forget('veille_etat');
        }

        return $reponse;
    }

    /** Relaie la réponse du service IA ; message clair si le service est arrêté. */
    private function relayer(callable $appel): JsonResponse
    {
        try {
            /** @var Response $reponse */
            $reponse = $appel();
        } catch (ConnectionException) {
            return response()->json(['message' => "Le service IA ne répond pas. Vérifiez qu'il est démarré."], 503);
        }

        $corps = $reponse->json() ?? [];
        if ($reponse->failed()) {
            $message = $corps['erreur'] ?? collect($corps)->flatten()->first() ?? 'Erreur du service IA.';

            return response()->json(['message' => $message, 'details' => $corps], $reponse->status());
        }

        return response()->json($corps, $reponse->status());
    }
}
