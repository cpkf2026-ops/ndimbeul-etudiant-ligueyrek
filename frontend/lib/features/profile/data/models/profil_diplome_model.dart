import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/profil_diplome.dart';

part 'profil_diplome_model.freezed.dart';
part 'profil_diplome_model.g.dart';

SituationActuelle? _situationFromJson(String? value) {
  switch (value) {
    case 'en_poste':
      return SituationActuelle.enPoste;
    case 'recherche_emploi':
      return SituationActuelle.rechercheEmploi;
    case 'stage':
      return SituationActuelle.stage;
    default:
      return null;
  }
}

String? _situationToJson(SituationActuelle? situation) {
  switch (situation) {
    case SituationActuelle.enPoste:
      return 'en_poste';
    case SituationActuelle.rechercheEmploi:
      return 'recherche_emploi';
    case SituationActuelle.stage:
      return 'stage';
    case null:
      return null;
  }
}

/// Miroir de `ProfilDiplomeResource` côté backend.
@freezed
sealed class ProfilDiplomeModel with _$ProfilDiplomeModel {
  const factory ProfilDiplomeModel({
    // ignore: invalid_annotation_target
    @JsonKey(name: 'dernier_diplome') String? dernierDiplome,
    String? domaine,
    // ignore: invalid_annotation_target
    @JsonKey(
      name: 'situation_actuelle',
      fromJson: _situationFromJson,
      toJson: _situationToJson,
    )
    SituationActuelle? situationActuelle,
    String? entreprise,
  }) = _ProfilDiplomeModel;

  const ProfilDiplomeModel._();

  factory ProfilDiplomeModel.fromJson(Map<String, dynamic> json) =>
      _$ProfilDiplomeModelFromJson(json);

  factory ProfilDiplomeModel.fromEntity(ProfilDiplome entity) => ProfilDiplomeModel(
        dernierDiplome: entity.dernierDiplome,
        domaine: entity.domaine,
        situationActuelle: entity.situationActuelle,
        entreprise: entity.entreprise,
      );

  ProfilDiplome toEntity() => ProfilDiplome(
        dernierDiplome: dernierDiplome,
        domaine: domaine,
        situationActuelle: situationActuelle,
        entreprise: entreprise,
      );

  /// Payload `PUT /profile/me` (règles : voir `UpdateProfilDiplomeRequest`).
  Map<String, dynamic> toUpdatePayload() => {
        'dernier_diplome': dernierDiplome,
        'domaine': domaine,
        'situation_actuelle': _situationToJson(situationActuelle),
        'entreprise': entreprise,
      };
}
