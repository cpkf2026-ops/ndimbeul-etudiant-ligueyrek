import '../../../../core/utils/result.dart';
import '../entities/recommandation.dart';

abstract interface class RecommendationRepository {
  /// `GET /ai/recommendations` — 422 si le profil lycéen est absent ou
  /// incomplet (remonté en `Failure.validation`, voir écran Recommandations).
  Future<Result<List<Recommandation>>> getRecommendations();
}
