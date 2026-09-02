import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/formation.dart';

part 'formation_model.freezed.dart';
part 'formation_model.g.dart';

NiveauFormation _niveauFromJson(String value) {
  switch (value) {
    case 'bts':
      return NiveauFormation.bts;
    case 'licence':
      return NiveauFormation.licence;
    case 'master':
      return NiveauFormation.master;
    case 'doctorat':
      return NiveauFormation.doctorat;
    default:
      return NiveauFormation.licence;
  }
}

String _niveauToJson(NiveauFormation value) => value.name;

// `moyenne_minimale` est casté `decimal:2` côté Laravel → string JSON.
double? _decimalFromJson(dynamic value) =>
    value == null ? null : double.tryParse(value.toString());

dynamic _decimalToJson(double? value) => value?.toString();

List<String>? _seriesFromJson(List<dynamic>? value) => value?.map((e) => e.toString()).toList();

@freezed
sealed class FormationModel with _$FormationModel {
  const factory FormationModel({
    required String id,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'universite_id') required String universiteId,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'universite_nom') String? universiteNom,
    required String intitule,
    required String domaine,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _niveauFromJson, toJson: _niveauToJson) required NiveauFormation niveau,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'duree_annees') int? dureeAnnees,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'series_acceptees', fromJson: _seriesFromJson) List<String>? seriesAcceptees,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'moyenne_minimale', fromJson: _decimalFromJson, toJson: _decimalToJson)
    double? moyenneMinimale,
    int? capacite,
    String? prerequis,
    String? debouches,
    // ignore: invalid_annotation_target
    @Default(false) @JsonKey(name: 'est_favori', defaultValue: false) bool estFavori,
  }) = _FormationModel;

  const FormationModel._();

  factory FormationModel.fromJson(Map<String, dynamic> json) => _$FormationModelFromJson(json);

  Formation toEntity() => Formation(
        id: id,
        universiteId: universiteId,
        universiteNom: universiteNom,
        intitule: intitule,
        domaine: domaine,
        niveau: niveau,
        dureeAnnees: dureeAnnees,
        seriesAcceptees: seriesAcceptees,
        moyenneMinimale: moyenneMinimale,
        capacite: capacite,
        prerequis: prerequis,
        debouches: debouches,
        estFavori: estFavori,
      );
}
