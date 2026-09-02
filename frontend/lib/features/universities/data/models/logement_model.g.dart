// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LogementModelImpl _$$LogementModelImplFromJson(Map<String, dynamic> json) =>
    _$LogementModelImpl(
      id: json['id'] as String,
      universiteId: json['universite_id'] as String,
      nom: json['nom'] as String,
      type: _typeFromJson(json['type'] as String),
      capacite: (json['capacite'] as num?)?.toInt(),
      tarifMensuel: _decimalFromJson(json['tarif_mensuel']),
      devise: json['devise'] as String? ?? 'XOF',
      contact: json['contact'] as String?,
      source: json['source'] as String?,
      dateMaj: json['date_maj'] == null
          ? null
          : DateTime.parse(json['date_maj'] as String),
    );

Map<String, dynamic> _$$LogementModelImplToJson(_$LogementModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'universite_id': instance.universiteId,
      'nom': instance.nom,
      'type': _typeToJson(instance.type),
      'capacite': instance.capacite,
      'tarif_mensuel': _decimalToJson(instance.tarifMensuel),
      'devise': instance.devise,
      'contact': instance.contact,
      'source': instance.source,
      'date_maj': instance.dateMaj?.toIso8601String(),
    };
