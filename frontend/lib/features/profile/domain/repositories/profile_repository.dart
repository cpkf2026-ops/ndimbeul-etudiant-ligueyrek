import '../../../../core/utils/result.dart';
import '../entities/profil_academique.dart';
import '../entities/profil_etudiant.dart';
import '../entities/profil_lyceen.dart';

abstract interface class ProfileRepository {
  /// `GET /profile/me` — profil académique de l'utilisateur connecté,
  /// typé selon son rôle (lycéen ou étudiant).
  Future<Result<ProfilAcademique>> getProfile();

  /// `PUT /profile/me` (branche lycéen) — mise à jour partielle.
  Future<Result<ProfilLyceen>> updateProfilLyceen(ProfilLyceen profil);

  /// `PUT /profile/me` (branche étudiant) — mise à jour partielle.
  Future<Result<ProfilEtudiant>> updateProfilEtudiant(ProfilEtudiant profil);
}
