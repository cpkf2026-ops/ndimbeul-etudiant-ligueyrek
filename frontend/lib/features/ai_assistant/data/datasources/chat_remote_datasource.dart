import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/chat_stream_event.dart';
import '../models/conversation_ia_model.dart';

abstract interface class ChatRemoteDataSource {
  Stream<ChatStreamEvent> sendMessage({required String message, String? conversationId});

  Future<List<ConversationSummaryModel>> getConversations();

  Future<ConversationIaModel> getConversation(String id);
}

/// Implémentation réelle — `POST /api/v1/ai/chat` en streaming SSE
/// (`text/event-stream`, relayé tel quel depuis Django par
/// `AiProxyController::chat`). Le contrat exact des frames émises par Django
/// n'est pas visible depuis Laravel : parsing défensif — toute frame `data:`
/// JSON-décodable avec une clé `token`/`delta`/`content`/`text` devient un
/// [ChatStreamEvent.token], `done`/`[DONE]` termine le flux, tout le reste
/// non JSON est traité comme texte brut (dégradation gracieuse).
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Stream<ChatStreamEvent> sendMessage({
    required String message,
    String? conversationId,
  }) async* {
    Response<ResponseBody> response;
    try {
      response = await _dio.post<ResponseBody>(
        ApiEndpoints.aiChat,
        data: {
          'message': message,
          if (conversationId != null) 'conversation_id': conversationId,
        },
        options: Options(responseType: ResponseType.stream),
      );
    } on DioException catch (e) {
      yield ChatStreamEvent.error(_errorMessage(e));
      return;
    }

    var buffer = '';
    var lastConversationId = conversationId ?? '';
    final sources = <String>[];

    await for (final chunk in response.data!.stream) {
      buffer += utf8.decode(chunk, allowMalformed: true);

      while (buffer.contains('\n\n')) {
        final frameEnd = buffer.indexOf('\n\n');
        final frame = buffer.substring(0, frameEnd);
        buffer = buffer.substring(frameEnd + 2);

        final dataLines = frame
            .split('\n')
            .where((line) => line.startsWith('data:'))
            .map((line) => line.substring(5).trim())
            .join('\n');
        if (dataLines.isEmpty) continue;

        if (dataLines == '[DONE]') {
          yield ChatStreamEvent.done(conversationId: lastConversationId, sources: sources);
          return;
        }

        Map<String, dynamic>? decoded;
        try {
          final parsed = jsonDecode(dataLines);
          if (parsed is Map<String, dynamic>) decoded = parsed;
        } catch (_) {
          decoded = null;
        }

        if (decoded == null) {
          yield ChatStreamEvent.token(dataLines);
          continue;
        }

        if (decoded['conversation_id'] != null) {
          lastConversationId = decoded['conversation_id'].toString();
        }
        if (decoded['sources'] is List) {
          sources
            ..clear()
            ..addAll((decoded['sources'] as List).map((e) => e.toString()));
        }
        if (decoded['error'] != null) {
          yield ChatStreamEvent.error(decoded['error'].toString());
          return;
        }
        if (decoded['done'] == true || decoded['type'] == 'done') {
          yield ChatStreamEvent.done(conversationId: lastConversationId, sources: sources);
          return;
        }

        final token = decoded['token'] ?? decoded['delta'] ?? decoded['content'] ?? decoded['text'];
        if (token != null) {
          yield ChatStreamEvent.token(token.toString());
        }
      }
    }

    yield ChatStreamEvent.done(conversationId: lastConversationId, sources: sources);
  }

  @override
  Future<List<ConversationSummaryModel>> getConversations() async {
    try {
      final response = await _dio.get(ApiEndpoints.aiConversations);
      final data = (response.data as Map<String, dynamic>)['data'] as List;
      return data
          .map((e) => ConversationSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<ConversationIaModel> getConversation(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.aiConversation(id));
      return ConversationIaModel.fromJson(
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  String _errorMessage(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Pas de connexion internet.';
    }
    return e.response?.data?['message'] as String? ?? 'Le service IA est momentanément indisponible.';
  }

  Exception _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkException();
    }
    if (e.response?.statusCode == 401) return const UnauthorizedException();
    return ServerException(
      message: e.response?.data?['message'] as String? ?? 'Erreur serveur',
      statusCode: e.response?.statusCode,
    );
  }
}
