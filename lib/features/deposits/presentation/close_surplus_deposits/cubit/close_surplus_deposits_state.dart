part of 'close_surplus_deposits_cubit.dart';

enum CloseSurplusDepositsStep { primaryDeposit, empty }

enum CloseSurplusDepositsEffect {
  confirmExit,
  back,
  home,
  assistant,
  termsUnavailable,
}

@Freezed(toStringOverride: false)
abstract class CloseSurplusDepositsState with _$CloseSurplusDepositsState {
  const factory CloseSurplusDepositsState.initial({
    @Default(RequestStatus.initial) RequestStatus depositsStatus,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    @Default(CloseSurplusDepositsStep.primaryDeposit)
    CloseSurplusDepositsStep step,
    @Default(<ListedDeposit>[]) List<ListedDeposit> deposits,
    ListedDeposit? deposit,
    SurplusDepositClosureReceipt? receipt,
    Failure? failure,
    String? message,

    @Default(false) bool termsAccepted,
    @Default(false) bool canContinue,
    @Default(false) bool hasChanges,
    @Default(true) bool isEditable,
    @Default(false) bool isExitToAssistant,
    String? idempotencyKey,
    CloseSurplusDepositsEffect? effect,
  }) = _CloseSurplusDepositsState;
}
