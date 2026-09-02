import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/mock_recommendation_remote_datasource.dart';
import '../../data/datasources/recommendation_remote_datasource.dart';
import '../../data/repositories/recommendation_repository_impl.dart';
import '../../domain/entities/recommandation.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../../domain/usecases/get_recommendations.dart';

final recommendationRemoteDataSourceProvider = Provider<RecommendationRemoteDataSource>((ref) {
  if (ref.watch(useMockProvider)) return MockRecommendationRemoteDataSource();
  return RecommendationRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

final recommendationRepositoryProvider = Provider<RecommendationRepository>((ref) {
  return RecommendationRepositoryImpl(
    remoteDataSource: ref.watch(recommendationRemoteDataSourceProvider),
  );
});

final getRecommendationsUseCaseProvider =
    Provider((ref) => GetRecommendations(ref.watch(recommendationRepositoryProvider)));

final recommendationsProvider = FutureProvider<List<Recommandation>>((ref) async {
  final result = await ref.read(getRecommendationsUseCaseProvider).call(const NoParams());
  return result.fold((failure) => throw failure, (list) => list);
});
