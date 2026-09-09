import 'package:freezed_annotation/freezed_annotation.dart';
import 'profil_diplome.dart';
import 'profil_etudiant.dart';
import 'profil_lyceen.dart';

part 'profil_academique.freezed.dart';

/// Union du profil académique retourné par `GET /profile/me` — le rôle de
/// l'utilisateur connecté (voir `authProvider`) détermine laquelle des trois
/// variantes est active, à l'image de `UtilisateurResource::profil` côté
/// backend (`ProfilLyceenResource`, `ProfilEtudiantResource` ou `ProfilDiplomeResource`).
@freezed
sealed class ProfilAcademique with _$ProfilAcademique {
  const factory ProfilAcademique.lyceen(ProfilLyceen profil) =
      ProfilAcademiqueLyceen;
  const factory ProfilAcademique.etudiant(ProfilEtudiant profil) =
      ProfilAcademiqueEtudiant;
  const factory ProfilAcademique.diplome(ProfilDiplome profil) =
      ProfilAcademiqueDiplome;
}
