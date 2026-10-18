part of 'close_surplus_deposits_cubit.dart';

enum CloseSurplusDepositsStep { primaryDeposit, review }

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
    @Default(RequestStatus.initial) RequestStatus reviewStatus,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    @Default(CloseSurplusDepositsStep.primaryDeposit)
    CloseSurplusDepositsStep step,
    @Default(<ListedDeposit>[]) List<ListedDeposit> deposits,
    ListedDeposit? deposit,
    SurplusDepositReview? review,
    SurplusDepositClosureReceipt? receipt,
    Failure? depositsFailure,
    Failure? reviewFailure,
    Failure? submissionFailure,
    @Default(false) bool termsAccepted,
    @Default(false) bool canContinue,
    @Default(false) bool hasChanges,
    @Default(true) bool isEditable,
    @Default(false) bool isExitToAssistant,
    String? idempotencyKey,
    CloseSurplusDepositsEffect? effect,
    @Default(0) int effectId,
  }) = _CloseSurplusDepositsState;
}
