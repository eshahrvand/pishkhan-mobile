part of 'card_issuance_cubit.dart';

enum IssuanceStep { selection, delivery, confirmation }

@freezed
abstract class CardIssuanceState with _$CardIssuanceState {
  const factory CardIssuanceState.initial({
    @Default(false) bool isAddressFormError,
    IssuanceDeposit? deposit,
    IssuanceAddress? address,
    @Default(false) bool selectionComplete,
    @Default(false) bool deliveryComplete,
    @Default(<IssuanceFee>[]) List<IssuanceFee> fees,
    @Default(0) int totalRial,
    @Default(false) bool walletSufficient,
    @Default(false) bool editable,
    @Default(false) bool canContinue,
    IssuanceRequest? request,
    @Default(RequestStatus.initial) RequestStatus status,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    IssuanceCatalog? catalog,
    @Default(IssuanceDraft()) IssuanceDraft draft,
    @Default(IssuanceStep.selection) IssuanceStep step,
    @Default(true) bool invoiceExpanded,
    @Default(true) bool summaryExpanded,
    Failure? failure,
    IssuanceReceipt? receipt,
  }) = _CardIssuanceState;
}
