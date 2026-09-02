// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profil_lyceen_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfilLyceenModelImpl _$$ProfilLyceenModelImplFromJson(
  Map<String, dynamic> json,
) => _$ProfilLyceenModelImpl(
  serieBac: json['serie_bac'] as String?,
  moyenneGenerale: (json['moyenne_generale'] as num?)?.toDouble(),
  passions: _stringListFromJson(json['passions'] as List?),
  metiersEnvisages: _stringListFromJson(json['metiers_envisages'] as List?),
  budgetMaxAnnuel: (json['budget_max_annuel'] as num?)?.toDouble(),
  mobilite: json['mobilite'] as bool? ?? false,
  prefPublicPrive: json['pref_public_prive'] == null
      ? PrefEtablissement.indifferent
      : _prefFromJson(json['pref_public_prive'] as String?),
  regionCible: json['region_cible'] as String?,
  anneeTerminale: (json['annee_terminale'] as num?)?.toInt(),
  completude: (json['completude'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$ProfilLyceenModelImplToJson(
  _$ProfilLyceenModelImpl instance,
) => <String, dynamic>{
  'serie_bac': instance.serieBac,
  'moyenne_generale': instance.moyenneGenerale,
  'passions': instance.passions,
  'metiers_envisages': instance.metiersEnvisages,
  'budget_max_annuel': instance.budgetMaxAnnuel,
  'mobilite': instance.mobilite,
  'pref_public_prive': _prefToJson(instance.prefPublicPrive),
  'region_cible': instance.regionCible,
  'annee_terminale': instance.anneeTerminale,
  'completude': instance.completude,
};
