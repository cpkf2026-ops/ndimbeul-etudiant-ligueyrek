import 'package:freezed_annotation/freezed_annotation.dart';
import 'bourse.dart';
import 'formation.dart';
import 'frais_scolarite.dart';
import 'logement.dart';

part 'universite.freezed.dart';

enum EtablissementType {
  public,
  prive;

  String get label {
    switch (this) {
      case EtablissementType.public:
        return 'Public';
      case EtablissementType.prive:
        return 'Privé';
    }
  }
}

/// Université / établissement d'enseignement supérieur (CDC §2.2/§5.3/§7.3).
@freezed
sealed class Universite with _$Universite {
  const factory Universite({
    required String id,
    required String nom,
    required String codeUnique,
    String? region,
    String? commune,
    required EtablissementType type,
    String? siteWebOfficiel,
    String? description,
    String? imageUrl,
    String? emailContact,
    String? telephoneContact,
    @Default([]) List<Formation> formations,
    @Default([]) List<Bourse> bourses,
    @Default([]) List<Logement> logements,
    @Default([]) List<FraisScolarite> fraisScolarite,
  }) = _Universite;

  const Universite._();

  String get localisation =>
      [commune, region].where((s) => s != null && s.isNotEmpty).join(', ');
}
