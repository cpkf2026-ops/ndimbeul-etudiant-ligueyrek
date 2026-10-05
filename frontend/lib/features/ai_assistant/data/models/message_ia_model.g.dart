// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_ia_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageIaModelImpl _$$MessageIaModelImplFromJson(Map<String, dynamic> json) =>
    _$MessageIaModelImpl(
      role: _roleFromJson(json['role'] as String),
      contenu: json['contenu'] as String,
      sources: _sourcesFromJson(json['sources'] as List?),
      date: json['date'] == null
          ? null
          : DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$$MessageIaModelImplToJson(
  _$MessageIaModelImpl instance,
) => <String, dynamic>{
  'role': _roleToJson(instance.role),
  'contenu': instance.contenu,
  'sources': instance.sources
      ?.map((e) => <String, dynamic>{'titre': e.titre, 'url': e.url})
      .toList(),
  'date': instance.date?.toIso8601String(),
};
