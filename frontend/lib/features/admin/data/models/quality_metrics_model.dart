import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/quality_metrics.dart';

part 'quality_metrics_model.freezed.dart';
part 'quality_metrics_model.g.dart';

@freezed
sealed class QualityMetricsLaravelModel with _$QualityMetricsLaravelModel {
  const factory QualityMetricsLaravelModel({
    // ignore: invalid_annotation_target
    @JsonKey(name: 'sources_actives') int? sourcesActives,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'sources_en_erreur') int? sourcesEnErreur,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'sources_obsoletes') int? sourcesObsoletes,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'offres_actives') int? offresActives,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'offres_expirees') int? offresExpirees,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'actions_admin_7_derniers_jours')
    int? actionsAdmin7DerniersJours,
  }) = _QualityMetricsLaravelModel;

  const QualityMetricsLaravelModel._();

  factory QualityMetricsLaravelModel.fromJson(Map<String, dynamic> json) =>
      _$QualityMetricsLaravelModelFromJson(json);

  QualityMetricsLaravel toEntity() => QualityMetricsLaravel(
    sourcesActives: sourcesActives,
    sourcesEnErreur: sourcesEnErreur,
    sourcesObsoletes: sourcesObsoletes,
    offresActives: offresActives,
    offresExpirees: offresExpirees,
    actionsAdmin7DerniersJours: actionsAdmin7DerniersJours,
  );
}

/// Miroir de la réponse `GET /admin/quality` — combine les métriques métier
/// Laravel (typées) et les métriques IA relayées de Django (forme non
/// garantie, gardée en map brute).
@freezed
sealed class QualityMetricsModel with _$QualityMetricsModel {
  const factory QualityMetricsModel({
    // ignore: invalid_annotation_target
    @JsonKey(name: 'metriques_ia') Map<String, dynamic>? metriquesIa,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'metriques_laravel')
    QualityMetricsLaravelModel? metriquesLaravel,
  }) = _QualityMetricsModel;

  const QualityMetricsModel._();

  factory QualityMetricsModel.fromJson(Map<String, dynamic> json) =>
      _$QualityMetricsModelFromJson(json);

  QualityMetrics toEntity() => QualityMetrics(
    metriquesIa: metriquesIa,
    metriquesLaravel: metriquesLaravel?.toEntity(),
  );
}
