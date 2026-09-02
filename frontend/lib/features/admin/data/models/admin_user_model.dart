import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/admin_user.dart';

part 'admin_user_model.freezed.dart';
part 'admin_user_model.g.dart';

UserRole _roleFromJson(String value) {
  switch (value) {
    case 'lyceen':
      return UserRole.lyceen;
    case 'etudiant':
      return UserRole.etudiant;
    case 'admin_etablissement':
      return UserRole.adminEtablissement;
    case 'super_admin':
      return UserRole.superAdmin;
    default:
      return UserRole.etudiant;
  }
}

String _roleToJson(UserRole role) {
  switch (role) {
    case UserRole.lyceen:
      return 'lyceen';
    case UserRole.etudiant:
      return 'etudiant';
    case UserRole.adminEtablissement:
      return 'admin_etablissement';
    case UserRole.superAdmin:
      return 'super_admin';
  }
}

UserStatut _statutFromJson(String? value) =>
    value == 'suspendu' ? UserStatut.suspendu : UserStatut.actif;

String _statutToJson(UserStatut statut) => statut.name;

/// Miroir de `UtilisateurResource` tel qu'exposé au back-office
/// (`GET /admin/users`) — pas d'enveloppe `profil` exploitée ici.
@freezed
sealed class AdminUserModel with _$AdminUserModel {
  const factory AdminUserModel({
    required String id,
    required String nom,
    required String prenom,
    required String email,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _roleFromJson, toJson: _roleToJson)
    required UserRole role,
    String? region,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _statutFromJson, toJson: _statutToJson)
    @Default(UserStatut.actif)
    UserStatut statut,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'date_inscription') DateTime? dateInscription,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'date_derniere_connexion') DateTime? dateDerniereConnexion,
  }) = _AdminUserModel;

  const AdminUserModel._();

  factory AdminUserModel.fromJson(Map<String, dynamic> json) =>
      _$AdminUserModelFromJson(json);

  AdminUser toEntity() => AdminUser(
    id: id,
    nom: nom,
    prenom: prenom,
    email: email,
    role: role,
    region: region,
    statut: statut,
    dateInscription: dateInscription,
    dateDerniereConnexion: dateDerniereConnexion,
  );
}
