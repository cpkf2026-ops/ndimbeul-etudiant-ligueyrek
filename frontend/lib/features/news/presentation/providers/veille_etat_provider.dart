import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/network/api_endpoints.dart';

/// Dernier passage d'une veille IA (actualités ou offres) : quand elle a vérifié,
/// ce qu'elle a trouvé, et quand elle repassera.
class EtatVeille {
  const EtatVeille({
    this.derniereVerification,
    this.trouves = 0,
    this.ajoutes = 0,
    this.prochainPassage,
    this.horsLigne = false,
  });

  final DateTime? derniereVerification;
  final int trouves;
  final int ajoutes;
  final DateTime? prochainPassage;

  /// Dernier passage sans connexion Internet : rien n'a pu être vérifié.
  final bool horsLigne;

  factory EtatVeille.fromJson(Map<String, dynamic> json) {
    final dernier = json['dernier_passage'] as Map<String, dynamic>?;
    return EtatVeille(
      derniereVerification: DateTime.tryParse(dernier?['heure'] as String? ?? '')?.toLocal(),
      trouves: ((dernier?['candidats'] as num?) ?? 0).toInt() +
          ((dernier?['flux_officiels'] as num?) ?? 0).toInt(),
      ajoutes: ((dernier?['creees'] as num?) ?? 0).toInt(),
      prochainPassage: DateTime.tryParse(json['prochain_passage'] as String? ?? '')?.toLocal(),
      horsLigne: dernier?['mode'] == 'hors_ligne',
    );
  }
}

/// `GET /veille/etat` : {actualites: {...}, opportunites: {...}}. Null si le service IA
/// ne répond pas — le bandeau garde alors son texte par défaut.
final veilleEtatProvider = FutureProvider<Map<String, EtatVeille>?>((ref) async {
  // Rechargé toutes les 5 min : sans cela, le bandeau restait figé sur l'état lu à
  // l'ouverture (« vérifiée il y a 20 h ») alors que la veille venait de repasser.
  final minuteur = Timer(const Duration(minutes: 5), ref.invalidateSelf);
  ref.onDispose(minuteur.cancel);
  try {
    final response = await ref.read(dioProvider).get(ApiEndpoints.veilleEtat);
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>?;
    if (data == null) return null;
    return data.map((module, etat) => MapEntry(module, EtatVeille.fromJson(etat as Map<String, dynamic>)));
  } catch (_) {
    return null;
  }
});
