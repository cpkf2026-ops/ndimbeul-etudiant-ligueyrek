import '../entities/chat_stream_event.dart';
import '../repositories/chat_repository.dart';

/// Exception délibérée au contrat `UseCase<Type, Params>` standard (voir
/// core/usecases/usecase.dart) : une opération de streaming SSE ne peut pas
/// être modélisée comme `Future<Result<T>>` sans perdre les événements
/// intermédiaires — elle expose directement le `Stream` du repository.
class SendChatMessage {
  const SendChatMessage(this._repository);
  final ChatRepository _repository;

  Stream<ChatStreamEvent> call({required String message, String? conversationId}) {
    return _repository.sendMessage(message: message, conversationId: conversationId);
  }
}
