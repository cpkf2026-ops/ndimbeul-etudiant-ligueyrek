// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bourse_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BourseModelImpl _$$BourseModelImplFromJson(Map<String, dynamic> json) =>
    _$BourseModelImpl(
      id: json['id'] as String,
      universiteId: json['universite_id'] as String?,
      nom: json['nom'] as String,
      organisme: json['organisme'] as String?,
      montant: _decimalFromJson(json['montant']),
      devise: json['devise'] as String? ?? 'XOF',
      conditions: json['conditions'] as String?,
      demarches: json['demarches'] as String?,
      dateLimite: json['date_limite'] == null
          ? null
          : DateTime.parse(json['date_limite'] as String),
      expiree: json['expiree'] as bool? ?? false,
      lien: json['lien'] as String?,
      source: json['source'] as String?,
      dateMaj: json['date_maj'] == null
          ? null
          : DateTime.parse(json['date_maj'] as String),
    );

Map<String, dynamic> _$$BourseModelImplToJson(_$BourseModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'universite_id': instance.universiteId,
      'nom': instance.nom,
      'organisme': instance.organisme,
      'montant': _decimalToJson(instance.montant),
      'devise': instance.devise,
      'conditions': instance.conditions,
      'demarches': instance.demarches,
      'date_limite': instance.dateLimite?.toIso8601String(),
      'expiree': instance.expiree,
      'lien': instance.lien,
      'source': instance.source,
      'date_maj': instance.dateMaj?.toIso8601String(),
    };
