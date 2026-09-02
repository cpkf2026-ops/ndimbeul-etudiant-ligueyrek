/// Conteneur générique pour les réponses paginées de l'API Laravel
/// (`{"data": [...], "meta": {"current_page","last_page","total"}}`).
class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get hasMore => currentPage < lastPage;
}
