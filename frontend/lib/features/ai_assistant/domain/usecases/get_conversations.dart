import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/conversation_ia.dart';
import '../repositories/chat_repository.dart';

class GetConversations implements UseCase<List<ConversationSummary>, NoParams> {
  const GetConversations(this._repository);
  final ChatRepository _repository;

  @override
  Future<Result<List<ConversationSummary>>> call(NoParams params) =>
      _repository.getConversations();
}
