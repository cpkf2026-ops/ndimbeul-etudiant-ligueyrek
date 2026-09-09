import 'package:freezed_annotation/freezed_annotation.dart';

part 'profil_diplome.freezed.dart';

/// Situation professionnelle actuelle (CDC — profil diplômé/en poste/en stage).
enum SituationActuelle {
  enPoste,
  rechercheEmploi,
  stage;

  String get label {
    switch (this) {
      case SituationActuelle.enPoste:
        return 'En poste';
      case SituationActuelle.rechercheEmploi:
        return 'En recherche d\'emploi';
      case SituationActuelle.stage:
        return 'En stage';
    }
  }
}

/// Profil d'un utilisateur déjà diplômé (voir `ProfilDiplomeResource` côté backend).
@freezed
sealed class ProfilDiplome with _$ProfilDiplome {
  const factory ProfilDiplome({
    String? dernierDiplome,
    String? domaine,
    SituationActuelle? situationActuelle,
    String? entreprise,
  }) = _ProfilDiplome;
}
