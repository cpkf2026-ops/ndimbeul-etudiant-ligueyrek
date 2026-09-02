// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'formation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FormationModelImpl _$$FormationModelImplFromJson(Map<String, dynamic> json) =>
    _$FormationModelImpl(
      id: json['id'] as String,
      universiteId: json['universite_id'] as String,
      universiteNom: json['universite_nom'] as String?,
      intitule: json['intitule'] as String,
      domaine: json['domaine'] as String,
      niveau: _niveauFromJson(json['niveau'] as String),
      dureeAnnees: (json['duree_annees'] as num?)?.toInt(),
      seriesAcceptees: _seriesFromJson(json['series_acceptees'] as List?),
      moyenneMinimale: _decimalFromJson(json['moyenne_minimale']),
      capacite: (json['capacite'] as num?)?.toInt(),
      prerequis: json['prerequis'] as String?,
      debouches: json['debouches'] as String?,
      estFavori: json['est_favori'] as bool? ?? false,
    );

Map<String, dynamic> _$$FormationModelImplToJson(
  _$FormationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'universite_id': instance.universiteId,
  'universite_nom': instance.universiteNom,
  'intitule': instance.intitule,
  'domaine': instance.domaine,
  'niveau': _niveauToJson(instance.niveau),
  'duree_annees': instance.dureeAnnees,
  'series_acceptees': instance.seriesAcceptees,
  'moyenne_minimale': _decimalToJson(instance.moyenneMinimale),
  'capacite': instance.capacite,
  'prerequis': instance.prerequis,
  'debouches': instance.debouches,
  'est_favori': instance.estFavori,
};
