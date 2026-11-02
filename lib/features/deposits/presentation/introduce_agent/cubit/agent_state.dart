part of 'agent_cubit.dart';

enum AgentEffect { addNext, confirmExit, back, home }

@Freezed(toStringOverride: false)
abstract class AgentState with _$AgentState {
  const factory AgentState.initial({
    @Default(RequestStatus.initial) RequestStatus depositsStatus,
    @Default(<ListedDeposit>[]) List<ListedDeposit> deposits,
    Failure? failure,
    String? message,
    ListedDeposit? deposit,
    AgentOperation? operation,
    @Default('') String nationalId,
    @Default(false) bool isNationalIdValid,
    @Default(false) bool isNationalIdError,
    @Default('') String validityText,
    DateTime? validUntil,
    @Default(false) bool isValidityValid,
    @Default(false) bool isValidityError,
    @Default(false) bool canSaveDraft,
    @Default(<PendingAgent>[]) List<PendingAgent> agents,
    @Default(false) bool hasChanges,
    @Default(false) bool termsAccepted,
    @Default(false) bool canSubmit,
    @Default(true) bool isEditable,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,

    AgentReceipt? receipt,
    AgentEffect? effect,

    @Default(false) bool isExitToHome,
  }) = _AgentState;
}
