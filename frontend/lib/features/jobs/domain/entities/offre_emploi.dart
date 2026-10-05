import 'package:freezed_annotation/freezed_annotation.dart';

part 'offre_emploi.freezed.dart';

/// Type d'offre — reflète l'enum validée côté Laravel
/// (`in:emploi,stage,alternance,formation,bourse`).
enum JobType {
  emploi,
  stage,
  alternance,
  formation,
  bourse,
  concours;

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
      case JobType.concours:
        return 'Concours';
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
    /// Fiabilité de la source vérifiée par la veille IA : 'officiel', 'presse'
    /// ou 'plateforme' (null pour les données de démonstration).
    String? fiabilite,
    DateTime? datePublication,
    DateTime? dateLimite,
    DateTime? dateIndexation,
    required String statut,
    @Default(false) bool expiree,
    @Default(false) bool estFavori,
  }) = _OffreEmploi;

  const OffreEmploi._();

  bool get sourceVerifiee => fiabilite != null;
  bool get sourceOfficielle => fiabilite == 'officiel';
}
