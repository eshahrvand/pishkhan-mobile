import '../../../domain/entities/password_data.dart';

sealed class PasswordEffect {
  const PasswordEffect();
}

final class PasswordExitRequested extends PasswordEffect {
  const PasswordExitRequested();
}

final class PasswordHomeRequested extends PasswordEffect {
  const PasswordHomeRequested();
}

final class PasswordExitConfirmationRequested extends PasswordEffect {
  const PasswordExitConfirmationRequested();
}

final class PasswordRecordRequested extends PasswordEffect {
  const PasswordRecordRequested(
    this.record,
    this.operation, {
    required this.newlySubmitted,
  });
  final PasswordRequestRecord record;
  final PasswordOperation operation;
  final bool newlySubmitted;
}

final class PasswordUnsupportedRequested extends PasswordEffect {
  const PasswordUnsupportedRequested();
}
