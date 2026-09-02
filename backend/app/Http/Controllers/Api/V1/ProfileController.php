<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\UpdateProfilEtudiantRequest;
use App\Http\Requests\UpdateProfilLyceenRequest;
use App\Http\Resources\UtilisateurResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $utilisateur = $request->user()->load(['profilLyceen', 'profilEtudiant', 'profilAdmin']);

        return response()->json(['utilisateur' => new UtilisateurResource($utilisateur)]);
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
        } else {
            return response()->json(['message' => 'Ce rôle ne possède pas de profil académique éditable.'], 422);
        }

        $utilisateur->load(['profilLyceen', 'profilEtudiant']);

        return response()->json([
            'message' => 'Profil mis à jour.',
            'utilisateur' => new UtilisateurResource($utilisateur),
        ]);
    }
}
