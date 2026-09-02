/// Paramètre partagé par les UseCase qui n'opèrent que sur un identifiant
/// d'offre (détail, favori, retrait des favoris).
class JobIdParams {
  const JobIdParams(this.id);
  final String id;
}
