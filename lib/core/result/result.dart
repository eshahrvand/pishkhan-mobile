import 'failure.dart';

sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
