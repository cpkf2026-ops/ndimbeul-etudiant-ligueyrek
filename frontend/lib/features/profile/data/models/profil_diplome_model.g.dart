// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profil_diplome_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfilDiplomeModelImpl _$$ProfilDiplomeModelImplFromJson(
  Map<String, dynamic> json,
) => _$ProfilDiplomeModelImpl(
  dernierDiplome: json['dernier_diplome'] as String?,
  domaine: json['domaine'] as String?,
  situationActuelle: _situationFromJson(json['situation_actuelle'] as String?),
  entreprise: json['entreprise'] as String?,
);

Map<String, dynamic> _$$ProfilDiplomeModelImplToJson(
  _$ProfilDiplomeModelImpl instance,
) => <String, dynamic>{
  'dernier_diplome': instance.dernierDiplome,
  'domaine': instance.domaine,
  'situation_actuelle': _situationToJson(instance.situationActuelle),
  'entreprise': instance.entreprise,
};
