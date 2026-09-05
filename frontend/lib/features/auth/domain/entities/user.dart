import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

enum UserRole {
  lyceen,
  etudiant,
  diplome,
  adminEtablissement,
  superAdmin;

  String get label {
    switch (this) {
      case UserRole.lyceen:
        return 'Lycéen';
      case UserRole.etudiant:
        return 'Étudiant';
      case UserRole.diplome:
        return 'Diplômé / En poste / En stage';
      case UserRole.adminEtablissement:
        return 'Admin établissement';
      case UserRole.superAdmin:
        return 'Super Admin';
    }
  }

  bool get isAdmin =>
      this == UserRole.adminEtablissement || this == UserRole.superAdmin;

  /// Le module Orientation (recommandations, simulation de bac) ne concerne
  /// que les profils encore en cours d'études — voir plan "Séparation
  /// inscription / complétion de profil" §4.
  bool get voitOrientation => this == UserRole.lyceen || this == UserRole.etudiant;
}

@freezed
sealed class User with _$User {
  const factory User({
    required String id,
    required String nom,
    required String prenom,
    required String email,
    // Null tant que l'utilisateur n'a pas complété son profil (choix du
    // statut) — voir profilComplete et CompleteProfileScreen.
    UserRole? role,
    String? region,
    @Default(false) bool profilComplete,
    required DateTime dateInscription,
  }) = _User;

  const User._();

  String get nomComplet => '$prenom $nom';
  String get initiale => prenom.isNotEmpty ? prenom[0].toUpperCase() : '?';
}
