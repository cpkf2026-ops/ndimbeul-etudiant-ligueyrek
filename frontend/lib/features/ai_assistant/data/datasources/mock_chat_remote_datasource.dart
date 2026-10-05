import '../../domain/entities/chat_stream_event.dart';
import '../../domain/entities/message_ia.dart';
import '../models/conversation_ia_model.dart';
import '../models/message_ia_model.dart';
import 'chat_remote_datasource.dart';

/// Jeu de données mocké — simule un flux SSE token par token pour développer
/// et démontrer le chat sans backend branché (voir §10 / §4.5).
class MockChatRemoteDataSource implements ChatRemoteDataSource {
  static final Map<String, List<MessageIaModel>> _conversations = {};

  String _reponsePour(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('bourse')) {
      return 'Plusieurs bourses sont actuellement ouvertes au Sénégal, notamment la '
          'Bourse d\'excellence UCAD (480 000 FCFA/an, moyenne ≥ 14/20) et la Bourse '
          'régionale de Saint-Louis. Je vous recommande de vérifier les conditions '
          'précises et les dates limites sur la fiche de chaque université — ce ne '
          'sont que des pistes à explorer, pas une liste exhaustive.';
    }
    if (lower.contains('logement')) {
      return 'Pour le logement étudiant, la Cité universitaire UCAD (COUD) propose des '
          'chambres à partir de 15 000 FCFA/mois. À Diamniadio, des résidences privées '
          'partenaires de l\'ISEP sont aussi référencées, autour de 35 000 FCFA/mois. '
          'Ce sont des options parmi d\'autres selon votre budget et votre région.';
    }
    if (lower.contains('informatique') || lower.contains('flutter') || lower.contains('dev')) {
      return 'Pour l\'informatique, plusieurs formations sénégalaises sont reconnues : '
          'la Licence Informatique de l\'UCAD, le Génie Logiciel de l\'ISEP Diamniadio, '
          'ou encore le cursus Ingénieur de l\'ESP (très sélectif, moyenne ≥ 15/20). '
          'Le meilleur choix dépend surtout de votre profil et de vos objectifs — '
          'n\'hésitez pas à comparer les fiches détaillées.';
    }
    return 'Je peux vous aider à explorer les universités, formations, bourses et '
        'logements du Sénégal. Précisez votre série, votre région ou votre domaine '
        'd\'intérêt pour que je vous propose des pistes adaptées à votre profil.';
  }

  @override
  Stream<ChatStreamEvent> sendMessage({
    required String message,
    String? conversationId,
  }) async* {
    final id = conversationId ?? 'conv_${DateTime.now().millisecondsSinceEpoch}';
    final reponse = _reponsePour(message);
    final mots = reponse.split(' ');

    for (var i = 0; i < mots.length; i++) {
      await Future.delayed(const Duration(milliseconds: 45));
      yield ChatStreamEvent.token(i == 0 ? mots[i] : ' ${mots[i]}');
    }

    final sources = <SourceCitee>[
      (titre: 'Université Cheikh Anta Diop', url: 'https://www.ucad.sn'),
      (titre: 'ISEP-Thiès', url: 'https://www.isep-thies.sn'),
    ];
    await Future.delayed(const Duration(milliseconds: 150));
    yield ChatStreamEvent.done(conversationId: id, sources: sources);

    final history = _conversations.putIfAbsent(id, () => []);
    history.add(MessageIaModel(role: MessageRole.user, contenu: message, date: DateTime.now()));
    history.add(
      MessageIaModel(
        role: MessageRole.assistant,
        contenu: reponse,
        sources: sources,
        date: DateTime.now(),
      ),
    );
  }

  @override
  Future<List<ConversationSummaryModel>> getConversations() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return _conversations.entries
        .map(
          (entry) => ConversationSummaryModel(
            id: entry.key,
            dateDerniereActivite: entry.value.isNotEmpty ? entry.value.last.date : null,
            createdAt: entry.value.isNotEmpty ? entry.value.first.date : null,
          ),
        )
        .toList()
        .reversed
        .toList();
  }

  @override
  Future<ConversationIaModel> getConversation(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ConversationIaModel(
      id: id,
      messages: _conversations[id] ?? const [],
      dateDerniereActivite: (_conversations[id]?.isNotEmpty ?? false)
          ? _conversations[id]!.last.date
          : null,
    );
  }
}
