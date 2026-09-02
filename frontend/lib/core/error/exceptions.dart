/// Exceptions techniques levées par la couche `data` (datasources).
/// Elles sont catchées par les `RepositoryImpl` et transformées en
/// [Failure] (voir failures.dart) avant de remonter à la couche domain/UI.
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({this.message = 'Erreur serveur', this.statusCode});
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'Pas de connexion internet'});
}

class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'Erreur de cache local'});
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException({this.message = 'Session expirée'});
}

/// Levée quand une tentative de connexion échoue et qu'aucun compte réel ne
/// correspond aux identifiants saisis — jamais de compte démo créé à la
/// volée en repli (voir MockAuthRemoteDataSource.login). Distincte de
/// [ValidationException] (email existant, mot de passe incorrect), qui
/// reste affichée en ligne sur l'écran de connexion.
class AccountNotFoundException implements Exception {
  final String message;
  const AccountNotFoundException({
    this.message = "Aucun compte n'est associé à ces identifiants. "
        'Veuillez vous inscrire pour continuer.',
  });
}

class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>>? errors;
  const ValidationException({
    this.message = 'Données invalides',
    this.errors,
  });
}
