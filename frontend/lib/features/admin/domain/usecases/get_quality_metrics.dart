import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/quality_metrics.dart';
import '../repositories/quality_repository.dart';

class GetQualityMetrics implements UseCase<QualityMetrics, NoParams> {
  const GetQualityMetrics(this._repository);
  final QualityRepository _repository;

  @override
  Future<Result<QualityMetrics>> call(NoParams params) {
    return _repository.getQualityMetrics();
  }
}
