import '../../../../core/utils/result.dart';
import '../entities/actualite_admin.dart';

/// Lecture seule — il n'existe aucun endpoint backend de création/édition
/// d'actualités (voir `AdminNewsScreen` et le rapport de livraison).
abstract interface class AdminNewsRepository {
  Future<Result<List<ActualiteAdmin>>> getNews();
}
