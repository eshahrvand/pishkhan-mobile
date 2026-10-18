part of 'expired_gift_balance_cubit.dart';

enum GiftBalanceEffect { filter, review }

enum GiftBalanceStep { selection, destination }

@Freezed(toStringOverride: false)
abstract class ExpiredGiftBalanceState with _$ExpiredGiftBalanceState {
  const factory ExpiredGiftBalanceState.initial({
    GiftBalanceEffect? effect,
    @Default(0) int effectId,
    @Default(false) bool advanceAfterReview,
    FlowNavigation? navigation,
    @Default(0) int navigationId,
    @Default(RequestStatus.initial) RequestStatus catalogStatus,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    @Default(GiftBalanceStep.selection) GiftBalanceStep step,
    @Default(1) int stepNumber,
    CardServiceCatalog? catalog,
    @Default(false) bool isCatalogEmpty,
    @Default(false) bool isEditable,
    @Default(false) bool isFilterAvailable,
    @Default(<ExpiredGiftCard>[]) List<ExpiredGiftCard> visibleCards,
    @Default(<ExpiredGiftCard>[]) List<ExpiredGiftCard> selectedCards,
    @Default(0) int totalRial,
    @Default(false) bool isAllVisibleSelected,
    CardServiceDeposit? destination,
    @Default(<String, CardServiceDeposit>{})
    Map<String, CardServiceDeposit> depositsByGiftId,
    @Default(false) bool canReviewSelection,
    @Default(false) bool canContinue,
    @Default('') String query,
    @Default(<GiftBalanceDepositFilter>[])
    List<GiftBalanceDepositFilter> filterOptions,
    @Default(GiftBalanceDepositFilter.all())
    GiftBalanceDepositFilter activeFilter,
    @Default(GiftBalanceDepositFilter.all())
    GiftBalanceDepositFilter draftFilter,
    @Default(false) bool termsAccepted,
    Failure? catalogFailure,
    Failure? submissionFailure,
    CardServiceReceipt? receipt,
  }) = _ExpiredGiftBalanceState;
}
