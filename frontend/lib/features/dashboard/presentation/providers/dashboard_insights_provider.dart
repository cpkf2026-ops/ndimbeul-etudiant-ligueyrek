import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../jobs/domain/entities/offre_emploi.dart';
import '../../../jobs/domain/usecases/get_jobs.dart';
import '../../../jobs/presentation/providers/job_provider.dart';
import '../../../news/domain/entities/actualite.dart';
import '../../../news/domain/usecases/get_actualites.dart';
import '../../../news/presentation/providers/news_provider.dart';
import '../widgets/logement_officiel.dart';

/// Une ligne du calendrier de l'accueil : soit une DATE LIMITE vérifiée (écrite
/// dans l'annonce, voir la veille IA), soit une annonce récente de concours ou
/// de bourse (date de publication réelle).
class Echeance {
  const Echeance({
    required this.titre,
    required this.source,
    required this.date,
    required this.estDateLimite,
    this.offreId,
    this.url,
  });

  final String titre;
  final String source;
  final DateTime date;

  /// true : date limite de candidature ; false : date de publication.
  final bool estDateLimite;
  final String? offreId;
  final String? url;
}

/// Nombre d'offres actives d'un type (Emploi, Stage, Concours…) et ses
/// domaines les plus fréquents.
class TendanceOffres {
  const TendanceOffres({
    required this.type,
    required this.nombre,
    required this.domaines,
  });
  final JobType type;
  final int nombre;
  final List<String> domaines;
}

class DashboardInsights {
  const DashboardInsights({
    required this.echeances,
    required this.tendances,
    required this.nbOffres,
    required this.infosLogement,
  });

  final List<Echeance> echeances;
  final List<TendanceOffres> tendances;
  final int nbOffres;

  /// Actualités récentes sur le logement étudiant (codification, cités
  /// universitaires…), trouvées par la veille IA.
  final List<Actualite> infosLogement;
}

/// Données RÉELLES des cartes « Échéances » et « Où ça recrute » de l'accueil,
/// calculées à partir des offres et actualités collectées toutes les 2 h par la
/// veille IA (aucune donnée inventée). Se recharge comme les fils (15 min).
final dashboardInsightsProvider = FutureProvider<DashboardInsights>((
  ref,
) async {
  final minuteur = Timer(kRafraichissementFils, ref.invalidateSelf);
  ref.onDispose(minuteur.cancel);

  final resultatOffres = await ref
      .read(getJobsUseCaseProvider)
      .call(const GetJobsParams(perPage: 100));
  final resultatActus = await ref
      .read(getActualitesUseCaseProvider)
      .call(const GetActualitesParams(perPage: 60));

  final offres = resultatOffres.fold(
    (_) => <OffreEmploi>[],
    (page) => page.items,
  );
  final actus = resultatActus.fold((_) => <Actualite>[], (page) => page.items);
  final maintenant = DateTime.now();
  final aujourdHui = DateTime(
    maintenant.year,
    maintenant.month,
    maintenant.day,
  );

  // 1. Dates limites vérifiées, de la plus proche à la plus lointaine.
  final dateLimites =
      offres
          .where(
            (o) =>
                !o.expiree &&
                o.dateLimite != null &&
                !o.dateLimite!.isBefore(aujourdHui),
          )
          .map(
            (o) => Echeance(
              titre: o.intitule,
              source: o.source ?? o.entreprise,
              date: o.dateLimite!,
              estDateLimite: true,
              offreId: o.id,
            ),
          )
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  // 2. Annonces récentes (moins de 21 jours) : actualités de concours, de
  // bourses et d'événements (rentrée, salons, portes ouvertes…), puis offres
  // de type concours ou bourse — toutes avec leur date de publication réelle.
  const categoriesAgenda = {
    CategorieActualite.concours,
    CategorieActualite.bourse,
    CategorieActualite.evenement,
  };
  final annonces = [
    ...actus
        .where(
          (a) =>
              categoriesAgenda.contains(a.categorie) &&
              maintenant.difference(a.datePublication).inDays <= 21,
        )
        .map(
          (a) => Echeance(
            titre: a.titre,
            source: a.auteur ?? 'Presse',
            date: a.datePublication,
            estDateLimite: false,
            url: a.sourceUrl,
          ),
        ),
    ...offres
        .where(
          (o) =>
              !o.expiree &&
              o.dateLimite == null &&
              (o.type == JobType.concours || o.type == JobType.bourse) &&
              o.datePublication != null &&
              maintenant.difference(o.datePublication!).inDays <= 21,
        )
        .map(
          (o) => Echeance(
            titre: o.intitule,
            source: o.source ?? o.entreprise,
            date: o.datePublication!,
            estDateLimite: false,
            offreId: o.id,
          ),
        ),
  ]..sort((a, b) => b.date.compareTo(a.date));

  // 3. Offres actives par type, avec leurs domaines les plus fréquents.
  final parType = <JobType, List<OffreEmploi>>{};
  for (final o in offres.where((o) => !o.expiree)) {
    parType.putIfAbsent(o.type, () => []).add(o);
  }
  final tendances = parType.entries.map((e) {
    final compte = <String, int>{};
    for (final o in e.value) {
      final d = o.domaine.trim();
      if (d.isNotEmpty && !d.toLowerCase().startsWith('non pr')) {
        compte[d] = (compte[d] ?? 0) + 1;
      }
    }
    final domaines =
        (compte.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
            .take(2)
            .map((d) => d.key)
            .toList();
    return TendanceOffres(
      type: e.key,
      nombre: e.value.length,
      domaines: domaines,
    );
  }).toList()..sort((a, b) => b.nombre.compareTo(a.nombre));

  // 4. Actualités sur le logement étudiant (moins de 60 jours).
  bool parleDeLogement(Actualite a) {
    final texte = '${a.titre} ${a.contenu}'.toLowerCase();
    return kMotsClesLogement.any(texte.contains);
  }

  final infosLogement =
      actus
          .where(
            (a) =>
                parleDeLogement(a) &&
                maintenant.difference(a.datePublication).inDays <= 60,
          )
          .toList()
        ..sort((a, b) => b.datePublication.compareTo(a.datePublication));

  return DashboardInsights(
    echeances: [...dateLimites, ...annonces].take(4).toList(),
    tendances: tendances.take(5).toList(),
    nbOffres: offres.where((o) => !o.expiree).length,
    infosLogement: infosLogement.take(3).toList(),
  );
});
