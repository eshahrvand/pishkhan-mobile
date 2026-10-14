import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.code);
  final String code;
  @override
  List<Object?> get props => [code];
}

final class DataFailure extends Failure {
  const DataFailure(super.code);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure() : super('unexpected');
}
