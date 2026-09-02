import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/message_ia.dart';

part 'message_ia_model.freezed.dart';
part 'message_ia_model.g.dart';

MessageRole _roleFromJson(String value) =>
    value == 'assistant' ? MessageRole.assistant : MessageRole.user;

String _roleToJson(MessageRole role) => role == MessageRole.assistant ? 'assistant' : 'user';

List<String> _sourcesFromJson(List<dynamic>? value) =>
    value?.map((e) => e.toString()).toList() ?? const [];

/// Miroir défensif d'un élément du tableau `messages` d'une `ConversationIa`
/// (`{role, contenu, sources, date}`, voir `ConversationIa::ajouterMessage`).
@freezed
sealed class MessageIaModel with _$MessageIaModel {
  const factory MessageIaModel({
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _roleFromJson, toJson: _roleToJson) required MessageRole role,
    required String contenu,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _sourcesFromJson) List<String>? sources,
    DateTime? date,
  }) = _MessageIaModel;

  const MessageIaModel._();

  factory MessageIaModel.fromJson(Map<String, dynamic> json) =>
      _$MessageIaModelFromJson(json);

  MessageIa toEntity() => MessageIa(
        role: role,
        contenu: contenu,
        sources: sources ?? const [],
        date: date,
      );
}
