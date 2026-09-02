<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Middleware RBAC. Usage dans les routes : ->middleware('role:super_admin,admin_etablissement')
 * Complète les Policies (qui gèrent l'autorisation fine par ressource) par un filtre
 * grossier au niveau route, conformément au CDC §3.3 "RBAC appliqué sur toutes les routes API".
 */
class EnsureRole
{
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $utilisateur = $request->user();

        if (! $utilisateur) {
            return response()->json(['message' => 'Non authentifié.'], 401);
        }

        if (! $utilisateur->estActif()) {
            return response()->json(['message' => 'Compte suspendu.'], 403);
        }

        if (! $utilisateur->aLeRole(...$roles)) {
            return response()->json(['message' => 'Accès refusé : rôle insuffisant.'], 403);
        }

        return $next($request);
    }
}
