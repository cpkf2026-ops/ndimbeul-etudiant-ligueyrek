import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/source_donnee.dart';

part 'source_donnee_model.freezed.dart';
part 'source_donnee_model.g.dart';

SourceType _typeFromJson(String value) => SourceType.values.firstWhere(
  (t) => t.name == value,
  orElse: () => SourceType.url,
);

String _typeToJson(SourceType type) => type.name;

SourceStatut _statutFromJson(String value) => SourceStatut.values.firstWhere(
  (s) => s.name == value,
  orElse: () => SourceStatut.actif,
);

String _statutToJson(SourceStatut statut) => statut.name;

@freezed
sealed class SourceDonneeModel with _$SourceDonneeModel {
  const factory SourceDonneeModel({
    required String id,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'universite_id') String? universiteId,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
    required SourceType type,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'url_ou_chemin') required String urlOuChemin,
    String? categorie,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _statutFromJson, toJson: _statutToJson)
    required SourceStatut statut,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'derniere_erreur') String? derniereErreur,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'date_dernier_crawl') DateTime? dateDernierCrawl,
  }) = _SourceDonneeModel;

  const SourceDonneeModel._();

  factory SourceDonneeModel.fromJson(Map<String, dynamic> json) =>
      _$SourceDonneeModelFromJson(json);

  SourceDonnee toEntity() => SourceDonnee(
    id: id,
    universiteId: universiteId,
    type: type,
    urlOuChemin: urlOuChemin,
    categorie: categorie,
    statut: statut,
    derniereErreur: derniereErreur,
    dateDernierCrawl: dateDernierCrawl,
  );
}
