import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/profil_diplome.dart';
import '../repositories/profile_repository.dart';

class UpdateProfilDiplomeParams {
  const UpdateProfilDiplomeParams(this.profil);
  final ProfilDiplome profil;
}

class UpdateProfilDiplome
    implements UseCase<ProfilDiplome, UpdateProfilDiplomeParams> {
  const UpdateProfilDiplome(this._repository);
  final ProfileRepository _repository;

  @override
  Future<Result<ProfilDiplome>> call(UpdateProfilDiplomeParams params) =>
      _repository.updateProfilDiplome(params.profil);
}
