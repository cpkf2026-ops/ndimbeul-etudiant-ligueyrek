import 'package:freezed_annotation/freezed_annotation.dart';

part 'actualite.freezed.dart';

/// Catégories d'actualités exposées par le backend (`categorie` en base,
/// voir NewsController::index validation : bourse|concours|evenement|
/// formation|general).
enum CategorieActualite {
  bourse,
  concours,
  evenement,
  formation,
  general;

  String get label => switch (this) {
        CategorieActualite.bourse => 'Bourse',
        CategorieActualite.concours => 'Concours',
        CategorieActualite.evenement => 'Événement',
        CategorieActualite.formation => 'Formation',
        CategorieActualite.general => 'Général',
      };
}

@freezed
sealed class Actualite with _$Actualite {
  const factory Actualite({
    required String id,
    required String titre,
    required String contenu,
    required CategorieActualite categorie,
    String? sourceUrl,
    String? imageUrl,
    required DateTime datePublication,
    String? auteur,
  }) = _Actualite;

  const Actualite._();
}

/// Page de résultats paginés d'actualités (voir NewsController::index meta).
@freezed
sealed class ActualitePage with _$ActualitePage {
  const factory ActualitePage({
    required List<Actualite> items,
    required int currentPage,
    required int lastPage,
    required int total,
  }) = _ActualitePage;

  const ActualitePage._();

  bool get hasMore => currentPage < lastPage;
}
