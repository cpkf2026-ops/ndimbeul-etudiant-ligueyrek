import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/app_notification.dart';

part 'app_notification_model.freezed.dart';

/// Modèle défensif — les notifications sont des lignes brutes de la table
/// Laravel standard `notifications` (Illuminate\Notifications\
/// DatabaseNotification), PAS une Resource façonnée par le backend.
/// `data` a une forme arbitraire selon `type` ; le seul type concret
/// aujourd'hui est `App\Notifications\NouvelleOffreCorrespondante`, dont
/// `toArray()` produit `{type: 'nouvelle_offre', nb_offres, offres: [...]}`
/// (voir backend/app/Notifications/NouvelleOffreCorrespondante.php).
/// On ne fait donc AUCUNE hypothèse forte sur la présence de ces clés.
@freezed
sealed class AppNotificationModel with _$AppNotificationModel {
  const factory AppNotificationModel({
    required String id,
    required String type,
    required String titre,
    required String corps,
    DateTime? readAt,
    required DateTime createdAt,
  }) = _AppNotificationModel;

  const AppNotificationModel._();

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final type = json['type']?.toString() ?? '';
    final rawData = json['data'];
    final data = rawData is Map ? Map<String, dynamic>.from(rawData) : <String, dynamic>{};

    final shortType = type.contains('\\') ? type.split('\\').last : type;
    final kind = (data['type'] as String?) ?? shortType;

    var titre = 'Nouvelle notification';
    var corps = 'Vous avez une nouvelle notification.';

    if (kind == 'nouvelle_offre' || shortType == 'NouvelleOffreCorrespondante') {
      final offresRaw = data['offres'];
      final offres = offresRaw is List ? offresRaw : const [];
      final nb = (data['nb_offres'] as num?)?.toInt() ?? offres.length;
      titre = nb > 1
          ? '$nb nouvelles offres correspondantes'
          : 'Nouvelle offre correspondante';
      if (offres.isNotEmpty && offres.first is Map) {
        final premiere = Map<String, dynamic>.from(offres.first as Map);
        final intitule = premiere['intitule']?.toString();
        final entreprise = premiere['entreprise']?.toString();
        if (intitule != null) {
          final suffixe = entreprise != null ? ' chez $entreprise' : '';
          corps = nb > 1
              ? '$intitule$suffixe et ${nb - 1} autre(s) offre(s) à découvrir.'
              : '$intitule$suffixe correspond à votre profil.';
        } else if (nb > 0) {
          corps = '$nb offre(s) correspondant à votre profil.';
        }
      } else if (nb > 0) {
        corps = '$nb offre(s) correspondant à votre profil.';
      }
    }

    final readAtRaw = json['read_at'];
    final createdAtRaw = json['created_at']?.toString();

    return AppNotificationModel(
      id: id,
      type: type,
      titre: titre,
      corps: corps,
      readAt: readAtRaw is String ? DateTime.tryParse(readAtRaw) : null,
      createdAt: createdAtRaw != null
          ? (DateTime.tryParse(createdAtRaw) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  AppNotification toEntity() => AppNotification(
        id: id,
        type: type,
        titre: titre,
        corps: corps,
        readAt: readAt,
        createdAt: createdAt,
      );
}
