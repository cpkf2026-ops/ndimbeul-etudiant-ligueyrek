import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_ia.freezed.dart';

enum MessageRole { user, assistant }

/// Message d'une conversation IA — reflète la structure stockée dans
/// `ConversationIa::ajouterMessage()` côté backend
/// (`{role, contenu, sources, date}`).
@freezed
sealed class MessageIa with _$MessageIa {
  const factory MessageIa({
    required MessageRole role,
    required String contenu,
    @Default(<String>[]) List<String> sources,
    DateTime? date,
    @Default(false) bool isStreaming,
  }) = _MessageIa;

  const MessageIa._();
}
