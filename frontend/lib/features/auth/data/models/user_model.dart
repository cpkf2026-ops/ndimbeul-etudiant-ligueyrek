import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

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

@freezed
sealed class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String nom,
    required String prenom,
    required String email,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _roleFromJson, toJson: _roleToJson) required UserRole role,
    String? region,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'date_inscription') required DateTime dateInscription,
  }) = _UserModel;

  const UserModel._();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  User toEntity() => User(
        id: id,
        nom: nom,
        prenom: prenom,
        email: email,
        role: role,
        region: region,
        dateInscription: dateInscription,
      );
}
