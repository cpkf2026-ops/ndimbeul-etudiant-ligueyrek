import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/recommandation.dart';
import '../repositories/recommendation_repository.dart';

class GetRecommendations implements UseCase<List<Recommandation>, NoParams> {
  const GetRecommendations(this._repository);
  final RecommendationRepository _repository;

  @override
  Future<Result<List<Recommandation>>> call(NoParams params) =>
      _repository.getRecommendations();
}
