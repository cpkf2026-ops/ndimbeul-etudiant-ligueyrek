
part of 'actualite_admin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActualiteAdminModelImpl _$$ActualiteAdminModelImplFromJson(
  Map<String, dynamic> json,
) => _$ActualiteAdminModelImpl(
  id: json['id'] as String,
  titre: json['titre'] as String,
  contenu: json['contenu'] as String?,
  categorie: json['categorie'] as String?,
  sourceUrl: json['source_url'] as String?,
  imageUrl: json['image_url'] as String?,
  datePublication: json['date_publication'] == null
      ? null
      : DateTime.parse(json['date_publication'] as String),
  auteur: json['auteur'] as String?,
);

Map<String, dynamic> _$$ActualiteAdminModelImplToJson(
  _$ActualiteAdminModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'titre': instance.titre,
  'contenu': instance.contenu,
  'categorie': instance.categorie,
  'source_url': instance.sourceUrl,
  'image_url': instance.imageUrl,
  'date_publication': instance.datePublication?.toIso8601String(),
  'auteur': instance.auteur,
};
