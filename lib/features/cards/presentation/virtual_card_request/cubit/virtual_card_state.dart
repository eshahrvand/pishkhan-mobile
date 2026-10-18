part of 'virtual_card_cubit.dart';

enum VirtualCardRetryAction { quote, submission }

@Freezed(toStringOverride: false)
abstract class VirtualCardState with _$VirtualCardState {
  const factory VirtualCardState.initial({
    FlowNavigation? navigation,
    @Default(0) int navigationId,
    int? count,
    @Default(false) bool isCountValid,
    @Default(false) bool isCountError,
    @Default(false) bool isEditable,
    @Default(false) bool canSubmit,
    @Default(false) bool canRetry,
    VirtualCardRetryAction? retryAction,
    @Default(RequestStatus.initial) RequestStatus catalogStatus,
    @Default(RequestStatus.initial) RequestStatus quoteStatus,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    VirtualCardCatalog? catalog,
    VirtualCardDeposit? deposit,
    @Default('') String countText,
    VirtualCardQuote? quote,
    @Default(false) bool termsAccepted,
    @Default(true) bool isInvoiceExpanded,
    Failure? catalogFailure,
    Failure? quoteFailure,
    Failure? submissionFailure,
    VirtualCardReceipt? receipt,
  }) = _VirtualCardState;
}
