part of 'cheque_book_cubit.dart';

enum ChequeBookStep { selection, checking, residency, delivery, confirmation }

enum ChequeBookEffect {
  back,
  home,
  assistant,
  confirmExit,
  deleteAddress,
  addAddress,
  registry,
  contentUnavailable,
  receipt,
}

enum ChequeBookAction { next, understood, submit }

@Freezed(toStringOverride: false)
abstract class ChequeBookState with _$ChequeBookState {
  const factory ChequeBookState.initial({
    @Default(ChequeBookStep.selection) ChequeBookStep step,
    @Default(1) int stepNumber,
    @Default(ChequeBookAction.next) ChequeBookAction primaryAction,
    @Default(RequestStatus.initial) RequestStatus catalogStatus,
    @Default(RequestStatus.initial) RequestStatus residencyStatus,
    @Default(RequestStatus.initial) RequestStatus addressDeletionStatus,
    @Default(RequestStatus.initial) RequestStatus addressSaveStatus,
    @Default(RequestStatus.initial) RequestStatus quoteStatus,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    ChequeBookCatalog? catalog,
    ChequeBookDeposit? deposit,
    int? leafCount,
    @Default(<int>[]) List<int> leafCounts,
    ChequeBookResidency? residency,
    @Default(<DeliveryAddress>[]) List<DeliveryAddress> deliveryAddresses,
    DeliveryAddress? address,
    DeliveryAddress? pendingAddress,
    @Default(false) bool isAddressDeletionAvailable,
    @Default(false) bool hasRegisteredResidence,
    @Default(false) bool isOtherRecipient,
    @Default(false) bool isRecipientRequired,
    @Default(false) bool isAgentIncluded,
    @Default('') String recipientName,
    @Default('') String recipientNationalId,
    @Default('') String agentIdentifier,
    @Default(false) bool isRecipientNameValid,
    @Default(false) bool isRecipientNationalIdValid,
    @Default(false) bool isRecipientNameError,
    @Default(false) bool isRecipientNationalIdError,
    @Default(true) bool isSummaryExpanded,
    @Default(true) bool isInvoiceExpanded,
    @Default(false) bool isWalletSufficient,
    @Default(0) int totalRial,
    @Default(false) bool canContinue,
    @Default(false) bool hasChanges,
    @Default(false) bool isEditable,
    @Default(false) bool isExitToAssistant,
    ChequeBookQuote? quote,
    ChequeBookDraft? confirmedDraft,
    String? idempotencyKey,
    ChequeBookReceipt? receipt,
    Failure? failure,
    String? message,

    ChequeBookEffect? effect,
  }) = _ChequeBookState;
}
