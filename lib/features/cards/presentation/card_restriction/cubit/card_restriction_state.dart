part of 'card_restriction_cubit.dart';

enum CardRestrictionEffect {
  confirmBlock,
  confirmExit,
  back,
  home,
  termsUnavailable,
}

@Freezed(toStringOverride: false)
abstract class CardRestrictionState with _$CardRestrictionState {
  const factory CardRestrictionState.initial({
    @Default(RequestStatus.initial) RequestStatus catalogStatus,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    CardRestrictionCatalog? catalog,
    RestrictionCard? card,
    CardRestrictionReason? reason,
    @Default('') String description,
    @Default(false) bool termsAccepted,
    @Default(false) bool isWalletSufficient,
    @Default(false) bool isEditable,
    @Default(false) bool isInvoiceExpanded,
    @Default(false) bool canSubmit,
    @Default(false) bool hasChanges,
    String? idempotencyKey,
    CardServiceReceipt? receipt,
    Failure? failure,
    String? message,
    CardRestrictionEffect? effect,
  }) = _CardRestrictionState;
}
