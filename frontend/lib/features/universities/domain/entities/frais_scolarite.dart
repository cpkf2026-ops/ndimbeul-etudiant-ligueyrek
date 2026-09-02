import 'package:freezed_annotation/freezed_annotation.dart';

part 'frais_scolarite.freezed.dart';

/// Frais de scolarité — rattachés à une université et, optionnellement, à
/// une formation précise (CDC §5.3/§7.3).
@freezed
sealed class FraisScolarite with _$FraisScolarite {
  const factory FraisScolarite({
    required String id,
    required String universiteId,
    String? formationId,
    required double montant,
    @Default('XOF') String devise,
    List<dynamic>? echeancier,
    List<String>? moyensPaiement,
    String? source,
    DateTime? dateMaj,
  }) = _FraisScolarite;
}
