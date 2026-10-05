import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/actualite.dart';

part 'actualite_model.freezed.dart';
part 'actualite_model.g.dart';

CategorieActualite _categorieFromJson(String value) {
  switch (value) {
    case 'bourse':
      return CategorieActualite.bourse;
    case 'concours':
      return CategorieActualite.concours;
    case 'evenement':
      return CategorieActualite.evenement;
    case 'formation':
      return CategorieActualite.formation;
    case 'general':
      return CategorieActualite.general;
    default:
      return CategorieActualite.general;
  }
}

String _categorieToJson(CategorieActualite categorie) => categorie.name;

@freezed
sealed class ActualiteModel with _$ActualiteModel {
  const factory ActualiteModel({
    required String id,
    required String titre,
    required String contenu,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _categorieFromJson, toJson: _categorieToJson)
    required CategorieActualite categorie,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'source_url') String? sourceUrl,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'image_url') String? imageUrl,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'date_publication') required DateTime datePublication,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'date_indexation') DateTime? dateIndexation,
    String? auteur,
    String? fiabilite,
  }) = _ActualiteModel;

  const ActualiteModel._();

  factory ActualiteModel.fromJson(Map<String, dynamic> json) =>
      _$ActualiteModelFromJson(json);

  Actualite toEntity() => Actualite(
        id: id,
        titre: titre,
        contenu: contenu,
        categorie: categorie,
        sourceUrl: sourceUrl,
        imageUrl: imageUrl,
        datePublication: datePublication,
        dateIndexation: dateIndexation,
        auteur: auteur,
        fiabilite: fiabilite,
      );
}
