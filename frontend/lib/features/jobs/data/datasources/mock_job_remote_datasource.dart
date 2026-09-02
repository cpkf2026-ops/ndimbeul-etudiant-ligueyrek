import '../../domain/entities/offre_emploi.dart';
import '../models/offre_emploi_model.dart';
import 'job_remote_datasource.dart';

/// Jeu de données mocké — offres réalistes d'entreprises sénégalaises
/// (voir §10 : `--dart-define=USE_MOCK=true`).
class MockJobRemoteDataSource implements JobRemoteDataSource {
  static final List<OffreEmploiModel> _jobs = [
    OffreEmploiModel(
      id: 'job_1',
      intitule: 'Développeur Flutter Junior',
      entreprise: 'Sonatel Digital',
      type: JobType.emploi,
      domaine: 'Informatique',
      niveauRequis: 'Bac+3',
      region: 'Dakar',
      description:
          'Rejoignez l\'équipe mobile de Sonatel Digital pour développer les applications '
          'grand public (Orange Money, Sonatel App). Vous travaillerez avec Flutter, Riverpod '
          'et une architecture Clean Architecture au sein d\'une équipe agile.',
      sourceUrl: 'https://www.sonatel.sn/carrieres',
      source: 'Sonatel Carrières',
      datePublication: DateTime(2026, 8, 1),
      dateLimite: DateTime(2026, 9, 15),
      statut: 'active',
      estFavori: true,
    ),
    OffreEmploiModel(
      id: 'job_2',
      intitule: 'Stage Ingénieur Réseaux',
      entreprise: 'Orange Sénégal',
      type: JobType.stage,
      domaine: 'Télécommunications',
      niveauRequis: 'Bac+4',
      region: 'Dakar',
      description:
          'Stage de fin d\'études de 6 mois au sein de la direction technique. '
          'Participation au déploiement et à la supervision du réseau 4G/5G.',
      sourceUrl: 'https://www.orange.sn/stages',
      source: 'Orange Sénégal',
      datePublication: DateTime(2026, 7, 20),
      dateLimite: DateTime(2026, 9, 1),
      statut: 'active',
    ),
    OffreEmploiModel(
      id: 'job_3',
      intitule: 'Alternance Comptabilité',
      entreprise: 'SGBS — Société Générale',
      type: JobType.alternance,
      domaine: 'Finance',
      niveauRequis: 'Bac+2',
      region: 'Dakar',
      description:
          'Contrat d\'alternance de 12 mois au sein du service comptabilité générale. '
          'Formation continue assurée en partenariat avec l\'ISEP Diamniadio.',
      sourceUrl: 'https://www.societegenerale.sn/carrieres',
      source: 'SGBS Carrières',
      datePublication: DateTime(2026, 7, 10),
      dateLimite: DateTime(2026, 8, 25),
      statut: 'active',
    ),
    OffreEmploiModel(
      id: 'job_4',
      intitule: 'Bourse d\'excellence Ingénierie',
      entreprise: 'Fondation SenElec',
      type: JobType.bourse,
      domaine: 'Énergie',
      niveauRequis: 'Bac',
      region: 'Toutes régions',
      description:
          'Bourse annuelle destinée aux bacheliers scientifiques souhaitant intégrer une '
          'école d\'ingénieur en énergie/électrotechnique. Prise en charge frais de scolarité '
          'et logement.',
      sourceUrl: 'https://www.senelec.sn/fondation',
      source: 'Fondation SenElec',
      datePublication: DateTime(2026, 6, 15),
      dateLimite: DateTime(2026, 8, 30),
      statut: 'active',
      estFavori: true,
    ),
    OffreEmploiModel(
      id: 'job_5',
      intitule: 'Formation courte — Data Analyst',
      entreprise: 'Orange Digital Center',
      type: JobType.formation,
      domaine: 'Informatique',
      niveauRequis: 'Bac+2',
      region: 'Dakar',
      description:
          'Formation intensive de 3 mois (Excel avancé, SQL, Power BI) avec certification '
          'et mise en relation avec les entreprises partenaires.',
      sourceUrl: 'https://www.orangedigitalcenter.sn',
      source: 'Orange Digital Center',
      datePublication: DateTime(2026, 5, 1),
      dateLimite: DateTime(2026, 6, 1),
      statut: 'expiree',
      expiree: true,
    ),
    OffreEmploiModel(
      id: 'job_6',
      intitule: 'Stage Marketing Digital',
      entreprise: 'Auchan Sénégal',
      type: JobType.stage,
      domaine: 'Marketing',
      niveauRequis: 'Bac+3',
      region: 'Thiès',
      description:
          'Stage de 4 mois au sein de l\'équipe communication digitale. Gestion des réseaux '
          'sociaux et campagnes publicitaires locales.',
      sourceUrl: 'https://www.auchan.sn/carrieres',
      source: 'Auchan Sénégal',
      datePublication: DateTime(2026, 8, 5),
      dateLimite: DateTime(2026, 9, 20),
      statut: 'active',
    ),
    OffreEmploiModel(
      id: 'job_7',
      intitule: 'Développeur Backend Laravel',
      entreprise: 'Wave Mobile Money',
      type: JobType.emploi,
      domaine: 'Informatique',
      niveauRequis: 'Bac+4',
      region: 'Dakar',
      description:
          'Développement et maintenance des API de la plateforme Wave. Stack PHP/Laravel, '
          'MySQL, Redis. Télétravail partiel possible.',
      sourceUrl: 'https://www.wave.com/carrieres',
      source: 'Wave Careers',
      datePublication: DateTime(2026, 8, 10),
      dateLimite: DateTime(2026, 10, 1),
      statut: 'active',
    ),
  ];

  @override
  Future<JobListPageModel> list({
    String? domaine,
    String? region,
    JobType? type,
    String? niveauRequis,
    DateTime? dateLimiteAvant,
    int page = 1,
    int perPage = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var filtered = _jobs.where((j) {
      if (domaine != null && j.domaine != domaine) return false;
      if (region != null && j.region != region) return false;
      if (type != null && j.type != type) return false;
      if (niveauRequis != null && j.niveauRequis != niveauRequis) return false;
      if (dateLimiteAvant != null &&
          j.dateLimite != null &&
          j.dateLimite!.isAfter(dateLimiteAvant)) {
        return false;
      }
      return true;
    }).toList();

    final start = ((page - 1) * perPage).clamp(0, filtered.length);
    final end = (start + perPage).clamp(0, filtered.length);
    final pageItems = filtered.sublist(start, end);

    return (
      items: pageItems,
      currentPage: page,
      lastPage: (filtered.length / perPage).ceil().clamp(1, 999),
      total: filtered.length,
    );
  }

  @override
  Future<OffreEmploiModel> detail(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _jobs.firstWhere(
      (j) => j.id == id,
      orElse: () => throw StateError('Offre introuvable'),
    );
  }

  @override
  Future<List<OffreEmploiModel>> favorites() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _jobs.where((j) => j.estFavori == true).toList();
  }

  @override
  Future<void> favorite(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _jobs.indexWhere((j) => j.id == id);
    if (index != -1) _jobs[index] = _jobs[index].copyWith(estFavori: true);
  }

  @override
  Future<void> unfavorite(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _jobs.indexWhere((j) => j.id == id);
    if (index != -1) _jobs[index] = _jobs[index].copyWith(estFavori: false);
  }
}
