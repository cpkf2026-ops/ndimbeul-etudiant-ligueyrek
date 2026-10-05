import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/datasources/mock_chat_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/conversation_ia.dart';
import '../../domain/entities/message_ia.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/get_conversation_detail.dart';
import '../../domain/usecases/get_conversations.dart';
import '../../domain/usecases/send_chat_message.dart';

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  if (ref.watch(useMockProvider)) return MockChatRemoteDataSource();
  return ChatRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(remoteDataSource: ref.watch(chatRemoteDataSourceProvider));
});

final sendChatMessageUseCaseProvider =
    Provider((ref) => SendChatMessage(ref.watch(chatRepositoryProvider)));
final getConversationsUseCaseProvider =
    Provider((ref) => GetConversations(ref.watch(chatRepositoryProvider)));
final getConversationDetailUseCaseProvider =
    Provider((ref) => GetConversationDetail(ref.watch(chatRepositoryProvider)));

/// Messages déjà finalisés de la conversation courante — ne change PAS
/// pendant le streaming d'un token (voir [chatStreamingTextProvider]), pour
/// éviter de reconstruire toute la liste de bulles à chaque token reçu (§8).
class ChatMessagesNotifier extends Notifier<List<MessageIa>> {
  @override
  List<MessageIa> build() => [];

  void add(MessageIa message) => state = [...state, message];

  void reset() => state = [];

  void loadHistory(List<MessageIa> messages) => state = messages;
}

final chatMessagesProvider = NotifierProvider<ChatMessagesNotifier, List<MessageIa>>(
  ChatMessagesNotifier.new,
);

/// Texte en cours d'accumulation pendant le streaming — `null` hors
/// streaming. Isolé dans son propre provider pour qu'un seul widget
/// (la bulle en cours) se reconstruise à chaque token, jamais tout l'écran.
final chatStreamingTextProvider = StateProvider<String?>((ref) => null);
final chatIsStreamingProvider = StateProvider<bool>((ref) => false);
final chatCurrentConversationIdProvider = StateProvider<String?>((ref) => null);

class ChatController {
  ChatController(this._ref);
  final Ref _ref;

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _ref.read(chatIsStreamingProvider)) return;

    _ref.read(chatMessagesProvider.notifier).add(
          MessageIa(role: MessageRole.user, contenu: trimmed, date: DateTime.now()),
        );
    _ref.read(chatStreamingTextProvider.notifier).state = '';
    _ref.read(chatIsStreamingProvider.notifier).state = true;

    final conversationId = _ref.read(chatCurrentConversationIdProvider);
    final stream = _ref.read(sendChatMessageUseCaseProvider).call(
          message: trimmed,
          conversationId: conversationId,
        );

    final buffer = StringBuffer();
    var sources = const <SourceCitee>[];
    String? errorMessage;

    await for (final event in stream) {
      event.when(
        token: (delta) {
          buffer.write(delta);
          _ref.read(chatStreamingTextProvider.notifier).state = buffer.toString();
        },
        done: (newConversationId, newSources) {
          sources = newSources;
          if (newConversationId.isNotEmpty) {
            _ref.read(chatCurrentConversationIdProvider.notifier).state = newConversationId;
          }
        },
        error: (message) => errorMessage = message,
      );
    }

    _ref.read(chatIsStreamingProvider.notifier).state = false;
    _ref.read(chatStreamingTextProvider.notifier).state = null;

    if (errorMessage != null) {
      _ref.read(chatMessagesProvider.notifier).add(
            MessageIa(
              role: MessageRole.assistant,
              contenu: 'Désolé, une erreur est survenue : $errorMessage',
              date: DateTime.now(),
            ),
          );
      return;
    }

    _ref.read(chatMessagesProvider.notifier).add(
          MessageIa(
            role: MessageRole.assistant,
            contenu: buffer.toString(),
            sources: sources,
            date: DateTime.now(),
          ),
        );
  }

  void startNewConversation() {
    _ref.read(chatMessagesProvider.notifier).reset();
    _ref.read(chatCurrentConversationIdProvider.notifier).state = null;
  }

  Future<Failure?> openConversation(String id) async {
    final result = await _ref.read(getConversationDetailUseCaseProvider).call(id);
    return result.fold((failure) => failure, (conversation) {
      _ref.read(chatMessagesProvider.notifier).loadHistory(conversation.messages);
      _ref.read(chatCurrentConversationIdProvider.notifier).state = conversation.id;
      return null;
    });
  }
}

final chatControllerProvider = Provider((ref) => ChatController(ref));

final conversationsProvider = FutureProvider<List<ConversationSummary>>((ref) async {
  final result = await ref.read(getConversationsUseCaseProvider).call(const NoParams());
  return result.fold((failure) => throw failure, (list) => list);
});
