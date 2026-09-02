<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\UniversiteResource;
use App\Models\Universite;
use App\Models\UniversiteSuivie;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class UniversityController extends Controller
{
    /**
     * GET /api/v1/universities — catalogue public avec filtres (CDC §2.2).
     */
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'region' => ['sometimes', 'string'],
            'type' => ['sometimes', 'in:public,prive'],
            'q' => ['sometimes', 'string', 'max:255'],
            'per_page' => ['sometimes', 'integer', 'min:1', 'max:100'],
        ]);

        $universites = Universite::query()
            ->where('statut_actif', true)
            ->dansRegion($request->query('region'))
            ->deType($request->query('type'))
            ->when($request->query('q'), fn ($q, $terme) => $q->where('nom', 'like', "%{$terme}%"))
            ->orderBy('nom')
            ->paginate($request->integer('per_page', 20));

        return response()->json([
            'data' => UniversiteResource::collection($universites),
            'meta' => [
                'current_page' => $universites->currentPage(),
                'last_page' => $universites->lastPage(),
                'total' => $universites->total(),
            ],
        ]);
    }

    /**
     * GET /api/v1/universities/{id} — fiche complète générée par l'IA (CDC §5.3/§7.3).
     * Les données structurées (formations/bourses/logements/frais) sont servies par Laravel ;
     * si elles sont absentes ou obsolètes, on relaie une demande de régénération à Django.
     */
    public function show(Request $request, Universite $universite): JsonResponse
    {
        $universite->load(['formations', 'bourses', 'logements', 'fraisScolarite']);

        if ($request->user()) {
            $this->enregistrerSuivi($request->user()->id, $universite->id, 'consultee');
        }

        return response()->json(['data' => new UniversiteResource($universite)]);
    }

    /**
     * GET /api/v1/universities/compare?ids=uuid1,uuid2,uuid3 (CDC §7.3 "Comparaison").
     */
    public function compare(Request $request): JsonResponse
    {
        $request->validate(['ids' => ['required', 'string']]);

        $ids = array_filter(array_map('trim', explode(',', $request->query('ids'))));

        if (count($ids) < 2 || count($ids) > 4) {
            return response()->json(['message' => 'Fournir entre 2 et 4 identifiants d\'université à comparer.'], 422);
        }

        $universites = Universite::whereIn('id', $ids)
            ->with(['formations', 'bourses', 'logements', 'fraisScolarite'])
            ->get();

        if ($request->user()) {
            foreach ($universites as $universite) {
                $this->enregistrerSuivi($request->user()->id, $universite->id, 'comparee');
            }
        }

        return response()->json(['data' => UniversiteResource::collection($universites)]);
    }

    /**
     * POST /api/v1/universities/{id}/track — marque une université comme suggérée/consultée/comparée
     * dans l'historique de l'espace étudiant (CDC §7.4, historique absent du schéma Conception, réintégré).
     */
    public function track(Request $request, Universite $universite): JsonResponse
    {
        $request->validate(['statut' => [Rule::in(['suggeree', 'consultee', 'comparee'])]]);

        $suivi = $this->enregistrerSuivi(
            $request->user()->id,
            $universite->id,
            $request->input('statut', 'consultee')
        );

        return response()->json(['message' => 'Suivi enregistré.', 'data' => $suivi], 201);
    }

    /**
     * GET /api/v1/universities/history — historique complet de l'étudiant connecté.
     */
    public function history(Request $request): JsonResponse
    {
        $historique = UniversiteSuivie::where('utilisateur_id', $request->user()->id)
            ->with('universite')
            ->orderByDesc('date_ajout')
            ->get();

        return response()->json(['data' => $historique]);
    }

    private function enregistrerSuivi(string $utilisateurId, string $universiteId, string $statut): UniversiteSuivie
    {
        return UniversiteSuivie::create([
            'utilisateur_id' => $utilisateurId,
            'universite_id' => $universiteId,
            'statut' => $statut,
            'date_ajout' => now(),
        ]);
    }
}
