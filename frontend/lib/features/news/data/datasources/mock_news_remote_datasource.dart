import '../../../../shared/constants/app_images.dart';
import '../../domain/entities/actualite.dart';
import '../models/actualite_model.dart';
import 'news_remote_datasource.dart';

/// Jeu de données mocké — actualités réalistes de l'écosystème étudiant
/// sénégalais (voir §10).
class MockNewsRemoteDataSource implements NewsRemoteDataSource {
  static final List<ActualiteModel> _actualites = [
    ActualiteModel(
      id: 'news_1',
      titre: 'Ouverture des inscriptions CAMPUSEN 2026-2027',
      contenu:
          'Le portail national d\'orientation CAMPUSEN ouvre ses inscriptions pour la '
          'prochaine rentrée universitaire. Les bacheliers 2026 peuvent dès à présent '
          'saisir leurs vœux d\'orientation en ligne jusqu\'au 15 septembre.',
      categorie: CategorieActualite.formation,
      imageUrl: AppImages.etudiantsGroupe,
      datePublication: DateTime(2026, 8, 10),
      auteur: 'Ministère de l\'Enseignement supérieur',
    ),
    ActualiteModel(
      id: 'news_2',
      titre: 'Nouvelles bourses d\'excellence pour les filières scientifiques',
      contenu:
          'Le gouvernement annonce 500 nouvelles bourses destinées aux bacheliers '
          'scientifiques (séries S) souhaitant intégrer une filière STEM. Dossiers à '
          'déposer avant fin septembre auprès de la Direction des Bourses.',
      categorie: CategorieActualite.bourse,
      imageUrl: AppImages.boursesEtude,
      datePublication: DateTime(2026, 8, 5),
      auteur: 'DBFC',
    ),
    ActualiteModel(
      id: 'news_3',
      titre: 'Journée portes ouvertes UCAD — 20 septembre 2026',
      contenu:
          'L\'Université Cheikh Anta Diop organise sa traditionnelle journée portes '
          'ouvertes pour présenter ses filières, laboratoires et associations '
          'étudiantes aux futurs bacheliers.',
      categorie: CategorieActualite.evenement,
      imageUrl: AppImages.amphi,
      datePublication: DateTime(2026, 8, 1),
      auteur: 'UCAD Communication',
    ),
    ActualiteModel(
      id: 'news_4',
      titre: 'Concours d\'entrée à l\'ESP : dates fixées',
      contenu:
          'Le concours d\'entrée en première année à l\'École Supérieure Polytechnique '
          'de Dakar se tiendra le 12 octobre 2026 dans tous les centres régionaux.',
      categorie: CategorieActualite.concours,
      imageUrl: AppImages.campusEsp,
      datePublication: DateTime(2026, 7, 28),
      auteur: 'ESP Dakar',
    ),
    ActualiteModel(
      id: 'news_5',
      titre: 'L\'UVS étend son réseau d\'Espaces Numériques Ouverts',
      contenu:
          'Trois nouveaux Espaces Numériques Ouverts (ENO) ouvrent à Kaolack, Tambacounda '
          'et Kolda pour rapprocher l\'enseignement supérieur numérique des régions.',
      categorie: CategorieActualite.general,
      imageUrl: AppImages.campusUvs,
      datePublication: DateTime(2026, 7, 15),
      auteur: 'UVS',
    ),
    ActualiteModel(
      id: 'news_6',
      titre: 'Semaine de l\'orientation à l\'ISEP Diamniadio',
      contenu:
          'L\'ISEP Diamniadio organise une semaine de l\'orientation avec ateliers, '
          'témoignages d\'anciens étudiants et visites de laboratoires.',
      categorie: CategorieActualite.evenement,
      imageUrl: AppImages.campusIsep,
      datePublication: DateTime(2026, 7, 3),
      auteur: 'ISEP Diamniadio',
    ),
  ];

  @override
  Future<ActualitePageModel> getActualites({
    CategorieActualite? categorie,
    int page = 1,
    int perPage = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));
    final filtered = categorie == null
        ? _actualites
        : _actualites.where((a) => a.categorie == categorie).toList();

    final start = ((page - 1) * perPage).clamp(0, filtered.length);
    final end = (start + perPage).clamp(0, filtered.length);

    return (
      items: filtered.sublist(start, end),
      currentPage: page,
      lastPage: (filtered.length / perPage).ceil().clamp(1, 999),
      total: filtered.length,
    );
  }

  @override
  Future<ActualiteModel> getActualiteDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _actualites.firstWhere((a) => a.id == id);
  }
}
