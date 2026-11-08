part of 'deposit_mandate_cubit.dart';

enum DepositMandateEffect {
  confirmExit,
  back,
  home,
  assistant,
  termsUnavailable,
}

@Freezed(toStringOverride: false)
abstract class DepositMandateState with _$DepositMandateState {
  const factory DepositMandateState.initial({
    @Default(RequestStatus.initial) RequestStatus catalogStatus,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    DepositMandateCatalog? catalog,
    @Default(<DepositMandateSubject>[]) List<DepositMandateSubject> subjects,
    @Default(<ListedDeposit>[]) List<ListedDeposit> deposits,
    DepositMandateCompany? company,
    DepositMandateSubject? subject,
    ListedDeposit? deposit,
    num? amountToman,
    @Default(false) bool termsAccepted,
    @Default(false) bool canSubmit,
    @Default(false) bool isEditable,
    @Default(false) bool hasChanges,
    @Default(false) bool isExitToAssistant,
    Failure? failure,
    String? message,

    String? idempotencyKey,
    DepositMandateReceipt? receipt,
    DepositMandateEffect? effect,
  }) = _DepositMandateState;
}
