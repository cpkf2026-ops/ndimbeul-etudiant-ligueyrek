<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreSourceDonneeRequest;
use App\Http\Resources\SourceDonneeResource;
use App\Models\SourceDonnee;
use App\Services\AuditLogger;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * GET/POST/PUT/DELETE /api/v1/admin/sources — gestion des sources de la veille IA (UC12).
 */
class SourceController extends Controller
{
    public function __construct(private readonly AuditLogger $auditLogger) {}

    public function index(Request $request): JsonResponse
    {
        $this->authorize('viewAny', SourceDonnee::class);

        $utilisateur = $request->user();
        $query = SourceDonnee::query()->with('universite');

        if ($utilisateur->estAdminEtablissement()) {
            $query->where('universite_id', $utilisateur->profilAdmin?->universite_id);
        }

        return response()->json(['data' => SourceDonneeResource::collection($query->paginate(20))]);
    }

    public function store(StoreSourceDonneeRequest $request): JsonResponse
    {
        $source = SourceDonnee::create($request->validated() + [
            'admin_id' => $request->user()->id,
            'statut' => 'actif',
        ]);

        $this->auditLogger->log($request->user(), 'create', 'sources_donnees', $source->id, null, $source->toArray());

        return response()->json(['message' => 'Source ajoutée.', 'data' => new SourceDonneeResource($source)], 201);
    }

    public function update(StoreSourceDonneeRequest $request, SourceDonnee $source): JsonResponse
    {
        $this->authorize('update', $source);

        $avant = $source->toArray();
        $source->update($request->validated());

        $this->auditLogger->log($request->user(), 'update', 'sources_donnees', $source->id, $avant, $source->toArray());

        return response()->json(['message' => 'Source mise à jour.', 'data' => new SourceDonneeResource($source)]);
    }

    public function destroy(Request $request, SourceDonnee $source): JsonResponse
    {
        $this->authorize('delete', $source);

        $avant = $source->toArray();
        $source->delete();

        $this->auditLogger->log($request->user(), 'delete', 'sources_donnees', $source->id, $avant, null);

        return response()->json(['message' => 'Source supprimée.']);
    }
}
