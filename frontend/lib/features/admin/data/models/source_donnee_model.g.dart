
part of 'source_donnee_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SourceDonneeModelImpl _$$SourceDonneeModelImplFromJson(
  Map<String, dynamic> json,
) => _$SourceDonneeModelImpl(
  id: json['id'] as String,
  universiteId: json['universite_id'] as String?,
  type: _typeFromJson(json['type'] as String),
  urlOuChemin: json['url_ou_chemin'] as String,
  categorie: json['categorie'] as String?,
  statut: _statutFromJson(json['statut'] as String),
  derniereErreur: json['derniere_erreur'] as String?,
  dateDernierCrawl: json['date_dernier_crawl'] == null
      ? null
      : DateTime.parse(json['date_dernier_crawl'] as String),
);

Map<String, dynamic> _$$SourceDonneeModelImplToJson(
  _$SourceDonneeModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'universite_id': instance.universiteId,
  'type': _typeToJson(instance.type),
  'url_ou_chemin': instance.urlOuChemin,
  'categorie': instance.categorie,
  'statut': _statutToJson(instance.statut),
  'derniere_erreur': instance.derniereErreur,
  'date_dernier_crawl': instance.dateDernierCrawl?.toIso8601String(),
};
