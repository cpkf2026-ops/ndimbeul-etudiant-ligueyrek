import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/actualite.dart';
import '../repositories/news_repository.dart';

class GetActualitesParams {
  const GetActualitesParams({this.categorie, this.page = 1, this.perPage = 10});
  final CategorieActualite? categorie;
  final int page;
  final int perPage;
}

class GetActualites implements UseCase<ActualitePage, GetActualitesParams> {
  const GetActualites(this._repository);
  final NewsRepository _repository;

  @override
  Future<Result<ActualitePage>> call(GetActualitesParams params) {
    return _repository.getActualites(
      categorie: params.categorie,
      page: params.page,
      perPage: params.perPage,
    );
  }
}
