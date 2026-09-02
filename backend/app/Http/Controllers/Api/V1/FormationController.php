<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\FormationResource;
use App\Models\Formation;
use App\Models\FormationFavorite;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FormationController extends Controller
{
    /**
     * GET /api/v1/formations — recherche multicritères (CDC §2.2, §7.2).
     */
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'domaine' => ['sometimes', 'string'],
            'niveau' => ['sometimes', 'in:bts,licence,master,doctorat'],
            'region' => ['sometimes', 'string'],
            'type_etablissement' => ['sometimes', 'in:public,prive'],
            'serie_bac' => ['sometimes', 'string'],
            'universite_id' => ['sometimes', 'uuid'],
            'per_page' => ['sometimes', 'integer', 'min:1', 'max:100'],
        ]);

        $formations = Formation::query()
            ->with('universite')
            ->dansDomaine($request->query('domaine'))
            ->deNiveau($request->query('niveau'))
            ->when($request->query('universite_id'), fn ($q, $id) => $q->where('universite_id', $id))
            ->when($request->query('region'), fn ($q, $region) => $q->whereHas('universite', fn ($u) => $u->where('region', $region)))
            ->when($request->query('type_etablissement'), fn ($q, $type) => $q->whereHas('universite', fn ($u) => $u->where('type', $type)))
            ->when($request->query('serie_bac'), function ($q, $serie) {
                $q->where(function ($q2) use ($serie) {
                    $q2->whereJsonContains('series_acceptees', $serie)
                        ->orWhereNull('series_acceptees');
                });
            })
            ->orderBy('intitule')
            ->paginate($request->integer('per_page', 20));

        return response()->json([
            'data' => FormationResource::collection($formations),
            'meta' => [
                'current_page' => $formations->currentPage(),
                'last_page' => $formations->lastPage(),
                'total' => $formations->total(),
            ],
        ]);
    }

    public function show(Request $request, Formation $formation): JsonResponse
    {
        $formation->load(['universite', 'fraisScolarite']);

        return response()->json(['data' => new FormationResource($formation)]);
    }

    /**
     * GET /api/v1/formations/compare?ids=uuid1,uuid2 (CDC UC07, symétrique de
     * UniversityController::compare — comparaison au niveau formation, pas seulement université).
     */
    public function compare(Request $request): JsonResponse
    {
        $request->validate(['ids' => ['required', 'string']]);

        $ids = array_filter(array_map('trim', explode(',', $request->query('ids'))));

        if (count($ids) < 2 || count($ids) > 4) {
            return response()->json(['message' => 'Fournir entre 2 et 4 identifiants de formation à comparer.'], 422);
        }

        $formations = Formation::whereIn('id', $ids)
            ->with(['universite', 'fraisScolarite'])
            ->get();

        return response()->json(['data' => FormationResource::collection($formations)]);
    }

    /**
     * GET /api/v1/formations/favorites — liste des formations sauvegardées par l'étudiant
     * connecté (CDC §2.8 "Opportunités suivies", manquant dans la première livraison :
     * seuls les endpoints POST/DELETE existaient, sans moyen de relire la liste).
     */
    public function favorites(Request $request): JsonResponse
    {
        $formations = Formation::query()
            ->whereHas('favorisPar', fn ($q) => $q->where('utilisateur_id', $request->user()->id))
            ->with('universite')
            ->get();

        return response()->json(['data' => FormationResource::collection($formations)]);
    }

    public function favorite(Request $request, Formation $formation): JsonResponse
    {
        $favori = FormationFavorite::firstOrCreate(
            ['utilisateur_id' => $request->user()->id, 'formation_id' => $formation->id],
            ['date_sauvegarde' => now(), 'notes_perso' => $request->input('notes_perso')]
        );

        return response()->json(['message' => 'Formation ajoutée aux favoris.', 'data' => $favori], 201);
    }

    public function unfavorite(Request $request, Formation $formation): JsonResponse
    {
        FormationFavorite::where('utilisateur_id', $request->user()->id)
            ->where('formation_id', $formation->id)
            ->delete();

        return response()->json(['message' => 'Formation retirée des favoris.']);
    }
}
