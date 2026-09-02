<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreBourseRequest;
use App\Http\Requests\Admin\StoreFraisScolariteRequest;
use App\Http\Requests\Admin\StoreLogementRequest;
use App\Http\Resources\BourseResource;
use App\Http\Resources\FraisScolariteResource;
use App\Http\Resources\LogementResource;
use App\Models\Bourse;
use App\Models\FraisScolarite;
use App\Models\Logement;
use App\Models\Universite;
use App\Services\AuditLogger;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Gestion des 3 volets structurés de la fiche université (CDC §5.3/§7.3) :
 * bourses, logements, frais de scolarité. CRUD réservé aux admins (établissement ou super).
 * Ces mêmes tables sont aussi alimentées automatiquement par la veille IA (Membre 4) —
 * la saisie manuelle sert de complément/correction, avec traçabilité via `source`/`date_maj`.
 */
class FicheAdminController extends Controller
{
    public function __construct(private readonly AuditLogger $auditLogger) {}

    // --- Bourses ---

    public function storeBourse(StoreBourseRequest $request, Universite $universite): JsonResponse
    {
        $bourse = $universite->bourses()->create($request->validated() + [
            'source' => $request->input('source', 'saisie_manuelle_admin'),
            'date_maj' => now(),
        ]);

        $this->auditLogger->log($request->user(), 'create', 'bourses', $bourse->id, null, $bourse->toArray());

        return response()->json(['message' => 'Bourse ajoutée.', 'data' => new BourseResource($bourse)], 201);
    }

    public function updateBourse(StoreBourseRequest $request, Bourse $bourse): JsonResponse
    {
        $avant = $bourse->toArray();
        $bourse->update($request->validated() + ['date_maj' => now()]);

        $this->auditLogger->log($request->user(), 'update', 'bourses', $bourse->id, $avant, $bourse->toArray());

        return response()->json(['message' => 'Bourse mise à jour.', 'data' => new BourseResource($bourse)]);
    }

    public function destroyBourse(Request $request, Bourse $bourse): JsonResponse
    {
        $avant = $bourse->toArray();
        $bourse->delete();

        $this->auditLogger->log($request->user(), 'delete', 'bourses', $bourse->id, $avant, null);

        return response()->json(['message' => 'Bourse supprimée.']);
    }

    // --- Logements ---

    public function storeLogement(StoreLogementRequest $request, Universite $universite): JsonResponse
    {
        $logement = $universite->logements()->create($request->validated() + [
            'source' => $request->input('source', 'saisie_manuelle_admin'),
            'date_maj' => now(),
        ]);

        $this->auditLogger->log($request->user(), 'create', 'logements', $logement->id, null, $logement->toArray());

        return response()->json(['message' => 'Logement ajouté.', 'data' => new LogementResource($logement)], 201);
    }

    public function updateLogement(StoreLogementRequest $request, Logement $logement): JsonResponse
    {
        $avant = $logement->toArray();
        $logement->update($request->validated() + ['date_maj' => now()]);

        $this->auditLogger->log($request->user(), 'update', 'logements', $logement->id, $avant, $logement->toArray());

        return response()->json(['message' => 'Logement mis à jour.', 'data' => new LogementResource($logement)]);
    }

    public function destroyLogement(Request $request, Logement $logement): JsonResponse
    {
        $avant = $logement->toArray();
        $logement->delete();

        $this->auditLogger->log($request->user(), 'delete', 'logements', $logement->id, $avant, null);

        return response()->json(['message' => 'Logement supprimé.']);
    }

    // --- Frais de scolarité ---

    public function storeFrais(StoreFraisScolariteRequest $request, Universite $universite): JsonResponse
    {
        $frais = $universite->fraisScolarite()->create($request->validated() + [
            'source' => $request->input('source', 'saisie_manuelle_admin'),
            'date_maj' => now(),
        ]);

        $this->auditLogger->log($request->user(), 'create', 'frais_scolarite', $frais->id, null, $frais->toArray());

        return response()->json(['message' => 'Frais de scolarité ajoutés.', 'data' => new FraisScolariteResource($frais)], 201);
    }

    public function updateFrais(StoreFraisScolariteRequest $request, FraisScolarite $fraisScolarite): JsonResponse
    {
        $avant = $fraisScolarite->toArray();
        $fraisScolarite->update($request->validated() + ['date_maj' => now()]);

        $this->auditLogger->log($request->user(), 'update', 'frais_scolarite', $fraisScolarite->id, $avant, $fraisScolarite->toArray());

        return response()->json(['message' => 'Frais mis à jour.', 'data' => new FraisScolariteResource($fraisScolarite)]);
    }

    public function destroyFrais(Request $request, FraisScolarite $fraisScolarite): JsonResponse
    {
        $avant = $fraisScolarite->toArray();
        $fraisScolarite->delete();

        $this->auditLogger->log($request->user(), 'delete', 'frais_scolarite', $fraisScolarite->id, $avant, null);

        return response()->json(['message' => 'Frais supprimés.']);
    }
}
