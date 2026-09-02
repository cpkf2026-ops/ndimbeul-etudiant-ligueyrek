import 'package:freezed_annotation/freezed_annotation.dart';

part 'source_donnee.freezed.dart';

/// Type de source de veille IA — reflète la contrainte
/// `in:url,pdf,api` de `StoreSourceDonneeRequest` (backend).
enum SourceType {
  url,
  pdf,
  api;

  String get label {
    switch (this) {
      case SourceType.url:
        return 'Site web';
      case SourceType.pdf:
        return 'Document PDF';
      case SourceType.api:
        return 'API';
    }
  }
}

/// Statut de crawl d'une source — valeurs backend `actif|erreur|obsolete`
/// (colonne `statut` de `sources_donnees`).
enum SourceStatut {
  actif,
  erreur,
  obsolete;

  String get label {
    switch (this) {
      case SourceStatut.actif:
        return 'Actif';
      case SourceStatut.erreur:
        return 'En erreur';
      case SourceStatut.obsolete:
        return 'Obsolète';
    }
  }
}

/// Source de données alimentant la veille IA (RAG) — gérée par les admins
/// d'établissement / super admins (UC12, `SourceDonneeResource`).
@freezed
sealed class SourceDonnee with _$SourceDonnee {
  const factory SourceDonnee({
    required String id,
    String? universiteId,
    required SourceType type,
    required String urlOuChemin,
    String? categorie,
    required SourceStatut statut,
    String? derniereErreur,
    DateTime? dateDernierCrawl,
  }) = _SourceDonnee;

  const SourceDonnee._();
}
