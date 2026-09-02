import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/paginated_result.dart';
import '../entities/universite.dart';
import '../repositories/university_repository.dart';

class GetUniversitiesParams {
  const GetUniversitiesParams({
    this.region,
    this.type,
    this.q,
    this.page = 1,
    this.perPage = 20,
  });

  final String? region;
  final EtablissementType? type;
  final String? q;
  final int page;
  final int perPage;

  GetUniversitiesParams copyWith({
    String? region,
    EtablissementType? type,
    String? q,
    int? page,
    int? perPage,
  }) {
    return GetUniversitiesParams(
      region: region ?? this.region,
      type: type ?? this.type,
      q: q ?? this.q,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }
}

class GetUniversities implements UseCase<PaginatedResult<Universite>, GetUniversitiesParams> {
  const GetUniversities(this._repository);
  final UniversityRepository _repository;

  @override
  Future<Result<PaginatedResult<Universite>>> call(GetUniversitiesParams params) {
    return _repository.getUniversities(
      region: params.region,
      type: params.type,
      q: params.q,
      page: params.page,
      perPage: params.perPage,
    );
  }
}
