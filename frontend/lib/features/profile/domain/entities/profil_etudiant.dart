import 'package:freezed_annotation/freezed_annotation.dart';

part 'profil_etudiant.freezed.dart';

/// Niveau d'étude actuel (CDC — profil étudiant).
enum NiveauEtudiant {
  l1,
  l2,
  l3,
  m1,
  m2,
  doctorat;

  String get label {
    switch (this) {
      case NiveauEtudiant.l1:
        return 'L1';
      case NiveauEtudiant.l2:
        return 'L2';
      case NiveauEtudiant.l3:
        return 'L3';
      case NiveauEtudiant.m1:
        return 'M1';
      case NiveauEtudiant.m2:
        return 'M2';
      case NiveauEtudiant.doctorat:
        return 'Doctorat';
    }
  }
}

/// Profil académique d'un étudiant déjà inscrit dans le supérieur
/// (voir `ProfilEtudiantResource` côté backend).
@freezed
sealed class ProfilEtudiant with _$ProfilEtudiant {
  const factory ProfilEtudiant({
    String? universiteActuelle,
    String? formationActuelle,
    NiveauEtudiant? niveauActuel,
    @Default(<String>[]) List<String> domainesInterets,
    @Default(false) bool rechercheStage,
    @Default(false) bool rechercheEmploi,
  }) = _ProfilEtudiant;
}
