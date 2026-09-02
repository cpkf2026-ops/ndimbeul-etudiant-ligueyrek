import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/source_donnee.dart';
import '../repositories/source_repository.dart';

class UpdateSourceParams {
  const UpdateSourceParams({
    required this.id,
    this.universiteId,
    required this.type,
    required this.urlOuChemin,
    this.categorie,
  });

  final String id;
  final String? universiteId;
  final SourceType type;
  final String urlOuChemin;
  final String? categorie;
}

class UpdateSource implements UseCase<SourceDonnee, UpdateSourceParams> {
  const UpdateSource(this._repository);
  final SourceRepository _repository;

  @override
  Future<Result<SourceDonnee>> call(UpdateSourceParams params) {
    return _repository.updateSource(
      id: params.id,
      universiteId: params.universiteId,
      type: params.type,
      urlOuChemin: params.urlOuChemin,
      categorie: params.categorie,
    );
  }
}
