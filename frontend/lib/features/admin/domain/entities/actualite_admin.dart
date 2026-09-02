import 'package:freezed_annotation/freezed_annotation.dart';

part 'actualite_admin.freezed.dart';

/// Actualité en lecture seule pour le back-office (`ActualiteResource`) —
/// aucun endpoint d'écriture n'existe côté backend, voir `AdminNewsScreen`.
@freezed
sealed class ActualiteAdmin with _$ActualiteAdmin {
  const factory ActualiteAdmin({
    required String id,
    required String titre,
    String? contenu,
    String? categorie,
    String? sourceUrl,
    String? imageUrl,
    DateTime? datePublication,
    String? auteur,
  }) = _ActualiteAdmin;

  const ActualiteAdmin._();
}
