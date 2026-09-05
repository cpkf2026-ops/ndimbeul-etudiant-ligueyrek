<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\CompleteProfileRequest;
use App\Http\Requests\UpdateProfilDiplomeRequest;
use App\Http\Requests\UpdateProfilEtudiantRequest;
use App\Http\Requests\UpdateProfilLyceenRequest;
use App\Http\Resources\UtilisateurResource;
use App\Models\Utilisateur;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $utilisateur = $request->user()->load(['profilLyceen', 'profilEtudiant', 'profilDiplome', 'profilAdmin']);

        return response()->json(['utilisateur' => new UtilisateurResource($utilisateur)]);
    }

    /**
     * POST /api/v1/profile/complete — étape obligatoire après l'inscription
     * (voir EnsureProfileComplete) : fixe le `role` de l'utilisateur d'après
     * le statut choisi, crée le profil spécialisé correspondant, et passe
     * `profil_complete` à true. Volontairement en dehors du garde-fou
     * `profil.complete` puisque c'est justement la route qui le satisfait.
     */
    public function complete(CompleteProfileRequest $request): JsonResponse
    {
        $utilisateur = $request->user();
        $data = $request->validated();

        match ($data['statut']) {
            Utilisateur::ROLE_LYCEEN => $utilisateur->profilLyceen()->updateOrCreate(
                ['utilisateur_id' => $utilisateur->id],
                collect($data)->only(['serie_bac', 'niveau', 'etablissement', 'annee_terminale'])->toArray(),
            ),
            Utilisateur::ROLE_ETUDIANT => $utilisateur->profilEtudiant()->updateOrCreate(
                ['utilisateur_id' => $utilisateur->id],
                collect($data)->only(['universite_actuelle', 'formation_actuelle', 'niveau_actuel'])->toArray(),
            ),
            Utilisateur::ROLE_DIPLOME => $utilisateur->profilDiplome()->updateOrCreate(
                ['utilisateur_id' => $utilisateur->id],
                collect($data)->only(['dernier_diplome', 'domaine', 'situation_actuelle', 'entreprise'])->toArray(),
            ),
        };

        $utilisateur->forceFill([
            'role' => $data['statut'],
            'profil_complete' => true,
        ])->save();

        $utilisateur->load(['profilLyceen', 'profilEtudiant', 'profilDiplome']);

        return response()->json([
            'message' => 'Profil complété.',
            'utilisateur' => new UtilisateurResource($utilisateur),
        ]);
    }

    /**
     * PUT /api/v1/profile/me — route unique quel que soit le rôle,
     * on aiguille vers le bon Form Request selon le profil de l'utilisateur connecté.
     */
    public function update(Request $request): JsonResponse
    {
        $utilisateur = $request->user();

        if ($utilisateur->estLyceen()) {
            $validated = app(UpdateProfilLyceenRequest::class)->validated();
            $utilisateur->profilLyceen()->updateOrCreate(['utilisateur_id' => $utilisateur->id], $validated);
        } elseif ($utilisateur->estEtudiant()) {
            $validated = app(UpdateProfilEtudiantRequest::class)->validated();
            $utilisateur->profilEtudiant()->updateOrCreate(['utilisateur_id' => $utilisateur->id], $validated);
        } elseif ($utilisateur->estDiplome()) {
            $validated = app(UpdateProfilDiplomeRequest::class)->validated();
            $utilisateur->profilDiplome()->updateOrCreate(['utilisateur_id' => $utilisateur->id], $validated);
        } else {
            return response()->json(['message' => 'Ce rôle ne possède pas de profil académique éditable.'], 422);
        }

        $utilisateur->load(['profilLyceen', 'profilEtudiant', 'profilDiplome']);

        return response()->json([
            'message' => 'Profil mis à jour.',
            'utilisateur' => new UtilisateurResource($utilisateur),
        ]);
    }
}
