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
    // Null = statut non vérifié (aucune source officielle) : on n'affiche alors rien.
    EtablissementType? type,
    String? siteWebOfficiel,
    String? description,
    String? imageUrl,
    String? emailContact,
    String? telephoneContact,
    String? adresse,
    // Fiche enrichie (infos publiques collectées par le service IA, surtout pour les
    // établissements sans site officiel) + page d'où elles viennent.
    @Default([]) List<String> domaines,
    @Default([]) List<String> diplomes,
    String? admission,
    @Default([]) List<String> niveauRequis,
    @Default([]) List<String> piecesAFournir,
    String? sourceInfos,
    @Default([]) List<Formation> formations,
    @Default([]) List<Bourse> bourses,
    @Default([]) List<Logement> logements,
    @Default([]) List<FraisScolarite> fraisScolarite,
  }) = _Universite;

  const Universite._();

  /// « Point E, Dakar » ; « Dakar » (et non « Dakar, Dakar ») quand seule la ville est connue.
  String get localisation => [commune, region]
      .where((s) => s != null && s.isNotEmpty)
      .toSet()
      .join(', ');
}
