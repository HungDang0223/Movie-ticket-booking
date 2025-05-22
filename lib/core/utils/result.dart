import 'package:movie_tickets/core/errors/failures.dart';

class Result<T> {
  final T? data;
  final Failure? failure;
  final Exception? exception;

  Result._({this.data, this.failure, this.exception});

  void when({
    required Function(T) success,
    required Function(Failure) failure,
  }) {
    if (isSuccess && data != null) {
      success(data as T);
    } else if (isFailure && this.failure != null) {
      failure(this.failure!);
    }
  }

  Future<void> whenAsync({
    required Future<void> Function(T) success,
    required Future<void> Function(Failure) failure,
  }) async {
    if (isSuccess && data != null) {
      await success(data as T);
    } else if (isFailure && this.failure != null) {
      await failure(this.failure!);
    }
  }

  Result<T> fold<T>(Result<T> result, Function(T) onSuccess, Function(Failure) onFailure) {
    return result.isSuccess
        ? Result.success(onSuccess(result.data as T))
        : Result.fromFailure(result.failure!);
  }

  static Result<T> success<T>(T data) => Result._(data: data);
  static Result<T> fromFailure<T>(Failure failure) => Result._(failure: failure);
  static Result<T> fromException<T>(Exception exception) => Result._(exception: exception);

  bool get isSuccess => data != null;
  bool get isFailure => failure != null;
  bool get isException => exception != null;
}
