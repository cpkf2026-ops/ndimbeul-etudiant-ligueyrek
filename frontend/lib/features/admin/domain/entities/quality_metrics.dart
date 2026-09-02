import 'package:freezed_annotation/freezed_annotation.dart';

part 'quality_metrics.freezed.dart';

/// Métriques métier calculées côté Laravel (`QualityController::index`) —
/// champs connus avec exactitude depuis le contrôleur, gardés nullable par
/// défensivité (ex. table vide, comptage indisponible).
@freezed
sealed class QualityMetricsLaravel with _$QualityMetricsLaravel {
  const factory QualityMetricsLaravel({
    int? sourcesActives,
    int? sourcesEnErreur,
    int? sourcesObsoletes,
    int? offresActives,
    int? offresExpirees,
    int? actionsAdmin7DerniersJours,
  }) = _QualityMetricsLaravel;

  const QualityMetricsLaravel._();
}

/// Tableau de bord qualité (UC14, `GET /admin/quality`, super_admin
/// uniquement) — combine les métriques métier Laravel (typées ci-dessus) et
/// les métriques IA relayées telles quelles depuis Django
/// (`/internal/quality-metrics`, forme non garantie côté contrat Laravel :
/// [metriquesIa] reste une map brute défensive, `null` si Django est
/// indisponible — voir `metriques_ia => $reponseDjango->successful() ? ... : null`).
@freezed
sealed class QualityMetrics with _$QualityMetrics {
  const factory QualityMetrics({
    Map<String, dynamic>? metriquesIa,
    QualityMetricsLaravel? metriquesLaravel,
  }) = _QualityMetrics;

  const QualityMetrics._();

  /// Accès défensif à une métrique IA numérique par clé possible (le
  /// contrat exact du micro-service IA n'est pas visible depuis Laravel).
  num? iaMetric(String key) {
    final value = metriquesIa?[key];
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }
}
