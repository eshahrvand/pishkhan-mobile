part of 'card_issuance_cubit.dart';

enum IssuanceStep { selection, delivery, confirmation }

@Freezed(toStringOverride: false)
abstract class CardIssuanceState with _$CardIssuanceState {
  const factory CardIssuanceState.initial({
    @Default(RequestStatus.initial) RequestStatus catalogStatus,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    Failure? catalogFailure,
    Failure? submissionFailure,
    IssuanceCatalog? catalog,
    @Default(IssuanceDraft()) IssuanceDraft draft,
    @Default(IssuanceStep.selection) IssuanceStep step,
    @Default(1) int stepNumber,
    @Default(false) bool isSelectionComplete,
    @Default(false) bool isDeliveryComplete,
    @Default(false) bool isCatalogEmpty,
    @Default(false) bool isEditable,
    @Default(false) bool canContinue,
    @Default(<IssuanceFee>[]) List<IssuanceFee> fees,
    @Default(0) int totalRial,
    @Default(false) bool isWalletSufficient,
    @Default(true) bool isInvoiceExpanded,
    @Default(true) bool isSummaryExpanded,
    @Default(false) bool isRecipientNameValid,
    @Default(false) bool isRecipientNationalIdValid,
    @Default(false) bool isRecipientMobileValid,
    @Default(false) bool isRecipientValid,
    @Default(false) bool isAgentNameValid,
    @Default(false) bool isAgentCodeValid,
    @Default(false) bool isAgentValid,
    @Default('') String addressTitle,
    @Default('') String addressDetail,
    @Default('') String addressPostalCode,
    @Default(false) bool isAddressTitleValid,
    @Default(false) bool isAddressDetailValid,
    @Default(false) bool isAddressPostalCodeValid,
    @Default(false) bool isAddressFormError,
    @Default(0) int addressSavedId,
    IssuanceRequest? confirmedRequest,
    IssuanceReceipt? receipt,
    IssuanceEffect? effect,
    @Default(0) int effectId,
    FlowNavigation? navigation,
    @Default(0) int navigationId,
    @Default(0) int scrollId,
  }) = _CardIssuanceState;
}
