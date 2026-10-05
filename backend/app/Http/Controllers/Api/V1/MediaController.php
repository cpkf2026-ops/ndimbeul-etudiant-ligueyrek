<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Storage;

class MediaController extends Controller
{
    /**
     * Sert les fichiers de storage/app/public (logos d'établissements, images
     * d'actualités téléchargées par la veille IA) avec un en-tête CORS explicite.
     *
     * Nécessaire car le serveur de développement PHP sert /storage/... comme un
     * fichier statique brut, sans jamais passer par le middleware CORS de Laravel :
     * le renderer web de Flutter (CanvasKit) refuse alors de décoder ces images en
     * l'absence d'Access-Control-Allow-Origin, et retombe silencieusement sur un
     * repli coloré. Seuls logos/ et actualites/ sont exposés (jamais de traversée
     * de chemin arbitraire).
     */
    public function show(Request $request, string $path): Response
    {
        if (str_contains($path, '..') || !preg_match('#^(logos|actualites)/[a-zA-Z0-9._-]+$#', $path)) {
            abort(404);
        }

        if (!Storage::disk('public')->exists($path)) {
            abort(404);
        }

        $contenu = Storage::disk('public')->get($path);
        $type = Storage::disk('public')->mimeType($path) ?: 'application/octet-stream';

        return response($contenu, 200, [
            'Content-Type' => $type,
            'Access-Control-Allow-Origin' => '*',
            'Cache-Control' => 'public, max-age=86400',
        ]);
    }
}
