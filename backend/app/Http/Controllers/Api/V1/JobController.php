<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\OffreEmploiResource;
use App\Models\OffreEmploi;
use App\Models\OffreFavorite;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class JobController extends Controller
{
    /**
     * GET /api/v1/jobs — fil d'offres avec filtres (CDC §8.3).
     */
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'domaine' => ['sometimes', 'string'],
            'region' => ['sometimes', 'string'],
            'type' => ['sometimes', 'in:emploi,stage,alternance,formation,bourse,concours'],
            'niveau_requis' => ['sometimes', 'string'],
            'date_limite_avant' => ['sometimes', 'date'],
            'per_page' => ['sometimes', 'integer', 'min:1', 'max:100'],
        ]);

        $offres = OffreEmploi::query()
            ->actives()
            ->dansDomaine($request->query('domaine'))
            ->dansRegion($request->query('region'))
            ->deType($request->query('type'))
            ->when($request->query('niveau_requis'), fn ($q, $n) => $q->where('niveau_requis', $n))
            ->when($request->query('date_limite_avant'), fn ($q, $d) => $q->where('date_limite', '<=', $d))
            // Plus récentes d'abord. Les offres trouvées par la veille Tavily sur les sites
            // d'emploi n'ont pas toujours de date de publication : on prend alors leur date
            // de collecte, sinon MySQL les rangerait tout en bas (NULL en dernier).
            ->orderByRaw('COALESCE(date_publication, DATE(date_collecte), DATE(date_indexation)) DESC')
            ->orderByDesc('date_indexation')
            ->paginate($request->integer('per_page', 20));

        return response()->json([
            'data' => OffreEmploiResource::collection($offres),
            'meta' => [
                'current_page' => $offres->currentPage(),
                'last_page' => $offres->lastPage(),
                'total' => $offres->total(),
            ],
        ]);
    }

    public function show(Request $request, OffreEmploi $job): JsonResponse
    {
        return response()->json(['data' => new OffreEmploiResource($job)]);
    }

    /**
     * GET /api/v1/jobs/favorites — offres sauvegardées par l'étudiant connecté
     * (CDC §2.8, même manque que pour les formations : aucun endpoint de lecture n'existait).
     */
    public function favorites(Request $request): JsonResponse
    {
        $offres = OffreEmploi::query()
            ->whereHas('favoris', fn ($q) => $q->where('utilisateur_id', $request->user()->id))
            ->get();

        return response()->json(['data' => OffreEmploiResource::collection($offres)]);
    }

    public function favorite(Request $request, OffreEmploi $job): JsonResponse
    {
        $favori = OffreFavorite::firstOrCreate(
            ['utilisateur_id' => $request->user()->id, 'offre_id' => $job->id],
            ['date_sauvegarde' => now()]
        );

        return response()->json(['message' => 'Offre sauvegardée.', 'data' => $favori], 201);
    }

    public function unfavorite(Request $request, OffreEmploi $job): JsonResponse
    {
        OffreFavorite::where('utilisateur_id', $request->user()->id)
            ->where('offre_id', $job->id)
            ->delete();

        return response()->json(['message' => 'Offre retirée des favoris.']);
    }
}
