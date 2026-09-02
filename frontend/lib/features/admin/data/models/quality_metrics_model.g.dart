
part of 'quality_metrics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QualityMetricsLaravelModelImpl _$$QualityMetricsLaravelModelImplFromJson(
  Map<String, dynamic> json,
) => _$QualityMetricsLaravelModelImpl(
  sourcesActives: (json['sources_actives'] as num?)?.toInt(),
  sourcesEnErreur: (json['sources_en_erreur'] as num?)?.toInt(),
  sourcesObsoletes: (json['sources_obsoletes'] as num?)?.toInt(),
  offresActives: (json['offres_actives'] as num?)?.toInt(),
  offresExpirees: (json['offres_expirees'] as num?)?.toInt(),
  actionsAdmin7DerniersJours: (json['actions_admin_7_derniers_jours'] as num?)
      ?.toInt(),
);

Map<String, dynamic> _$$QualityMetricsLaravelModelImplToJson(
  _$QualityMetricsLaravelModelImpl instance,
) => <String, dynamic>{
  'sources_actives': instance.sourcesActives,
  'sources_en_erreur': instance.sourcesEnErreur,
  'sources_obsoletes': instance.sourcesObsoletes,
  'offres_actives': instance.offresActives,
  'offres_expirees': instance.offresExpirees,
  'actions_admin_7_derniers_jours': instance.actionsAdmin7DerniersJours,
};

_$QualityMetricsModelImpl _$$QualityMetricsModelImplFromJson(
  Map<String, dynamic> json,
) => _$QualityMetricsModelImpl(
  metriquesIa: json['metriques_ia'] as Map<String, dynamic>?,
  metriquesLaravel: json['metriques_laravel'] == null
      ? null
      : QualityMetricsLaravelModel.fromJson(
          json['metriques_laravel'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$$QualityMetricsModelImplToJson(
  _$QualityMetricsModelImpl instance,
) => <String, dynamic>{
  'metriques_ia': instance.metriquesIa,
  'metriques_laravel': instance.metriquesLaravel,
};
