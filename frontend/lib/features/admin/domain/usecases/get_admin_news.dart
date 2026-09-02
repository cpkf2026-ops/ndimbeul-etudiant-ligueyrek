import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/actualite_admin.dart';
import '../repositories/admin_news_repository.dart';

class GetAdminNews implements UseCase<List<ActualiteAdmin>, NoParams> {
  const GetAdminNews(this._repository);
  final AdminNewsRepository _repository;

  @override
  Future<Result<List<ActualiteAdmin>>> call(NoParams params) {
    return _repository.getNews();
  }
}
