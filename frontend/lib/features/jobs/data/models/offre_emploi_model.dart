import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/offre_emploi.dart';

part 'offre_emploi_model.freezed.dart';
part 'offre_emploi_model.g.dart';

JobType _typeFromJson(String value) {
  switch (value) {
    case 'emploi':
      return JobType.emploi;
    case 'stage':
      return JobType.stage;
    case 'alternance':
      return JobType.alternance;
    case 'formation':
      return JobType.formation;
    case 'bourse':
      return JobType.bourse;
    case 'concours':
      return JobType.concours;
    default:
      return JobType.emploi;
  }
}

String _typeToJson(JobType type) => type.name;

// Défensif : certaines fiches plus anciennes en base peuvent avoir ces champs à null
// (avant que la veille IA ne garantisse toujours une valeur) — on évite un plantage du
// parsing JSON pour l'utilisateur plutôt que d'exiger une discipline parfaite côté API.
String _texteOuDefaut(dynamic value, String defaut) =>
    (value as String?)?.trim().isNotEmpty == true ? value as String : defaut;

String _entrepriseFromJson(dynamic value) => _texteOuDefaut(value, 'Non précisé');
String _domaineFromJson(dynamic value) => _texteOuDefaut(value, 'Non précisé');
String _regionFromJson(dynamic value) => _texteOuDefaut(value, 'Non précisée');
String _descriptionFromJson(dynamic value) => _texteOuDefaut(value, '');

@freezed
sealed class OffreEmploiModel with _$OffreEmploiModel {
  const factory OffreEmploiModel({
    required String id,
    required String intitule,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _entrepriseFromJson) required String entreprise,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson) required JobType type,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _domaineFromJson) required String domaine,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'niveau_requis') String? niveauRequis,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _regionFromJson) required String region,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _descriptionFromJson) required String description,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'source_url') String? sourceUrl,
    String? source,
    String? fiabilite,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'date_publication') DateTime? datePublication,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'date_limite') DateTime? dateLimite,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'date_indexation') DateTime? dateIndexation,
    required String statut,
    @Default(false) bool expiree,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'est_favori') bool? estFavori,
  }) = _OffreEmploiModel;

  const OffreEmploiModel._();

  factory OffreEmploiModel.fromJson(Map<String, dynamic> json) =>
      _$OffreEmploiModelFromJson(json);

  OffreEmploi toEntity() => OffreEmploi(
        id: id,
        intitule: intitule,
        entreprise: entreprise,
        type: type,
        domaine: domaine,
        niveauRequis: niveauRequis,
        region: region,
        description: description,
        sourceUrl: sourceUrl,
        source: source,
        fiabilite: fiabilite,
        datePublication: datePublication,
        dateLimite: dateLimite,
        dateIndexation: dateIndexation,
        statut: statut,
        expiree: expiree,
        estFavori: estFavori ?? false,
      );
}
