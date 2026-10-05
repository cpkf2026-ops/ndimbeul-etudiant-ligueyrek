import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/profil_lyceen.dart';

part 'profil_lyceen_model.freezed.dart';
part 'profil_lyceen_model.g.dart';

// Défensif : un cast Eloquent 'decimal:2' renvoie parfois un nombre en chaîne ("14.50")
// selon le contexte de sérialisation — `as double?` planterait dessus (voir bug corrigé
// dans ProfilLyceenResource ; on garde ce filet de sécurité côté client par prudence).
double? _decimalFromJson(dynamic value) =>
    value == null ? null : double.tryParse(value.toString());

dynamic _decimalToJson(double? value) => value;

PrefEtablissement _prefFromJson(String? value) {
  switch (value) {
    case 'public':
      return PrefEtablissement.public;
    case 'prive':
      return PrefEtablissement.prive;
    default:
      return PrefEtablissement.indifferent;
  }
}

String _prefToJson(PrefEtablissement pref) {
  switch (pref) {
    case PrefEtablissement.public:
      return 'public';
    case PrefEtablissement.prive:
      return 'prive';
    case PrefEtablissement.indifferent:
      return 'indifferent';
  }
}

List<String> _stringListFromJson(List<dynamic>? value) =>
    value?.map((e) => e.toString()).toList() ?? <String>[];

/// Miroir de `ProfilLyceenResource` côté backend — `completude` (0-100) est
/// calculée serveur (`calculerCompletude()`), jamais recalculée côté client.
@freezed
sealed class ProfilLyceenModel with _$ProfilLyceenModel {
  const factory ProfilLyceenModel({
    // ignore: invalid_annotation_target
    @JsonKey(name: 'serie_bac') String? serieBac,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'moyenne_generale', fromJson: _decimalFromJson, toJson: _decimalToJson)
    double? moyenneGenerale,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _stringListFromJson) List<String>? passions,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'matieres_fortes', fromJson: _stringListFromJson)
    List<String>? matieresFortes,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'metiers_envisages', fromJson: _stringListFromJson)
    List<String>? metiersEnvisages,
    @Default(false) bool mobilite,
    // ignore: invalid_annotation_target
    @JsonKey(
      name: 'pref_public_prive',
      fromJson: _prefFromJson,
      toJson: _prefToJson,
    )
    @Default(PrefEtablissement.indifferent)
    PrefEtablissement prefPublicPrive,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'region_cible') String? regionCible,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'annee_terminale') int? anneeTerminale,
    @Default(0) int completude,
  }) = _ProfilLyceenModel;

  const ProfilLyceenModel._();

  factory ProfilLyceenModel.fromJson(Map<String, dynamic> json) =>
      _$ProfilLyceenModelFromJson(json);

  factory ProfilLyceenModel.fromEntity(ProfilLyceen entity) =>
      ProfilLyceenModel(
        serieBac: entity.serieBac,
        moyenneGenerale: entity.moyenneGenerale,
        passions: entity.passions,
        matieresFortes: entity.matieresFortes,
        metiersEnvisages: entity.metiersEnvisages,
        mobilite: entity.mobilite,
        prefPublicPrive: entity.prefPublicPrive,
        regionCible: entity.regionCible,
        anneeTerminale: entity.anneeTerminale,
        completude: entity.completude,
      );

  ProfilLyceen toEntity() => ProfilLyceen(
        serieBac: serieBac,
        moyenneGenerale: moyenneGenerale,
        passions: passions ?? const [],
        matieresFortes: matieresFortes ?? const [],
        metiersEnvisages: metiersEnvisages ?? const [],
        mobilite: mobilite,
        prefPublicPrive: prefPublicPrive,
        regionCible: regionCible,
        anneeTerminale: anneeTerminale,
        completude: completude,
      );

  /// Payload `PUT /profile/me` — tous les champs éditables (règles de
  /// validation : voir `UpdateProfilLyceenRequest`).
  Map<String, dynamic> toUpdatePayload() => {
        'serie_bac': serieBac,
        'moyenne_generale': moyenneGenerale,
        'passions': passions,
        'matieres_fortes': matieresFortes,
        'metiers_envisages': metiersEnvisages,
        'mobilite': mobilite,
        'pref_public_prive': _prefToJson(prefPublicPrive),
        'region_cible': regionCible,
        'annee_terminale': anneeTerminale,
      };
}
