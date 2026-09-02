// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'frais_scolarite_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FraisScolariteModelImpl _$$FraisScolariteModelImplFromJson(
  Map<String, dynamic> json,
) => _$FraisScolariteModelImpl(
  id: json['id'] as String,
  universiteId: json['universite_id'] as String,
  formationId: json['formation_id'] as String?,
  montant: _decimalFromJson(json['montant']),
  devise: json['devise'] as String? ?? 'XOF',
  echeancier: json['echeancier'] as List<dynamic>?,
  moyensPaiement: (json['moyens_paiement'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  source: json['source'] as String?,
  dateMaj: json['date_maj'] == null
      ? null
      : DateTime.parse(json['date_maj'] as String),
);

Map<String, dynamic> _$$FraisScolariteModelImplToJson(
  _$FraisScolariteModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'universite_id': instance.universiteId,
  'formation_id': instance.formationId,
  'montant': _decimalToJson(instance.montant),
  'devise': instance.devise,
  'echeancier': instance.echeancier,
  'moyens_paiement': instance.moyensPaiement,
  'source': instance.source,
  'date_maj': instance.dateMaj?.toIso8601String(),
};
