import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/recommandation.dart';

part 'recommandation_model.freezed.dart';

double _decimalFromJson(dynamic value) => double.tryParse(value?.toString() ?? '') ?? 0;

List<String> _stringListFromJson(dynamic value) {
  if (value is List) return value.map((e) => e.toString()).toList();
  return const [];
}

/// Miroir de la réponse réelle de `POST /internal/recommendations` (Django,
/// `recommandations/views.py::recommendations`), relayée telle quelle par
/// `AiProxyController::recommendations`.
@freezed
sealed class ConditionsAdmissionModel with _$ConditionsAdmissionModel {
  const factory ConditionsAdmissionModel({
    @Default(<String>[]) List<String> seriesAcceptees,
    double? moyenneMinimale,
    String? prerequis,
  }) = _ConditionsAdmissionModel;

  factory ConditionsAdmissionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ConditionsAdmissionModel();
    return ConditionsAdmissionModel(
      seriesAcceptees: _stringListFromJson(json['series_acceptees']),
      moyenneMinimale: json['moyenne_minimale'] != null
          ? _decimalFromJson(json['moyenne_minimale'])
          : null,
      prerequis: json['prerequis']?.toString(),
    );
  }

  const ConditionsAdmissionModel._();

  ConditionsAdmission toEntity() => ConditionsAdmission(
        seriesAcceptees: seriesAcceptees,
        moyenneMinimale: moyenneMinimale,
        prerequis: prerequis,
      );
}

@freezed
sealed class RecommandationModel with _$RecommandationModel {
  const factory RecommandationModel({
    required String formationId,
    required String intitule,
    String? niveau,
    String? domaine,
    required String universiteId,
    required String universiteNom,
    String? universiteRegion,
    required double scoreCorrespondance,
    required String explicationLlm,
    ConditionsAdmissionModel? conditionsAdmission,
    String? debouches,
  }) = _RecommandationModel;

  factory RecommandationModel.fromJson(Map<String, dynamic> json) {
    final universite = json['universite'] as Map<String, dynamic>?;
    return RecommandationModel(
      formationId: (json['formation_id'] ?? '').toString(),
      intitule: (json['intitule'] ?? 'Formation suggérée').toString(),
      niveau: json['niveau']?.toString(),
      domaine: json['domaine']?.toString(),
      universiteId: (universite?['id'] ?? '').toString(),
      universiteNom: (universite?['nom'] ?? '').toString(),
      universiteRegion: universite?['region']?.toString(),
      scoreCorrespondance: _decimalFromJson(json['score_correspondance']),
      explicationLlm: (json['explication'] ?? '').toString(),
      conditionsAdmission: ConditionsAdmissionModel.fromJson(
        json['conditions_admission'] as Map<String, dynamic>?,
      ),
      debouches: json['debouches']?.toString(),
    );
  }

  const RecommandationModel._();

  Recommandation toEntity() => Recommandation(
        formationId: formationId,
        intitule: intitule,
        niveau: niveau,
        domaine: domaine,
        universiteId: universiteId,
        universiteNom: universiteNom,
        universiteRegion: universiteRegion,
        scoreCorrespondance: scoreCorrespondance,
        explicationLlm: explicationLlm,
        conditionsAdmission: conditionsAdmission?.toEntity(),
        debouches: debouches,
      );
}
