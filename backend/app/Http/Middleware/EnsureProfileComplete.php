<?php

namespace App\Http\Middleware;

use App\Models\Utilisateur;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Garde-fou serveur (voir plan "Séparation inscription / complétion de profil") :
 * bloque l'accès aux fonctionnalités métier tant que l'utilisateur n'a pas
 * choisi son statut et complété son profil via POST /profile/complete. Les
 * comptes admin (jamais soumis à cette étape) passent toujours.
 * Usage : ->middleware('profil.complete') à côté de auth:sanctum.
 */
class EnsureProfileComplete
{
    public function handle(Request $request, Closure $next): Response
    {
        $utilisateur = $request->user();

        if (! $utilisateur) {
            return response()->json(['message' => 'Non authentifié.'], 401);
        }

        if ($utilisateur->aLeRole(Utilisateur::ROLE_ADMIN_ETABLISSEMENT, Utilisateur::ROLE_SUPER_ADMIN)) {
            return $next($request);
        }

        if (! $utilisateur->profil_complete) {
            return response()->json([
                'message' => 'Merci de compléter votre profil avant de continuer.',
                'code' => 'profil_incomplete',
            ], 403);
        }

        return $next($request);
    }
}
