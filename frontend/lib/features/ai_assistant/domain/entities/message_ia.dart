import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_ia.freezed.dart';

enum MessageRole { user, assistant }

/// Une source citée par l'IA — `url` est le vrai site officiel de l'établissement
/// ou l'annonce source (voir rag_local.py côté Django), `null` pour les documents
/// importés manuellement sans page web associée (jamais de lien inventé).
typedef SourceCitee = ({String titre, String? url});

/// Message d'une conversation IA — reflète la structure stockée dans
/// `ConversationIa::ajouterMessage()` côté backend
/// (`{role, contenu, sources, date}`).
@freezed
sealed class MessageIa with _$MessageIa {
  const factory MessageIa({
    required MessageRole role,
    required String contenu,
    @Default(<SourceCitee>[]) List<SourceCitee> sources,
    DateTime? date,
    @Default(false) bool isStreaming,
  }) = _MessageIa;

  const MessageIa._();
}
