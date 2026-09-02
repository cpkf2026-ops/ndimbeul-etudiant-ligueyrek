import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/recommandation.dart';

part 'recommandation_model.freezed.dart';

double _decimalFromJson(dynamic value) => double.tryParse(value?.toString() ?? '') ?? 0;

List<String> _sourcesFromJson(dynamic value) {
  if (value is List) return value.map((e) => e.toString()).toList();
  return const [];
}

/// Miroir défensif de la réponse Django relayée telle quelle par
/// `AiProxyController::recommendations` — le contrat exact du micro-service
/// IA n'est pas garanti côté Laravel (voir `Recommandation` Eloquent, colonnes
/// `score_correspondance`/`explication_llm`/`sources_infos`/`formation_id`).
/// Les infos de formation/université, si présentes, sont lues depuis un
/// éventuel objet imbriqué `formation` — sinon dégradées gracieusement.
@freezed
sealed class RecommandationModel with _$RecommandationModel {
  const factory RecommandationModel({
    required String formationId,
    required double scoreCorrespondance,
    required String explicationLlm,
    @Default(<String>[]) List<String> sourcesInfos,
    DateTime? dateGeneration,
    String? formationIntitule,
    String? universiteId,
    String? universiteNom,
  }) = _RecommandationModel;

  factory RecommandationModel.fromJson(Map<String, dynamic> json) {
    final formation = json['formation'] as Map<String, dynamic>?;
    return RecommandationModel(
      formationId: (json['formation_id'] ?? formation?['id'] ?? '').toString(),
      scoreCorrespondance: _decimalFromJson(json['score_correspondance']),
      explicationLlm: (json['explication_llm'] ?? '').toString(),
      sourcesInfos: _sourcesFromJson(json['sources_infos']),
      dateGeneration: DateTime.tryParse(json['date_generation']?.toString() ?? ''),
      formationIntitule: formation?['intitule']?.toString(),
      universiteId: (formation?['universite_id'])?.toString(),
      universiteNom: formation?['universite_nom']?.toString(),
    );
  }

  const RecommandationModel._();

  Recommandation toEntity() => Recommandation(
        formationId: formationId,
        scoreCorrespondance: scoreCorrespondance,
        explicationLlm: explicationLlm,
        sourcesInfos: sourcesInfos,
        dateGeneration: dateGeneration,
        formationIntitule: formationIntitule,
        universiteId: universiteId,
        universiteNom: universiteNom,
      );
}
