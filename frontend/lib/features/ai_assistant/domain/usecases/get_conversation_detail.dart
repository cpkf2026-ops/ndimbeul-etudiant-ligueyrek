import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/conversation_ia.dart';
import '../repositories/chat_repository.dart';

class GetConversationDetail implements UseCase<ConversationIa, String> {
  const GetConversationDetail(this._repository);
  final ChatRepository _repository;

  @override
  Future<Result<ConversationIa>> call(String id) => _repository.getConversation(id);
}
