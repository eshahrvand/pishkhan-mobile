part of 'deposit_restriction_cubit.dart';

enum DepositRestrictionEffect {
  confirmExit,
  back,
  home,
  assistant,
  termsUnavailable,
}

@Freezed(toStringOverride: false)
abstract class DepositRestrictionState with _$DepositRestrictionState {
  const factory DepositRestrictionState.initial({
    @Default(RequestStatus.initial) RequestStatus catalogStatus,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    DepositRestrictionCatalog? catalog,
    DepositRestrictionOption? deposit,
    DepositRestrictionReason? reason,
    @Default('') String description,
    @Default(false) bool termsAccepted,
    @Default(false) bool isWalletSufficient,
    @Default(false) bool canSubmit,
    @Default(false) bool isEditable,
    @Default(false) bool hasChanges,
    @Default(false) bool isExitToAssistant,
    Failure? catalogFailure,
    Failure? submissionFailure,
    String? idempotencyKey,
    DepositRestrictionReceipt? receipt,
    DepositRestrictionEffect? effect,
    @Default(0) int effectId,
  }) = _DepositRestrictionState;
}
