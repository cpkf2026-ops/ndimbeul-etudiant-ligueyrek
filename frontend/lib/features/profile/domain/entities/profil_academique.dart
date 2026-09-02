import 'package:freezed_annotation/freezed_annotation.dart';
import 'profil_etudiant.dart';
import 'profil_lyceen.dart';

part 'profil_academique.freezed.dart';

/// Union du profil académique retourné par `GET /profile/me` — le rôle de
/// l'utilisateur connecté (voir `authProvider`) détermine laquelle des deux
/// variantes est active, à l'image de `UtilisateurResource::profil` côté
/// backend (`ProfilLyceenResource` ou `ProfilEtudiantResource`).
@freezed
sealed class ProfilAcademique with _$ProfilAcademique {
  const factory ProfilAcademique.lyceen(ProfilLyceen profil) =
      ProfilAcademiqueLyceen;
  const factory ProfilAcademique.etudiant(ProfilEtudiant profil) =
      ProfilAcademiqueEtudiant;
}
