import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Type de retour standard de tous les UseCase / Repository :
/// `Left(Failure)` en cas d'échec, `Right(T)` en cas de succès.
typedef Result<T> = Either<Failure, T>;
