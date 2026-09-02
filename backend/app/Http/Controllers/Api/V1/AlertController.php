<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\AlerteProfilRequest;
use App\Http\Resources\AlerteProfilResource;
use App\Models\AlerteProfil;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Module Alertes personnalisées (CDC §8.3, Analyse des besoins §2.6 / UC15).
 */
class AlertController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $alertes = AlerteProfil::where('utilisateur_id', $request->user()->id)
            ->orderByDesc('created_at')
            ->get();

        return response()->json(['data' => AlerteProfilResource::collection($alertes)]);
    }

    public function store(AlerteProfilRequest $request): JsonResponse
    {
        $alerte = AlerteProfil::create([
            'utilisateur_id' => $request->user()->id,
            'criteres' => $request->input('criteres'),
            'actif' => $request->boolean('actif', true),
        ]);

        return response()->json(['message' => 'Alerte créée.', 'data' => new AlerteProfilResource($alerte)], 201);
    }

    public function update(AlerteProfilRequest $request, AlerteProfil $alerte): JsonResponse
    {
        if ($alerte->utilisateur_id !== $request->user()->id) {
            return response()->json(['message' => 'Accès refusé.'], 403);
        }

        $alerte->update($request->validated());

        return response()->json(['message' => 'Alerte mise à jour.', 'data' => new AlerteProfilResource($alerte)]);
    }

    public function destroy(Request $request, AlerteProfil $alerte): JsonResponse
    {
        if ($alerte->utilisateur_id !== $request->user()->id) {
            return response()->json(['message' => 'Accès refusé.'], 403);
        }

        $alerte->delete();

        return response()->json(['message' => 'Alerte supprimée.']);
    }
}
