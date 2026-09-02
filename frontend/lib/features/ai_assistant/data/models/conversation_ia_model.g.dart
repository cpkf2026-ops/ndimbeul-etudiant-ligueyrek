// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_ia_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConversationSummaryModelImpl _$$ConversationSummaryModelImplFromJson(
  Map<String, dynamic> json,
) => _$ConversationSummaryModelImpl(
  id: json['id'] as String,
  dateDerniereActivite: json['date_derniere_activite'] == null
      ? null
      : DateTime.parse(json['date_derniere_activite'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$ConversationSummaryModelImplToJson(
  _$ConversationSummaryModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'date_derniere_activite': instance.dateDerniereActivite?.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
};

_$ConversationIaModelImpl _$$ConversationIaModelImplFromJson(
  Map<String, dynamic> json,
) => _$ConversationIaModelImpl(
  id: json['id'] as String,
  messages: (json['messages'] as List<dynamic>?)
      ?.map((e) => MessageIaModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  dateDerniereActivite: json['date_derniere_activite'] == null
      ? null
      : DateTime.parse(json['date_derniere_activite'] as String),
);

Map<String, dynamic> _$$ConversationIaModelImplToJson(
  _$ConversationIaModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'messages': instance.messages,
  'date_derniere_activite': instance.dateDerniereActivite?.toIso8601String(),
};
