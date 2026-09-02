import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// Erreurs "métier" exposées à la couche presentation. Toujours un message
/// clair en français, jamais de détail technique brut affiché à l'écran.
@freezed
sealed class Failure with _$Failure {
  const factory Failure.server({
    @Default('Une erreur est survenue côté serveur. Réessayez plus tard.')
    String message,
    int? statusCode,
  }) = ServerFailure;

  const factory Failure.network({
    @Default('Pas de connexion internet. Vérifiez votre réseau.')
    String message,
  }) = NetworkFailure;

  const factory Failure.cache({
    @Default('Impossible de lire les données locales.') String message,
  }) = CacheFailure;

  const factory Failure.unauthorized({
    @Default('Votre session a expiré. Veuillez vous reconnecter.')
    String message,
  }) = UnauthorizedFailure;

  /// Connexion refusée car aucun compte réel ne correspond aux identifiants
  /// saisis — la présentation redirige vers l'inscription plutôt que
  /// d'afficher une simple erreur en ligne (voir login_screen.dart).
  const factory Failure.accountNotFound({
    @Default("Aucun compte n'est associé à ces identifiants. "
        'Veuillez vous inscrire pour continuer.')
    String message,
  }) = AccountNotFoundFailure;

  const factory Failure.validation({
    @Default('Certains champs sont invalides.') String message,
    Map<String, List<String>>? errors,
  }) = ValidationFailure;

  const factory Failure.unexpected({
    @Default('Une erreur inattendue est survenue.') String message,
  }) = UnexpectedFailure;
}
