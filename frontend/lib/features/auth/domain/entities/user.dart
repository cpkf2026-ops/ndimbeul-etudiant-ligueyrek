import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

enum UserRole {
  lyceen,
  etudiant,
  adminEtablissement,
  superAdmin;

  String get label {
    switch (this) {
      case UserRole.lyceen:
        return 'Lycéen';
      case UserRole.etudiant:
        return 'Étudiant';
      case UserRole.adminEtablissement:
        return 'Admin établissement';
      case UserRole.superAdmin:
        return 'Super Admin';
    }
  }

  bool get isAdmin =>
      this == UserRole.adminEtablissement || this == UserRole.superAdmin;
}

@freezed
sealed class User with _$User {
  const factory User({
    required String id,
    required String nom,
    required String prenom,
    required String email,
    required UserRole role,
    String? region,
    required DateTime dateInscription,
  }) = _User;

  const User._();

  String get nomComplet => '$prenom $nom';
  String get initiale => prenom.isNotEmpty ? prenom[0].toUpperCase() : '?';
}
