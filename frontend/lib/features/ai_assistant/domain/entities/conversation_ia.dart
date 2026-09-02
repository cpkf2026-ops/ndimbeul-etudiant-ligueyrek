import 'package:freezed_annotation/freezed_annotation.dart';
import 'message_ia.dart';

part 'conversation_ia.freezed.dart';

/// Résumé de conversation — tel que renvoyé par `GET /ai/conversations`
/// (liste allégée, sans `messages`).
@freezed
sealed class ConversationSummary with _$ConversationSummary {
  const factory ConversationSummary({
    required String id,
    DateTime? dateDerniereActivite,
    DateTime? dateCreation,
  }) = _ConversationSummary;
}

/// Conversation complète — telle que renvoyée par `GET /ai/conversations/{id}`.
@freezed
sealed class ConversationIa with _$ConversationIa {
  const factory ConversationIa({
    required String id,
    @Default(<MessageIa>[]) List<MessageIa> messages,
    DateTime? dateDerniereActivite,
  }) = _ConversationIa;
}
