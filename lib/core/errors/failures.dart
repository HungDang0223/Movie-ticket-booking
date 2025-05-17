abstract class Failure {
  final String message;
  Failure(this.message);
}

class DioExceptionFailure extends Failure {
  DioExceptionFailure(super.message);
}

class ClientFailure extends Failure {
  ClientFailure(super.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class CacheFailure extends Failure {
  CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  NetworkFailure(super.message);
}

class UnexpectedFailure extends Failure {
  UnexpectedFailure(super.message);
}
