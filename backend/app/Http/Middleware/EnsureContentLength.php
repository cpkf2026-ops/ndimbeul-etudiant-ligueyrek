<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\StreamedResponse;

/**
 * Force l'en-tête Content-Length sur les réponses non streamées.
 *
 * Le serveur de développement intégré de PHP (`php artisan serve`) ne l'ajoute jamais
 * lui-même (vérifié : même un script PHP trivial servi par `php -S` en est dépourvu),
 * se contentant de fermer la connexion pour signaler la fin du corps. C'est valide au
 * sens strict de HTTP/1.1, mais le fetch() d'Edge/Chrome le rejette silencieusement
 * (DioException/OperationError côté Flutter Web, sans détail exploitable). Les réponses
 * SSE (StreamedResponse, /ai/chat) sont exclues : leur longueur n'est pas connue à l'avance.
 */
class EnsureContentLength
{
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        if (! $response instanceof StreamedResponse && ! $response->headers->has('Content-Length')) {
            $response->headers->set('Content-Length', (string) strlen($response->getContent()));
        }

        return $response;
    }
}
