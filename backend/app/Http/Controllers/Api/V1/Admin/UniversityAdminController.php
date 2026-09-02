<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreUniversiteRequest;
use App\Http\Requests\Admin\UpdateUniversiteRequest;
use App\Http\Resources\UniversiteResource;
use App\Models\Universite;
use App\Services\AuditLogger;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * CRUD universités réservé au back-office (CDC §2.2 "Gestion CRUD des formations
 * par les administrateurs d'établissement" — étendu ici à l'université elle-même).
 * Un admin_etablissement ne voit/modifie que SON établissement ; super_admin voit tout.
 */
class UniversityAdminController extends Controller
{
    public function __construct(private readonly AuditLogger $auditLogger) {}

    public function index(Request $request): JsonResponse
    {
        $utilisateur = $request->user();

        $query = Universite::query();

        if ($utilisateur->estAdminEtablissement()) {
            $query->where('id', $utilisateur->profilAdmin?->universite_id);
        }

        return response()->json(['data' => UniversiteResource::collection($query->paginate(20))]);
    }

    public function store(StoreUniversiteRequest $request): JsonResponse
    {
        $universite = Universite::create($request->validated());

        $this->auditLogger->log($request->user(), 'create', 'universites', $universite->id, null, $universite->toArray());

        return response()->json(['message' => 'Université créée.', 'data' => new UniversiteResource($universite)], 201);
    }

    public function update(UpdateUniversiteRequest $request, Universite $universite): JsonResponse
    {
        $avant = $universite->toArray();
        $universite->update($request->validated());

        $this->auditLogger->log($request->user(), 'update', 'universites', $universite->id, $avant, $universite->toArray());

        return response()->json(['message' => 'Université mise à jour.', 'data' => new UniversiteResource($universite)]);
    }

    public function destroy(Request $request, Universite $universite): JsonResponse
    {
        $this->authorize('delete', $universite);

        $avant = $universite->toArray();
        $universite->delete();

        $this->auditLogger->log($request->user(), 'delete', 'universites', $universite->id, $avant, null);

        return response()->json(['message' => 'Université supprimée.']);
    }
}
