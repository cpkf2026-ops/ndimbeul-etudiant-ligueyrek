import 'package:freezed_annotation/freezed_annotation.dart';

part 'profil_lyceen.freezed.dart';

/// Préférence public/privé pour la recherche d'établissement (CDC — profil lycéen).
enum PrefEtablissement {
  public,
  prive,
  indifferent;

  String get label {
    switch (this) {
      case PrefEtablissement.public:
        return 'Public';
      case PrefEtablissement.prive:
        return 'Privé';
      case PrefEtablissement.indifferent:
        return 'Indifférent';
    }
  }
}

/// Profil académique d'un lycéen — alimente le moteur de recommandation IA
/// (voir `ProfilLyceenResource` côté backend). `completude` est calculée
/// côté serveur (`calculerCompletude()`), jamais recalculée côté client.
@freezed
sealed class ProfilLyceen with _$ProfilLyceen {
  const factory ProfilLyceen({
    String? serieBac,
    double? moyenneGenerale,
    @Default(<String>[]) List<String> passions,
    @Default(<String>[]) List<String> metiersEnvisages,
    double? budgetMaxAnnuel,
    @Default(false) bool mobilite,
    @Default(PrefEtablissement.indifferent) PrefEtablissement prefPublicPrive,
    String? regionCible,
    int? anneeTerminale,
    @Default(0) int completude,
  }) = _ProfilLyceen;

  const ProfilLyceen._();

  bool get estComplet => completude >= 100;
}
