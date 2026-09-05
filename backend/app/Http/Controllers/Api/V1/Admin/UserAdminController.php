<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\UpdateUserRoleRequest;
use App\Http\Resources\UtilisateurResource;
use App\Models\Utilisateur;
use App\Services\AuditLogger;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * UC14 "Gérer les utilisateurs" — réservé au super_admin (routes protégées par
 * middleware role:super_admin, voir routes/api.php).
 */
class UserAdminController extends Controller
{
    public function __construct(private readonly AuditLogger $auditLogger) {}

    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'role' => ['sometimes', 'in:lyceen,etudiant,diplome,admin_etablissement,super_admin'],
            'statut' => ['sometimes', 'in:actif,suspendu'],
            'per_page' => ['sometimes', 'integer', 'min:1', 'max:100'],
        ]);

        $utilisateurs = Utilisateur::query()
            ->when($request->query('role'), fn ($q, $r) => $q->where('role', $r))
            ->when($request->query('statut'), fn ($q, $s) => $q->where('statut', $s))
            ->orderByDesc('created_at')
            ->paginate($request->integer('per_page', 20));

        return response()->json(['data' => UtilisateurResource::collection($utilisateurs)]);
    }

    public function updateRole(UpdateUserRoleRequest $request, Utilisateur $utilisateur): JsonResponse
    {
        $ancienRole = $utilisateur->role;
        $utilisateur->update(['role' => $request->input('role')]);

        $this->auditLogger->changementRole($request->user(), $utilisateur, $ancienRole, $utilisateur->role);

        return response()->json(['message' => 'Rôle mis à jour.', 'data' => new UtilisateurResource($utilisateur)]);
    }

    public function suspend(Request $request, Utilisateur $utilisateur): JsonResponse
    {
        $this->authorize('suspend', $utilisateur);

        $utilisateur->update(['statut' => 'suspendu']);
        $utilisateur->tokens()->delete(); // révoque toutes les sessions actives

        $this->auditLogger->log($request->user(), 'update', 'utilisateurs', $utilisateur->id, ['statut' => 'actif'], ['statut' => 'suspendu']);

        return response()->json(['message' => 'Utilisateur suspendu.']);
    }

    public function reactivate(Request $request, Utilisateur $utilisateur): JsonResponse
    {
        $this->authorize('update', $utilisateur);

        $utilisateur->update(['statut' => 'actif']);

        $this->auditLogger->log($request->user(), 'update', 'utilisateurs', $utilisateur->id, ['statut' => 'suspendu'], ['statut' => 'actif']);

        return response()->json(['message' => 'Utilisateur réactivé.']);
    }

    /**
     * Suppression logique (soft delete, `Utilisateur` utilise déjà
     * `SoftDeletes`) — préserve l'intégrité des favoris/conversations liés.
     */
    public function destroy(Request $request, Utilisateur $utilisateur): JsonResponse
    {
        $this->authorize('delete', $utilisateur);

        $utilisateur->tokens()->delete();
        $utilisateur->delete();

        $this->auditLogger->log($request->user(), 'delete', 'utilisateurs', $utilisateur->id, ['statut' => $utilisateur->statut], null);

        return response()->json(['message' => 'Utilisateur supprimé.']);
    }
}
