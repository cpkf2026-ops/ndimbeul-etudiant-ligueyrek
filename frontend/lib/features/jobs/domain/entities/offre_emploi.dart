import 'package:freezed_annotation/freezed_annotation.dart';

part 'offre_emploi.freezed.dart';

/// Type d'offre — reflète l'enum validée côté Laravel
/// (`in:emploi,stage,alternance,formation,bourse`).
enum JobType {
  emploi,
  stage,
  alternance,
  formation,
  bourse;

  String get label {
    switch (this) {
      case JobType.emploi:
        return 'Emploi';
      case JobType.stage:
        return 'Stage';
      case JobType.alternance:
        return 'Alternance';
      case JobType.formation:
        return 'Formation';
      case JobType.bourse:
        return 'Bourse';
    }
  }
}

@freezed
sealed class OffreEmploi with _$OffreEmploi {
  const factory OffreEmploi({
    required String id,
    required String intitule,
    required String entreprise,
    required JobType type,
    required String domaine,
    String? niveauRequis,
    required String region,
    required String description,
    String? sourceUrl,
    String? source,
    DateTime? datePublication,
    DateTime? dateLimite,
    required String statut,
    @Default(false) bool expiree,
    @Default(false) bool estFavori,
  }) = _OffreEmploi;

  const OffreEmploi._();
}
