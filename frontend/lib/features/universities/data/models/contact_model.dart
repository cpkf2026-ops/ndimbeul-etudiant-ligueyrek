import 'package:freezed_annotation/freezed_annotation.dart';

part 'contact_model.freezed.dart';
part 'contact_model.g.dart';

/// Sous-objet `contact` de `UniversiteResource` (`{email, telephone}`).
@freezed
sealed class ContactModel with _$ContactModel {
  const factory ContactModel({
    String? email,
    String? telephone,
  }) = _ContactModel;

  factory ContactModel.fromJson(Map<String, dynamic> json) => _$ContactModelFromJson(json);
}
