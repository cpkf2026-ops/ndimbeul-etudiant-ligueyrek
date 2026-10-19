// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'universite_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UniversiteModelImpl _$$UniversiteModelImplFromJson(
  Map<String, dynamic> json,
) => _$UniversiteModelImpl(
  id: json['id'] as String,
  nom: json['nom'] as String,
  codeUnique: json['code_unique'] as String,
  region: json['region'] as String?,
  commune: json['commune'] as String?,
  type: _typeFromJson(json['type'] as String?),
  siteWebOfficiel: json['site_web_officiel'] as String?,
  description: json['description'] as String?,
  imageUrl: json['image_url'] as String?,
  contact: json['contact'] == null
      ? null
      : ContactModel.fromJson(json['contact'] as Map<String, dynamic>),
  domaines:
      (json['domaines'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  diplomes:
      (json['diplomes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  admission: json['admission'] as String?,
  niveauRequis:
      (json['niveau_requis'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  piecesAFournir:
      (json['pieces_a_fournir'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  sourceInfos: json['source_infos'] as String?,
  formations:
      (json['formations'] as List<dynamic>?)
          ?.map((e) => FormationModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  bourses:
      (json['bourses'] as List<dynamic>?)
          ?.map((e) => BourseModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  logements:
      (json['logements'] as List<dynamic>?)
          ?.map((e) => LogementModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  fraisScolarite:
      (json['frais_scolarite'] as List<dynamic>?)
          ?.map((e) => FraisScolariteModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$UniversiteModelImplToJson(
  _$UniversiteModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'nom': instance.nom,
  'code_unique': instance.codeUnique,
  'region': instance.region,
  'commune': instance.commune,
  'type': _typeToJson(instance.type),
  'site_web_officiel': instance.siteWebOfficiel,
  'description': instance.description,
  'image_url': instance.imageUrl,
  'contact': instance.contact,
  'domaines': instance.domaines,
  'diplomes': instance.diplomes,
  'admission': instance.admission,
  'niveau_requis': instance.niveauRequis,
  'pieces_a_fournir': instance.piecesAFournir,
  'source_infos': instance.sourceInfos,
  'formations': instance.formations,
  'bourses': instance.bourses,
  'logements': instance.logements,
  'frais_scolarite': instance.fraisScolarite,
};
