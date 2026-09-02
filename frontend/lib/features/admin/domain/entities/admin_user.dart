import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../auth/domain/entities/user.dart';

part 'admin_user.freezed.dart';

/// Statut de compte — colonne `statut` de `utilisateurs` (`actif|suspendu`).
enum UserStatut {
  actif,
  suspendu;

  String get label => this == UserStatut.actif ? 'Actif' : 'Suspendu';
}

/// Utilisateur tel que vu par le back-office (UC14, `UtilisateurResource`).
/// Réutilise [UserRole] de la feature auth (lecture seule autorisée).
@freezed
sealed class AdminUser with _$AdminUser {
  const factory AdminUser({
    required String id,
    required String nom,
    required String prenom,
    required String email,
    required UserRole role,
    String? region,
    required UserStatut statut,
    DateTime? dateInscription,
    DateTime? dateDerniereConnexion,
  }) = _AdminUser;

  const AdminUser._();

  String get nomComplet => '$prenom $nom';
}
