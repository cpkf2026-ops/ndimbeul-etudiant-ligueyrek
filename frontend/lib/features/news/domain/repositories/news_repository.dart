import '../../../../core/utils/result.dart';
import '../entities/actualite.dart';

abstract interface class NewsRepository {
  Future<Result<ActualitePage>> getActualites({
    CategorieActualite? categorie,
    int page = 1,
    int perPage = 10,
  });

  Future<Result<Actualite>> getActualiteDetail(String id);
}
