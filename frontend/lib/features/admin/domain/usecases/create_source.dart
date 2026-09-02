import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/source_donnee.dart';
import '../repositories/source_repository.dart';

class CreateSourceParams {
  const CreateSourceParams({
    this.universiteId,
    required this.type,
    required this.urlOuChemin,
    this.categorie,
  });

  final String? universiteId;
  final SourceType type;
  final String urlOuChemin;
  final String? categorie;
}

class CreateSource implements UseCase<SourceDonnee, CreateSourceParams> {
  const CreateSource(this._repository);
  final SourceRepository _repository;

  @override
  Future<Result<SourceDonnee>> call(CreateSourceParams params) {
    return _repository.createSource(
      universiteId: params.universiteId,
      type: params.type,
      urlOuChemin: params.urlOuChemin,
      categorie: params.categorie,
    );
  }
}
