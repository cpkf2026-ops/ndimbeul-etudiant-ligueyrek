import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/profil_academique.dart';
import '../repositories/profile_repository.dart';

class GetProfile implements UseCase<ProfilAcademique, NoParams> {
  const GetProfile(this._repository);
  final ProfileRepository _repository;

  @override
  Future<Result<ProfilAcademique>> call(NoParams params) =>
      _repository.getProfile();
}
