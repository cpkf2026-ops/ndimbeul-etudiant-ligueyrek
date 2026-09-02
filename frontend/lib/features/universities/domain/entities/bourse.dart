import 'package:freezed_annotation/freezed_annotation.dart';

part 'bourse.freezed.dart';

/// Bourse d'études — nationale (universiteId == null) ou liée à un
/// établissement précis. Voir CDC §5.3/§7.3.
@freezed
sealed class Bourse with _$Bourse {
  const factory Bourse({
    required String id,
    String? universiteId,
    required String nom,
    String? organisme,
    double? montant,
    @Default('XOF') String devise,
    String? conditions,
    String? demarches,
    DateTime? dateLimite,
    @Default(false) bool expiree,
    String? lien,
    String? source,
    DateTime? dateMaj,
  }) = _Bourse;
}
