/// Jerarquía de errores de dominio.
sealed class Failure implements Exception {
  const Failure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class IntegrityFailure extends Failure {
  const IntegrityFailure(super.message);
}

class AssetLoadFailure extends Failure {
  const AssetLoadFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
