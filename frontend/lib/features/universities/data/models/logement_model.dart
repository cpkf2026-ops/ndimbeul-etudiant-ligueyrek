import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/logement.dart';

part 'logement_model.freezed.dart';
part 'logement_model.g.dart';

TypeLogement _typeFromJson(String value) {
  switch (value) {
    case 'residence':
      return TypeLogement.residence;
    case 'foyer':
      return TypeLogement.foyer;
    case 'partenaire':
      return TypeLogement.partenaire;
    default:
      return TypeLogement.residence;
  }
}

String _typeToJson(TypeLogement type) => type.name;

double? _decimalFromJson(dynamic value) =>
    value == null ? null : double.tryParse(value.toString());

dynamic _decimalToJson(double? value) => value?.toString();

@freezed
sealed class LogementModel with _$LogementModel {
  const factory LogementModel({
    required String id,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'universite_id') required String universiteId,
    required String nom,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson) required TypeLogement type,
    int? capacite,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'tarif_mensuel', fromJson: _decimalFromJson, toJson: _decimalToJson)
    double? tarifMensuel,
    @Default('XOF') String devise,
    String? contact,
    String? source,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'date_maj') DateTime? dateMaj,
  }) = _LogementModel;

  const LogementModel._();

  factory LogementModel.fromJson(Map<String, dynamic> json) => _$LogementModelFromJson(json);

  Logement toEntity() => Logement(
        id: id,
        universiteId: universiteId,
        nom: nom,
        type: type,
        capacite: capacite,
        tarifMensuel: tarifMensuel,
        devise: devise,
        contact: contact,
        source: source,
        dateMaj: dateMaj,
      );
}
