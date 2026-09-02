import '../utils/result.dart';

/// Contrat générique de tous les UseCase de la couche domain.
/// [Type] = type de retour en cas de succès, [Params] = paramètres d'entrée.
abstract interface class UseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

/// À utiliser quand un UseCase ne prend aucun paramètre.
final class NoParams {
  const NoParams();
}
