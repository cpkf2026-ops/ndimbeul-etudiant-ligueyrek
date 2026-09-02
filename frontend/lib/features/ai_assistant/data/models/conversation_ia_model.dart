import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/conversation_ia.dart';
import 'message_ia_model.dart';

part 'conversation_ia_model.freezed.dart';
part 'conversation_ia_model.g.dart';

/// Miroir de la ligne allégée renvoyée par `GET /ai/conversations`
/// (`{id, date_derniere_activite, created_at}`, sans `messages`).
@freezed
sealed class ConversationSummaryModel with _$ConversationSummaryModel {
  const factory ConversationSummaryModel({
    required String id,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'date_derniere_activite') DateTime? dateDerniereActivite,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _ConversationSummaryModel;

  const ConversationSummaryModel._();

  factory ConversationSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationSummaryModelFromJson(json);

  ConversationSummary toEntity() => ConversationSummary(
        id: id,
        dateDerniereActivite: dateDerniereActivite,
        dateCreation: createdAt,
      );
}

/// Miroir de `GET /ai/conversations/{id}` — ligne Eloquent complète de
/// `ConversationIa` (`{id, messages, date_derniere_activite}`).
@freezed
sealed class ConversationIaModel with _$ConversationIaModel {
  const factory ConversationIaModel({
    required String id,
    List<MessageIaModel>? messages,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'date_derniere_activite') DateTime? dateDerniereActivite,
  }) = _ConversationIaModel;

  const ConversationIaModel._();

  factory ConversationIaModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationIaModelFromJson(json);

  ConversationIa toEntity() => ConversationIa(
        id: id,
        messages: (messages ?? const []).map((m) => m.toEntity()).toList(),
        dateDerniereActivite: dateDerniereActivite,
      );
}
