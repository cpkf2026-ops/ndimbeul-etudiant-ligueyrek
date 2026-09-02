import '../../../../core/utils/result.dart';
import '../entities/quality_metrics.dart';

abstract interface class QualityRepository {
  /// UC14 — `GET /admin/quality` (super_admin uniquement).
  Future<Result<QualityMetrics>> getQualityMetrics();
}
