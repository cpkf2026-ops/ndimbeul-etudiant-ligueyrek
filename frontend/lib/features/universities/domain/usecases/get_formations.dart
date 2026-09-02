import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/formation.dart';
import '../entities/paginated_result.dart';
import '../entities/universite.dart';
import '../repositories/formation_repository.dart';

class GetFormationsParams {
  const GetFormationsParams({
    this.domaine,
    this.niveau,
    this.region,
    this.typeEtablissement,
    this.serieBac,
    this.universiteId,
    this.page = 1,
    this.perPage = 20,
  });

  final String? domaine;
  final NiveauFormation? niveau;
  final String? region;
  final EtablissementType? typeEtablissement;
  final String? serieBac;
  final String? universiteId;
  final int page;
  final int perPage;

  GetFormationsParams copyWith({
    String? domaine,
    NiveauFormation? niveau,
    String? region,
    EtablissementType? typeEtablissement,
    String? serieBac,
    String? universiteId,
    int? page,
    int? perPage,
  }) {
    return GetFormationsParams(
      domaine: domaine ?? this.domaine,
      niveau: niveau ?? this.niveau,
      region: region ?? this.region,
      typeEtablissement: typeEtablissement ?? this.typeEtablissement,
      serieBac: serieBac ?? this.serieBac,
      universiteId: universiteId ?? this.universiteId,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }
}

class GetFormations implements UseCase<PaginatedResult<Formation>, GetFormationsParams> {
  const GetFormations(this._repository);
  final FormationRepository _repository;

  @override
  Future<Result<PaginatedResult<Formation>>> call(GetFormationsParams params) {
    return _repository.getFormations(
      domaine: params.domaine,
      niveau: params.niveau,
      region: params.region,
      typeEtablissement: params.typeEtablissement,
      serieBac: params.serieBac,
      universiteId: params.universiteId,
      page: params.page,
      perPage: params.perPage,
    );
  }
}
