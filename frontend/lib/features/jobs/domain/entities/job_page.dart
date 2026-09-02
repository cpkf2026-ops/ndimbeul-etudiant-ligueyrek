import 'package:freezed_annotation/freezed_annotation.dart';
import 'offre_emploi.dart';

part 'job_page.freezed.dart';

/// Page paginée d'offres — reflète l'enveloppe `{"data": [...], "meta": {...}}`
/// renvoyée par `GET /jobs`.
@freezed
sealed class JobPage with _$JobPage {
  const factory JobPage({
    required List<OffreEmploi> items,
    required int currentPage,
    required int lastPage,
    required int total,
  }) = _JobPage;

  const JobPage._();

  bool get hasMore => currentPage < lastPage;
}
