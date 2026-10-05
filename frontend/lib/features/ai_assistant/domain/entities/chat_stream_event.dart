import 'package:freezed_annotation/freezed_annotation.dart';
import 'message_ia.dart';

part 'chat_stream_event.freezed.dart';

/// Événement unitaire du flux SSE `/ai/chat` — un delta de texte, la fin de
/// la réponse (avec sources citées) ou une erreur de flux.
@freezed
sealed class ChatStreamEvent with _$ChatStreamEvent {
  const factory ChatStreamEvent.token(String delta) = ChatStreamEventToken;
  const factory ChatStreamEvent.done({
    required String conversationId,
    @Default(<SourceCitee>[]) List<SourceCitee> sources,
  }) = ChatStreamEventDone;
  const factory ChatStreamEvent.error(String message) = ChatStreamEventError;
}
