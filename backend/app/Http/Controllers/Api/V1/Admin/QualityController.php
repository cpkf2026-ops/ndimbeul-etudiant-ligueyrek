<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\OffreEmploi;
use App\Models\SourceDonnee;
use App\Services\DjangoAiClient;
use Illuminate\Http\JsonResponse;

/**
 * GET /api/v1/admin/quality — tableau de bord qualité (UC14). Combine les métriques
 * IA (relayées de Django) et des métriques métier calculées directement côté Laravel.
 */
class QualityController extends Controller
{
    public function __construct(private readonly DjangoAiClient $django) {}

    public function index(): JsonResponse
    {
        $reponseDjango = $this->django->qualityMetrics();

        return response()->json([
            'metriques_ia' => $reponseDjango->successful() ? $reponseDjango->json() : null,
            'metriques_laravel' => [
                'sources_actives' => SourceDonnee::where('statut', 'actif')->count(),
                'sources_en_erreur' => SourceDonnee::where('statut', 'erreur')->count(),
                'sources_obsoletes' => SourceDonnee::where('statut', 'obsolete')->count(),
                'offres_actives' => OffreEmploi::actives()->count(),
                'offres_expirees' => OffreEmploi::where('statut', 'expiree')->count(),
                'actions_admin_7_derniers_jours' => AuditLog::where('date_action', '>=', now()->subDays(7))->count(),
            ],
        ]);
    }
}
