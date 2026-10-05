import 'package:freezed_annotation/freezed_annotation.dart';

part 'recommandation.freezed.dart';

/// Conditions d'admission d'une formation — série(s) de bac acceptée(s), moyenne
/// minimale requise, prérequis en texte libre. Champs `null`/vides si non
/// renseignés côté établissement (jamais inventés).
@freezed
sealed class ConditionsAdmission with _$ConditionsAdmission {
  const factory ConditionsAdmission({
    @Default(<String>[]) List<String> seriesAcceptees,
    double? moyenneMinimale,
    String? prerequis,
  }) = _ConditionsAdmission;
}

/// Suggestion de formation générée par le moteur de scoring IA (Django,
/// relayé par `AiProxyController::recommendations`) — TOUJOURS présentée
/// comme une aide non contraignante, jamais un classement définitif (§9).
///
/// Le filtrage par série de bac est éliminatoire côté serveur (Tâche 4) :
/// une formation présente ici est garantie compatible avec la série du profil.
@freezed
sealed class Recommandation with _$Recommandation {
  const factory Recommandation({
    required String formationId,
    required String intitule,
    String? niveau,
    String? domaine,
    required String universiteId,
    required String universiteNom,
    String? universiteRegion,
    required double scoreCorrespondance,
    required String explicationLlm,
    ConditionsAdmission? conditionsAdmission,
    String? debouches,
  }) = _Recommandation;
}
