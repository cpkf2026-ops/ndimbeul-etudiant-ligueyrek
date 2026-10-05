// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offre_emploi_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OffreEmploiModelImpl _$$OffreEmploiModelImplFromJson(
  Map<String, dynamic> json,
) => _$OffreEmploiModelImpl(
  id: json['id'] as String,
  intitule: json['intitule'] as String,
  entreprise: _entrepriseFromJson(json['entreprise']),
  type: _typeFromJson(json['type'] as String),
  domaine: _domaineFromJson(json['domaine']),
  niveauRequis: json['niveau_requis'] as String?,
  region: _regionFromJson(json['region']),
  description: _descriptionFromJson(json['description']),
  sourceUrl: json['source_url'] as String?,
  source: json['source'] as String?,
  fiabilite: json['fiabilite'] as String?,
  datePublication: json['date_publication'] == null
      ? null
      : DateTime.parse(json['date_publication'] as String),
  dateLimite: json['date_limite'] == null
      ? null
      : DateTime.parse(json['date_limite'] as String),
  dateIndexation: json['date_indexation'] == null
      ? null
      : DateTime.parse(json['date_indexation'] as String),
  statut: json['statut'] as String,
  expiree: json['expiree'] as bool? ?? false,
  estFavori: json['est_favori'] as bool?,
);

Map<String, dynamic> _$$OffreEmploiModelImplToJson(
  _$OffreEmploiModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'intitule': instance.intitule,
  'entreprise': instance.entreprise,
  'type': _typeToJson(instance.type),
  'domaine': instance.domaine,
  'niveau_requis': instance.niveauRequis,
  'region': instance.region,
  'description': instance.description,
  'source_url': instance.sourceUrl,
  'source': instance.source,
  'fiabilite': instance.fiabilite,
  'date_publication': instance.datePublication?.toIso8601String(),
  'date_limite': instance.dateLimite?.toIso8601String(),
  'date_indexation': instance.dateIndexation?.toIso8601String(),
  'statut': instance.statut,
  'expiree': instance.expiree,
  'est_favori': instance.estFavori,
};
