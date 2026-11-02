part of 'cheque_clearance_cubit.dart';

enum ChequeNumberError { invalid, notFound }

enum ChequeClearanceEffect {
  back,
  confirmExit,
  assistant,
  home,
  postalOffices,
  contentUnavailable,
}

@Freezed(toStringOverride: false)
abstract class ChequeClearanceState with _$ChequeClearanceState {
  const factory ChequeClearanceState.initial({
    @Default(RequestStatus.initial) RequestStatus catalogStatus,
    ChequeClearanceCatalog? catalog,
    Failure? failure,
    String? message,
    ChequeDeposit? deposit,
    @Default('') String chequeNumber,
    @Default(false) bool isChequeNumberValid,
    ChequeNumberError? chequeNumberError,
    ChequeClearanceReason? reason,
    ChequeClearanceDocument? requiredDocument,
    @Default(false) bool isJudicialLetterRequired,
    @Default(false) bool isConsentRequired,
    @Default('') String judicialLetterNumber,
    @Default(false) bool isJudicialLetterNumberValid,
    @Default(false) bool isJudicialLetterNumberError,
    @Default(false) bool termsAccepted,
    @Default(false) bool canSubmit,
    @Default(false) bool isEditable,
    @Default(false) bool hasChanges,
    @Default(false) bool isExitToAssistant,
    String? idempotencyKey,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,

    ChequeClearanceReceipt? receipt,
    ChequeClearanceEffect? effect,
  }) = _ChequeClearanceState;
}
