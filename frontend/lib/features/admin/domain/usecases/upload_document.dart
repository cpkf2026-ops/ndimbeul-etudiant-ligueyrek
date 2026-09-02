import 'dart:typed_data';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/source_repository.dart';

class UploadDocumentParams {
  const UploadDocumentParams({
    required this.bytes,
    required this.filename,
    this.sourceId,
    this.universiteId,
    this.categorie,
  });

  final Uint8List bytes;
  final String filename;
  final String? sourceId;
  final String? universiteId;
  final String? categorie;
}

class UploadDocument
    implements UseCase<Map<String, dynamic>, UploadDocumentParams> {
  const UploadDocument(this._repository);
  final SourceRepository _repository;

  @override
  Future<Result<Map<String, dynamic>>> call(UploadDocumentParams params) {
    return _repository.uploadDocument(
      bytes: params.bytes,
      filename: params.filename,
      sourceId: params.sourceId,
      universiteId: params.universiteId,
      categorie: params.categorie,
    );
  }
}
