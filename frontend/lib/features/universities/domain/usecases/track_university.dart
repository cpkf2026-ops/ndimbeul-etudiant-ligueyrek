import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/university_repository.dart';

class TrackUniversityParams {
  const TrackUniversityParams({required this.id, required this.statut});

  final String id;

  /// ∈ {suggeree, consultee, comparee}.
  final String statut;
}

class TrackUniversity implements UseCase<void, TrackUniversityParams> {
  const TrackUniversity(this._repository);
  final UniversityRepository _repository;

  @override
  Future<Result<void>> call(TrackUniversityParams params) =>
      _repository.trackUniversity(id: params.id, statut: params.statut);
}
