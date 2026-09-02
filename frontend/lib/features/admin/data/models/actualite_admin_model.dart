import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/actualite_admin.dart';

part 'actualite_admin_model.freezed.dart';
part 'actualite_admin_model.g.dart';

@freezed
sealed class ActualiteAdminModel with _$ActualiteAdminModel {
  const factory ActualiteAdminModel({
    required String id,
    required String titre,
    String? contenu,
    String? categorie,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'source_url') String? sourceUrl,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'image_url') String? imageUrl,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'date_publication') DateTime? datePublication,
    String? auteur,
  }) = _ActualiteAdminModel;

  const ActualiteAdminModel._();

  factory ActualiteAdminModel.fromJson(Map<String, dynamic> json) =>
      _$ActualiteAdminModelFromJson(json);

  ActualiteAdmin toEntity() => ActualiteAdmin(
    id: id,
    titre: titre,
    contenu: contenu,
    categorie: categorie,
    sourceUrl: sourceUrl,
    imageUrl: imageUrl,
    datePublication: datePublication,
    auteur: auteur,
  );
}
