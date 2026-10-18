part of 'second_password_cubit.dart';

enum SecondPasswordStep { selection, password, serial, instruction, recording }

enum PasswordType { first, second }

enum PasswordPrimaryAction { continueFlow, startKyc, submit, changePassword }

@Freezed(toStringOverride: false)
abstract class SecondPasswordState with _$SecondPasswordState {
  const factory SecondPasswordState.initial({
    PasswordEffect? effect,
    @Default(0) int effectId,
    @Default(false) bool isFullStatusVisible,
    @Default(false) bool isPasswordVisible,
    @Default(false) bool isConfirmationVisible,
    @Default(false) bool isCurrentPasswordVisible,
    @Default(false) bool isConfirmationError,
    @Default(false) bool isSerialError,
    @Default(false) bool isEditable,
    @Default(false) bool isChange,
    @Default(true) bool isCurrentPasswordValid,
    PasswordCard? card,
    @Default(false) bool isSelectionComplete,
    @Default(false) bool isOperationSupported,
    @Default(false) bool isPasswordLengthValid,
    @Default(false) bool isPasswordPatternValid,
    @Default(false) bool isPasswordDateValid,
    @Default(true) bool isConfirmationValid,
    @Default(false) bool isFormComplete,
    @Default(false) bool isSerialValid,
    @Default(false) bool isWalletSufficient,
    @Default(false) bool canContinue,
    @Default(RequestStatus.initial) RequestStatus catalogStatus,
    @Default(RequestStatus.initial) RequestStatus existingRequestStatus,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    @Default(SecondPasswordStep.selection) SecondPasswordStep step,
    @Default(PasswordPrimaryAction.continueFlow)
    PasswordPrimaryAction primaryAction,
    PasswordCatalog? catalog,
    @Default(<PasswordCard>[]) List<PasswordCard> cardsForSelectedKind,
    @Default(PasswordOperation.setSecondPassword) PasswordOperation? operation,
    PasswordCardKind? kind,
    PasswordType? passwordType,
    @Default('') String password,
    @Default('') String currentPassword,
    @Default('') String confirmation,
    @Default('') String nationalCardSerial,
    @Default(false) bool termsAccepted,
    @Default(false) bool isRecordingConfirmed,
    PasswordRequestRecord? record,
    String? idempotencyKey,
    Failure? catalogFailure,
    Failure? existingRequestFailure,
    Failure? submissionFailure,
  }) = _SecondPasswordState;
}
