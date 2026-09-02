import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/profil_lyceen.dart';
import '../repositories/profile_repository.dart';

class UpdateProfilLyceenParams {
  const UpdateProfilLyceenParams(this.profil);
  final ProfilLyceen profil;
}

class UpdateProfilLyceen
    implements UseCase<ProfilLyceen, UpdateProfilLyceenParams> {
  const UpdateProfilLyceen(this._repository);
  final ProfileRepository _repository;

  @override
  Future<Result<ProfilLyceen>> call(UpdateProfilLyceenParams params) =>
      _repository.updateProfilLyceen(params.profil);
}
