import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/profil_etudiant.dart';
import '../repositories/profile_repository.dart';

class UpdateProfilEtudiantParams {
  const UpdateProfilEtudiantParams(this.profil);
  final ProfilEtudiant profil;
}

class UpdateProfilEtudiant
    implements UseCase<ProfilEtudiant, UpdateProfilEtudiantParams> {
  const UpdateProfilEtudiant(this._repository);
  final ProfileRepository _repository;

  @override
  Future<Result<ProfilEtudiant>> call(UpdateProfilEtudiantParams params) =>
      _repository.updateProfilEtudiant(params.profil);
}
