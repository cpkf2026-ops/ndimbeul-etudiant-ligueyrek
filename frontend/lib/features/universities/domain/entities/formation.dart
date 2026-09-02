import 'package:freezed_annotation/freezed_annotation.dart';

part 'formation.freezed.dart';

enum NiveauFormation {
  bts,
  licence,
  master,
  doctorat;

  String get label {
    switch (this) {
      case NiveauFormation.bts:
        return 'BTS';
      case NiveauFormation.licence:
        return 'Licence';
      case NiveauFormation.master:
        return 'Master';
      case NiveauFormation.doctorat:
        return 'Doctorat';
    }
  }
}

/// Formation proposée par une université (CDC §2.2/§7.2).
@freezed
sealed class Formation with _$Formation {
  const factory Formation({
    required String id,
    required String universiteId,
    String? universiteNom,
    required String intitule,
    required String domaine,
    required NiveauFormation niveau,
    int? dureeAnnees,
    List<String>? seriesAcceptees,
    double? moyenneMinimale,
    int? capacite,
    String? prerequis,
    String? debouches,
    @Default(false) bool estFavori,
  }) = _Formation;
}
