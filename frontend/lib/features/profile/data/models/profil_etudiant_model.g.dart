// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profil_etudiant_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfilEtudiantModelImpl _$$ProfilEtudiantModelImplFromJson(
  Map<String, dynamic> json,
) => _$ProfilEtudiantModelImpl(
  universiteActuelle: json['universite_actuelle'] as String?,
  formationActuelle: json['formation_actuelle'] as String?,
  niveauActuel: _niveauFromJson(json['niveau_actuel'] as String?),
  domainesInterets: _stringListFromJson(json['domaines_interets'] as List?),
  rechercheStage: json['recherche_stage'] as bool? ?? false,
  rechercheEmploi: json['recherche_emploi'] as bool? ?? false,
);

Map<String, dynamic> _$$ProfilEtudiantModelImplToJson(
  _$ProfilEtudiantModelImpl instance,
) => <String, dynamic>{
  'universite_actuelle': instance.universiteActuelle,
  'formation_actuelle': instance.formationActuelle,
  'niveau_actuel': _niveauToJson(instance.niveauActuel),
  'domaines_interets': instance.domainesInterets,
  'recherche_stage': instance.rechercheStage,
  'recherche_emploi': instance.rechercheEmploi,
};
