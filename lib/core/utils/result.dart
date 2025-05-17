import 'package:movie_tickets/core/errors/failures.dart';

class Result<T> {
  final T? data;
  final Failure? failure;
  final Exception? exception;

  Result._({this.data, this.failure, this.exception});

  Result<T> fold<T>(Result<T> result, Function(T) onSuccess, Function(Failure) onFailure) {
    return result.isSuccess
        ? Result.success(onSuccess(result.data!))
        : Result.fromFailure(result.failure!);
  }

  static Result<T> success<T>(T data) => Result._(data: data);
  static Result<T> fromFailure<T>(Failure failure) => Result._(failure: failure);
  static Result<T> fromException<T>(Exception exception) => Result._(exception: exception);

  bool get isSuccess => data != null;
  bool get isFailure => failure != null;
  bool get isException => exception != null;
}
