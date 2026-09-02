import '../models/recommandation_model.dart';
import 'recommendation_remote_datasource.dart';

/// Jeu de données mocké — recommandations réalistes pointant vers les
/// formations mockées de la feature `universities` (mêmes identifiants,
/// voir `MockUniversityData`) pour que la navigation vers la fiche
/// université fonctionne de bout en bout (voir §10).
class MockRecommendationRemoteDataSource implements RecommendationRemoteDataSource {
  @override
  Future<List<RecommandationModel>> getRecommendations() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return [
      RecommandationModel(
        formationId: 'form_isep_dmn_1',
        scoreCorrespondance: 92,
        explicationLlm:
            'Cette formation correspond bien à votre profil scientifique (série S2, '
            'moyenne 13.5/20) et à votre intérêt pour l\'informatique. Sa taille humaine '
            'et son ancrage professionnalisant peuvent convenir à un projet de carrière '
            'en développement logiciel.',
        sourcesInfos: const ['isep-diamniadio.sn/formations'],
        dateGeneration: DateTime.now().subtract(const Duration(hours: 4)),
        formationIntitule: 'BTS Développement Web et Mobile',
        universiteId: 'univ_isep_dmn',
        universiteNom: 'ISEP Diamniadio',
      ),
      RecommandationModel(
        formationId: 'form_ucad_1',
        scoreCorrespondance: 85,
        explicationLlm:
            'L\'UCAD propose une Licence Informatique reconnue, accessible avec votre '
            'moyenne actuelle. Sa taille plus importante offre davantage de spécialisations '
            'possibles en 2e et 3e année.',
        sourcesInfos: const ['ucad.sn/formations'],
        dateGeneration: DateTime.now().subtract(const Duration(hours: 4)),
        formationIntitule: 'Licence Informatique',
        universiteId: 'univ_ucad',
        universiteNom: 'UCAD',
      ),
      RecommandationModel(
        formationId: 'univ_unchk_f1',
        scoreCorrespondance: 74,
        explicationLlm:
            'L\'UN-CHK (ex-UVS) peut être une piste intéressante si vous recherchez de la '
            'flexibilité (cours 100% en ligne) — moins d\'interactions présentielles que '
            'dans un campus classique, à prendre en compte selon votre profil d\'apprentissage.',
        sourcesInfos: const ['unchk.sn'],
        dateGeneration: DateTime.now().subtract(const Duration(hours: 4)),
        formationIntitule: 'Licence Développement Web et Mobile',
        universiteId: 'univ_unchk',
        universiteNom: 'Université Numérique Cheikh Hamidou Kane',
      ),
    ];
  }
}
