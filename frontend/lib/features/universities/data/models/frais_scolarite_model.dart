import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/frais_scolarite.dart';

part 'frais_scolarite_model.freezed.dart';
part 'frais_scolarite_model.g.dart';

double _decimalFromJson(dynamic value) => double.tryParse(value.toString()) ?? 0;

dynamic _decimalToJson(double value) => value.toString();

@freezed
sealed class FraisScolariteModel with _$FraisScolariteModel {
  const factory FraisScolariteModel({
    required String id,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'universite_id') required String universiteId,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'formation_id') String? formationId,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) required double montant,
    @Default('XOF') String devise,
    List<dynamic>? echeancier,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'moyens_paiement') List<String>? moyensPaiement,
    String? source,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'date_maj') DateTime? dateMaj,
  }) = _FraisScolariteModel;

  const FraisScolariteModel._();

  factory FraisScolariteModel.fromJson(Map<String, dynamic> json) =>
      _$FraisScolariteModelFromJson(json);

  FraisScolarite toEntity() => FraisScolarite(
        id: id,
        universiteId: universiteId,
        formationId: formationId,
        montant: montant,
        devise: devise,
        echeancier: echeancier,
        moyensPaiement: moyensPaiement,
        source: source,
        dateMaj: dateMaj,
      );
}
