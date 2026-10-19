import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';

/// Ajout assisté par l'IA (back-office) : recherche web -> proposition -> publication.
/// Les réponses restent des Map : ce sont des formulaires pré-remplis que l'administrateur
/// relit et corrige, pas des entités métier.
class AssistantRemoteDataSource {
  AssistantRemoteDataSource(this._dio);
  final Dio _dio;

  // Recherche web + lecture du site officiel : peut prendre ~20-40 s.
  static const _long = Duration(seconds: 100);

  Future<Map<String, dynamic>> rechercherEtablissement(String nom) => _post(
        '/admin/universities/recherche',
        {'nom': nom},
      );

  Future<Map<String, dynamic>> analyserLien(String url, String genre) => _post(
        '/admin/contenus/analyser',
        {'url': url, 'genre': genre},
      );

  /// genre : etablissement | actualite | offre.
  Future<Map<String, dynamic>> publier(String genre, Map<String, dynamic> donnees) {
    const chemins = {
      'etablissement': '/admin/universities/publier',
      'actualite': '/admin/news',
      'offre': '/admin/jobs',
    };
    return _post(chemins[genre]!, donnees);
  }

  Future<Map<String, dynamic>> _post(String chemin, Map<String, dynamic> corps) async {
    try {
      final r = await _dio.post(
        chemin,
        data: corps,
        options: Options(receiveTimeout: _long, sendTimeout: _long),
      );
      return Map<String, dynamic>.from(r.data as Map);
    } on DioException catch (e) {
      final data = e.response?.data;
      String? message;
      if (data is Map) {
        message = data['message'] as String?;
        final erreurs = data['errors'];
        if (erreurs is Map && erreurs.isNotEmpty) {
          message = (erreurs.values.first as List).first.toString();
        }
      }
      throw AssistantException(message ??
          (e.type == DioExceptionType.receiveTimeout
              ? 'La recherche a pris trop de temps. Réessayez.'
              : 'Le serveur ne répond pas. Vérifiez votre connexion.'));
    }
  }
}

class AssistantException implements Exception {
  AssistantException(this.message);
  final String message;
  @override
  String toString() => message;
}

final assistantDataSourceProvider =
    Provider<AssistantRemoteDataSource>((ref) => AssistantRemoteDataSource(ref.read(dioProvider)));
