import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/profil_etudiant.dart';

part 'profil_etudiant_model.freezed.dart';
part 'profil_etudiant_model.g.dart';

NiveauEtudiant? _niveauFromJson(String? value) {
  switch (value) {
    case 'L1':
      return NiveauEtudiant.l1;
    case 'L2':
      return NiveauEtudiant.l2;
    case 'L3':
      return NiveauEtudiant.l3;
    case 'M1':
      return NiveauEtudiant.m1;
    case 'M2':
      return NiveauEtudiant.m2;
    case 'Doctorat':
      return NiveauEtudiant.doctorat;
    default:
      return null;
  }
}

String? _niveauToJson(NiveauEtudiant? niveau) {
  switch (niveau) {
    case NiveauEtudiant.l1:
      return 'L1';
    case NiveauEtudiant.l2:
      return 'L2';
    case NiveauEtudiant.l3:
      return 'L3';
    case NiveauEtudiant.m1:
      return 'M1';
    case NiveauEtudiant.m2:
      return 'M2';
    case NiveauEtudiant.doctorat:
      return 'Doctorat';
    case null:
      return null;
  }
}

List<String> _stringListFromJson(List<dynamic>? value) =>
    value?.map((e) => e.toString()).toList() ?? <String>[];

/// Miroir de `ProfilEtudiantResource` côté backend.
@freezed
sealed class ProfilEtudiantModel with _$ProfilEtudiantModel {
  const factory ProfilEtudiantModel({
    // ignore: invalid_annotation_target
    @JsonKey(name: 'universite_actuelle') String? universiteActuelle,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'formation_actuelle') String? formationActuelle,
    // ignore: invalid_annotation_target
    @JsonKey(
      name: 'niveau_actuel',
      fromJson: _niveauFromJson,
      toJson: _niveauToJson,
    )
    NiveauEtudiant? niveauActuel,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'domaines_interets', fromJson: _stringListFromJson)
    List<String>? domainesInterets,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'recherche_stage') @Default(false) bool rechercheStage,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'recherche_emploi') @Default(false) bool rechercheEmploi,
  }) = _ProfilEtudiantModel;

  const ProfilEtudiantModel._();

  factory ProfilEtudiantModel.fromJson(Map<String, dynamic> json) =>
      _$ProfilEtudiantModelFromJson(json);

  factory ProfilEtudiantModel.fromEntity(ProfilEtudiant entity) =>
      ProfilEtudiantModel(
        universiteActuelle: entity.universiteActuelle,
        formationActuelle: entity.formationActuelle,
        niveauActuel: entity.niveauActuel,
        domainesInterets: entity.domainesInterets,
        rechercheStage: entity.rechercheStage,
        rechercheEmploi: entity.rechercheEmploi,
      );

  ProfilEtudiant toEntity() => ProfilEtudiant(
        universiteActuelle: universiteActuelle,
        formationActuelle: formationActuelle,
        niveauActuel: niveauActuel,
        domainesInterets: domainesInterets ?? const [],
        rechercheStage: rechercheStage,
        rechercheEmploi: rechercheEmploi,
      );

  /// Payload `PUT /profile/me` (règles : voir `UpdateProfilEtudiantRequest`).
  Map<String, dynamic> toUpdatePayload() => {
        'universite_actuelle': universiteActuelle,
        'formation_actuelle': formationActuelle,
        'niveau_actuel': _niveauToJson(niveauActuel),
        'domaines_interets': domainesInterets,
        'recherche_stage': rechercheStage,
        'recherche_emploi': rechercheEmploi,
      };
}
