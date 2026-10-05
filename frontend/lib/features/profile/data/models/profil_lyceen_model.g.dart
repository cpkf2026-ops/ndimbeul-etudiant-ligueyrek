// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profil_lyceen_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfilLyceenModelImpl _$$ProfilLyceenModelImplFromJson(
  Map<String, dynamic> json,
) => _$ProfilLyceenModelImpl(
  serieBac: json['serie_bac'] as String?,
  moyenneGenerale: _decimalFromJson(json['moyenne_generale']),
  passions: _stringListFromJson(json['passions'] as List?),
  matieresFortes: _stringListFromJson(json['matieres_fortes'] as List?),
  metiersEnvisages: _stringListFromJson(json['metiers_envisages'] as List?),
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
  'moyenne_generale': _decimalToJson(instance.moyenneGenerale),
  'passions': instance.passions,
  'matieres_fortes': instance.matieresFortes,
  'metiers_envisages': instance.metiersEnvisages,
  'mobilite': instance.mobilite,
  'pref_public_prive': _prefToJson(instance.prefPublicPrive),
  'region_cible': instance.regionCible,
  'annee_terminale': instance.anneeTerminale,
  'completude': instance.completude,
};
