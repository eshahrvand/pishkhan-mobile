part of 'expired_gift_balance_cubit.dart';

enum GiftBalanceEffect { filter, review }

enum GiftBalanceStep { selection, destination }

@freezed
abstract class ExpiredGiftBalanceState with _$ExpiredGiftBalanceState {
  const factory ExpiredGiftBalanceState.initial({
    GiftBalanceEffect? effect,
    @Default(0) int effectId,
    @Default(false) bool advanceAfterReview,
    FlowNavigation? navigation,
    @Default(0) int navigationId,
    @Default(RequestStatus.initial) RequestStatus status,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    @Default(GiftBalanceStep.selection) GiftBalanceStep step,
    CardServiceCatalog? catalog,
    @Default(false) bool isEmpty,
    @Default(false) bool editable,
    @Default(false) bool selectionEditable,
    @Default(false) bool hasFilter,
    @Default(<ExpiredGiftCard>[]) List<ExpiredGiftCard> visibleCards,
    @Default(<ExpiredGiftCard>[]) List<ExpiredGiftCard> selectedCards,
    @Default(0) int totalRial,
    @Default(false) bool allVisibleSelected,
    CardServiceDeposit? destination,
    @Default(<String, CardServiceDeposit>{})
    Map<String, CardServiceDeposit> depositsByGiftId,
    @Default(false) bool canContinue,
    @Default(false) bool canSubmit,
    @Default(<String>{}) Set<String> selectedIds,
    @Default('') String query,
    String? filterDepositId,
    String? draftFilterDepositId,
    @Default(false) bool filterOpen,
    @Default(false) bool reviewOpen,
    String? destinationId,
    @Default(false) bool termsAccepted,
    Failure? failure,
    CardServiceReceipt? receipt,
  }) = _ExpiredGiftBalanceState;
}
