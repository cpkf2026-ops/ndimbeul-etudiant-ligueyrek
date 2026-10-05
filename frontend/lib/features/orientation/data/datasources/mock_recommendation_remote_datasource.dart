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
        intitule: 'BTS Développement Web et Mobile',
        niveau: 'bts',
        domaine: 'Informatique',
        universiteId: 'univ_isep_dmn',
        universiteNom: 'ISEP Diamniadio',
        universiteRegion: 'Dakar',
        scoreCorrespondance: 92,
        explicationLlm:
            'Cette formation correspond bien à votre profil scientifique (série S2, '
            'moyenne 13.5/20) et à votre intérêt pour l\'informatique. Sa taille humaine '
            'et son ancrage professionnalisant peuvent convenir à un projet de carrière '
            'en développement logiciel.',
        conditionsAdmission: const ConditionsAdmissionModel(
          seriesAcceptees: ['S1', 'S2', 'S3', 'T'],
          moyenneMinimale: 10,
        ),
        debouches: 'Développeur web/mobile junior, intégrateur, support technique.',
      ),
      RecommandationModel(
        formationId: 'form_ucad_1',
        intitule: 'Licence Informatique',
        niveau: 'licence',
        domaine: 'Informatique',
        universiteId: 'univ_ucad',
        universiteNom: 'UCAD',
        universiteRegion: 'Dakar',
        scoreCorrespondance: 85,
        explicationLlm:
            'L\'UCAD propose une Licence Informatique reconnue, accessible avec votre '
            'moyenne actuelle. Sa taille plus importante offre davantage de spécialisations '
            'possibles en 2e et 3e année.',
        conditionsAdmission: const ConditionsAdmissionModel(
          seriesAcceptees: ['S1', 'S2', 'S3'],
          moyenneMinimale: 12,
        ),
        debouches: 'Poursuite en master, développeur, administrateur systèmes.',
      ),
      RecommandationModel(
        formationId: 'univ_unchk_f1',
        intitule: 'Licence Développement Web et Mobile',
        niveau: 'licence',
        domaine: 'Informatique',
        universiteId: 'univ_unchk',
        universiteNom: 'Université Numérique Cheikh Hamidou Kane',
        universiteRegion: 'Dakar',
        scoreCorrespondance: 74,
        explicationLlm:
            'L\'UN-CHK (ex-UVS) peut être une piste intéressante si vous recherchez de la '
            'flexibilité (cours 100% en ligne) — moins d\'interactions présentielles que '
            'dans un campus classique, à prendre en compte selon votre profil d\'apprentissage.',
        conditionsAdmission: const ConditionsAdmissionModel(seriesAcceptees: ['S1', 'S2', 'L']),
        debouches: 'Développeur web, freelance, poursuite d\'études à distance.',
      ),
    ];
  }
}
