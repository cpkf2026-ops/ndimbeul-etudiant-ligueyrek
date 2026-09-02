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
    default:
      return JobType.emploi;
  }
}

String _typeToJson(JobType type) => type.name;

@freezed
sealed class OffreEmploiModel with _$OffreEmploiModel {
  const factory OffreEmploiModel({
    required String id,
    required String intitule,
    required String entreprise,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson) required JobType type,
    required String domaine,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'niveau_requis') String? niveauRequis,
    required String region,
    required String description,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'source_url') String? sourceUrl,
    String? source,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'date_publication') DateTime? datePublication,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'date_limite') DateTime? dateLimite,
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
        datePublication: datePublication,
        dateLimite: dateLimite,
        statut: statut,
        expiree: expiree,
        estFavori: estFavori ?? false,
      );
}
