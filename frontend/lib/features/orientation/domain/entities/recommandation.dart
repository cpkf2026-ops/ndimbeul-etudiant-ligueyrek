import 'package:freezed_annotation/freezed_annotation.dart';

part 'recommandation.freezed.dart';

/// Suggestion de formation générée par le moteur de scoring IA (Django,
/// relayé par `AiProxyController::recommendations`) — TOUJOURS présentée
/// comme une aide non contraignante, jamais un classement définitif (§9).
@freezed
sealed class Recommandation with _$Recommandation {
  const factory Recommandation({
    required String formationId,
    required double scoreCorrespondance,
    required String explicationLlm,
    @Default(<String>[]) List<String> sourcesInfos,
    DateTime? dateGeneration,
    String? formationIntitule,
    String? universiteId,
    String? universiteNom,
  }) = _Recommandation;
}
