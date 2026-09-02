import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/bourse.dart';

part 'bourse_model.freezed.dart';
part 'bourse_model.g.dart';

// `montant` est casté `decimal:2` côté Laravel → sérialisé en string JSON
// ("150000.00"), jamais en nombre natif. Voir Bourse::casts().
double? _decimalFromJson(dynamic value) =>
    value == null ? null : double.tryParse(value.toString());

dynamic _decimalToJson(double? value) => value?.toString();

@freezed
sealed class BourseModel with _$BourseModel {
  const factory BourseModel({
    required String id,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'universite_id') String? universiteId,
    required String nom,
    String? organisme,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) double? montant,
    @Default('XOF') String devise,
    String? conditions,
    String? demarches,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'date_limite') DateTime? dateLimite,
    @Default(false) bool expiree,
    String? lien,
    String? source,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'date_maj') DateTime? dateMaj,
  }) = _BourseModel;

  const BourseModel._();

  factory BourseModel.fromJson(Map<String, dynamic> json) => _$BourseModelFromJson(json);

  Bourse toEntity() => Bourse(
        id: id,
        universiteId: universiteId,
        nom: nom,
        organisme: organisme,
        montant: montant,
        devise: devise,
        conditions: conditions,
        demarches: demarches,
        dateLimite: dateLimite,
        expiree: expiree,
        lien: lien,
        source: source,
        dateMaj: dateMaj,
      );
}
