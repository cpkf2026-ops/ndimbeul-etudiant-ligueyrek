import 'dart:typed_data';

import '../../../../core/utils/result.dart';
import '../entities/source_donnee.dart';

abstract interface class SourceRepository {
  Future<Result<List<SourceDonnee>>> getSources();

  Future<Result<SourceDonnee>> createSource({
    String? universiteId,
    required SourceType type,
    required String urlOuChemin,
    String? categorie,
  });

  Future<Result<SourceDonnee>> updateSource({
    required String id,
    String? universiteId,
    required SourceType type,
    required String urlOuChemin,
    String? categorie,
  });

  Future<Result<void>> deleteSource(String id);

  /// UC12 — envoie un PDF vers l'index RAG Django (`POST
  /// /admin/documents/upload`). [bytes] permet une implémentation
  /// cross-platform (web compris) sans dépendre de `dart:io`.
  Future<Result<Map<String, dynamic>>> uploadDocument({
    required Uint8List bytes,
    required String filename,
    String? sourceId,
    String? universiteId,
    String? categorie,
  });
}
