import '../../../../core/utils/result.dart';
import '../entities/chat_stream_event.dart';
import '../entities/conversation_ia.dart';

abstract interface class ChatRepository {
  /// `POST /ai/chat` — flux SSE token par token (voir §4.5/§8 : StreamProvider
  /// isolé, jamais wrappé dans `Result` puisqu'un flux gère déjà ses propres
  /// erreurs événement par événement via [ChatStreamEvent.error]).
  Stream<ChatStreamEvent> sendMessage({required String message, String? conversationId});

  Future<Result<List<ConversationSummary>>> getConversations();

  Future<Result<ConversationIa>> getConversation(String id);
}
