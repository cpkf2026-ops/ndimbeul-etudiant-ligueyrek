// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actualite_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActualiteModelImpl _$$ActualiteModelImplFromJson(Map<String, dynamic> json) =>
    _$ActualiteModelImpl(
      id: json['id'] as String,
      titre: json['titre'] as String,
      contenu: json['contenu'] as String,
      categorie: _categorieFromJson(json['categorie'] as String),
      sourceUrl: json['source_url'] as String?,
      imageUrl: json['image_url'] as String?,
      datePublication: DateTime.parse(json['date_publication'] as String),
      dateIndexation: json['date_indexation'] == null
          ? null
          : DateTime.parse(json['date_indexation'] as String),
      auteur: json['auteur'] as String?,
      fiabilite: json['fiabilite'] as String?,
    );

Map<String, dynamic> _$$ActualiteModelImplToJson(
  _$ActualiteModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'titre': instance.titre,
  'contenu': instance.contenu,
  'categorie': _categorieToJson(instance.categorie),
  'source_url': instance.sourceUrl,
  'image_url': instance.imageUrl,
  'date_publication': instance.datePublication.toIso8601String(),
  'date_indexation': instance.dateIndexation?.toIso8601String(),
  'auteur': instance.auteur,
  'fiabilite': instance.fiabilite,
};
