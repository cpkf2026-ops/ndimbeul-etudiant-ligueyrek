import 'package:freezed_annotation/freezed_annotation.dart';

part 'logement.freezed.dart';

enum TypeLogement {
  residence,
  foyer,
  partenaire;

  String get label {
    switch (this) {
      case TypeLogement.residence:
        return 'Résidence universitaire';
      case TypeLogement.foyer:
        return 'Foyer étudiant';
      case TypeLogement.partenaire:
        return 'Partenaire privé';
    }
  }
}

/// Solution de logement rattachée à une université (CDC §5.3/§7.3).
@freezed
sealed class Logement with _$Logement {
  const factory Logement({
    required String id,
    required String universiteId,
    required String nom,
    required TypeLogement type,
    int? capacite,
    double? tarifMensuel,
    @Default('XOF') String devise,
    String? contact,
    String? source,
    DateTime? dateMaj,
  }) = _Logement;
}
