part of 'cheque_cancellation_cubit.dart';

enum ChequeCancellationStep { selection, cheques, reasons, confirmation }

enum ChequeCancellationEffect {
  review,
  reason,
  deleteCheque,
  deleteReviewCheque,
  postalOffices,
  contentUnavailable,
  receipt,
  confirmExit,
  back,
  home,
  assistant,
}

@Freezed(toStringOverride: false)
abstract class ChequeCancellationState with _$ChequeCancellationState {
  const factory ChequeCancellationState.initial({
    @Default(ChequeCancellationStep.selection) ChequeCancellationStep step,
    @Default(1) int stepNumber,
    @Default(RequestStatus.initial) RequestStatus catalogStatus,
    Failure? failure,
    String? message,
    ChequeCancellationCatalog? catalog,
    ChequeDeposit? deposit,
    CancellationChequeType? type,
    @Default(RequestStatus.initial) RequestStatus chequesStatus,

    @Default(<CancellableCheque>[]) List<CancellableCheque> cheques,
    @Default(<CancellationChequeChoice>[])
    List<CancellationChequeChoice> visibleCheques,
    @Default(<ChequeCancellationEntry>[])
    List<ChequeCancellationEntry> selectedEntries,
    @Default('') String searchQuery,
    @Default(false) bool isAllSelected,
    @Default(false) bool isEditable,
    @Default(false) bool canContinue,
    @Default(false) bool isReviewContinuing,
    @Default(false) bool isReasonForAll,
    CancellableCheque? pendingCheque,
    ChequeCancellationReason? reasonDraft,
    @Default(false) bool termsAccepted,
    ChequeCancellationRequest? confirmedRequest,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,

    ChequeCancellationReceipt? receipt,
    @Default(false) bool isExitToAssistant,
    ChequeCancellationEffect? effect,
  }) = _ChequeCancellationState;
}
