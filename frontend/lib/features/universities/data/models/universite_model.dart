import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/universite.dart';
import 'bourse_model.dart';
import 'contact_model.dart';
import 'formation_model.dart';
import 'frais_scolarite_model.dart';
import 'logement_model.dart';

part 'universite_model.freezed.dart';
part 'universite_model.g.dart';

// Statut absent ou inconnu -> null (non vérifié) : jamais « public » par défaut.
EtablissementType? _typeFromJson(String? value) {
  switch (value) {
    case 'public':
      return EtablissementType.public;
    case 'prive':
      return EtablissementType.prive;
    default:
      return null;
  }
}

String? _typeToJson(EtablissementType? type) => type?.name;

@freezed
sealed class UniversiteModel with _$UniversiteModel {
  const factory UniversiteModel({
    required String id,
    required String nom,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'code_unique') required String codeUnique,
    String? region,
    String? commune,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson) EtablissementType? type,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'site_web_officiel') String? siteWebOfficiel,
    String? description,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'image_url') String? imageUrl,
    ContactModel? contact,
    @Default([]) List<String> domaines,
    @Default([]) List<String> diplomes,
    String? admission,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'niveau_requis') @Default([]) List<String> niveauRequis,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'pieces_a_fournir') @Default([]) List<String> piecesAFournir,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'source_infos') String? sourceInfos,
    @Default([]) List<FormationModel> formations,
    @Default([]) List<BourseModel> bourses,
    @Default([]) List<LogementModel> logements,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'frais_scolarite') @Default([]) List<FraisScolariteModel> fraisScolarite,
  }) = _UniversiteModel;

  const UniversiteModel._();

  factory UniversiteModel.fromJson(Map<String, dynamic> json) => _$UniversiteModelFromJson(json);

  Universite toEntity() => Universite(
        id: id,
        nom: nom,
        codeUnique: codeUnique,
        region: region,
        commune: commune,
        type: type,
        siteWebOfficiel: siteWebOfficiel,
        description: description,
        imageUrl: imageUrl,
        emailContact: contact?.email,
        telephoneContact: contact?.telephone,
        adresse: contact?.adresse,
        domaines: domaines,
        diplomes: diplomes,
        admission: admission,
        niveauRequis: niveauRequis,
        piecesAFournir: piecesAFournir,
        sourceInfos: sourceInfos,
        formations: formations.map((f) => f.toEntity()).toList(),
        bourses: bourses.map((b) => b.toEntity()).toList(),
        logements: logements.map((l) => l.toEntity()).toList(),
        fraisScolarite: fraisScolarite.map((f) => f.toEntity()).toList(),
      );
}
