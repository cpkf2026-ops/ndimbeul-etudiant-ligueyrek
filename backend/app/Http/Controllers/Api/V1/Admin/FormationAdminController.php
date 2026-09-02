<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreFormationRequest;
use App\Http\Requests\Admin\UpdateFormationRequest;
use App\Http\Resources\FormationResource;
use App\Models\Formation;
use App\Models\Universite;
use App\Services\AuditLogger;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FormationAdminController extends Controller
{
    public function __construct(private readonly AuditLogger $auditLogger) {}

    public function store(StoreFormationRequest $request, Universite $universite): JsonResponse
    {
        $formation = $universite->formations()->create($request->validated());

        $this->auditLogger->log($request->user(), 'create', 'formations', $formation->id, null, $formation->toArray());

        return response()->json(['message' => 'Formation créée.', 'data' => new FormationResource($formation)], 201);
    }

    public function update(UpdateFormationRequest $request, Formation $formation): JsonResponse
    {
        $avant = $formation->toArray();
        $formation->update($request->validated());

        $this->auditLogger->log($request->user(), 'update', 'formations', $formation->id, $avant, $formation->toArray());

        return response()->json(['message' => 'Formation mise à jour.', 'data' => new FormationResource($formation)]);
    }

    public function destroy(Request $request, Formation $formation): JsonResponse
    {
        $this->authorize('delete', $formation);

        $avant = $formation->toArray();
        $formation->delete();

        $this->auditLogger->log($request->user(), 'delete', 'formations', $formation->id, $avant, null);

        return response()->json(['message' => 'Formation supprimée.']);
    }
}
