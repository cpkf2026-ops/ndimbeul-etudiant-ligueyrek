<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\ActualiteResource;
use App\Models\Actualite;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NewsController extends Controller
{
    /**
     * GET /api/v1/news — fil filtré par profil (CDC §2.7).
     */
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'categorie' => ['sometimes', 'in:bourse,concours,evenement,formation,general'],
            'per_page' => ['sometimes', 'integer', 'min:1', 'max:100'],
        ]);

        $role = $request->user()?->role;

        $actualites = Actualite::query()
            ->publiees()
            ->when($request->query('categorie'), fn ($q, $c) => $q->where('categorie', $c))
            ->when($role, fn ($q) => $q->where(function ($q2) use ($role) {
                $q2->whereNull('cible_roles')->orWhereJsonContains('cible_roles', $role);
            }))
            ->orderByDesc('date_publication')
            ->paginate($request->integer('per_page', 20));

        return response()->json([
            'data' => ActualiteResource::collection($actualites),
            'meta' => [
                'current_page' => $actualites->currentPage(),
                'last_page' => $actualites->lastPage(),
                'total' => $actualites->total(),
            ],
        ]);
    }

    public function show(Actualite $actualite): JsonResponse
    {
        return response()->json(['data' => new ActualiteResource($actualite)]);
    }
}
