part of 'transactions_cubit.dart';

enum WalletDateTarget { from, to }

@Freezed(toStringOverride: false)
abstract class WalletTransactionsState with _$WalletTransactionsState {
  const factory WalletTransactionsState.initial({
    @Default(RequestStatus.initial) RequestStatus transactionsStatus,
    @Default(<WalletReceipt>[]) List<WalletReceipt> transactions,
    @Default(WalletTransactionFilter()) WalletTransactionFilter filter,
    WalletFilterKind? filterKind,
    @Default(<WalletTransactionType>{}) Set<WalletTransactionType> draftTypes,
    WalletDatePeriod? draftPeriod,
    DateTime? draftFrom,
    DateTime? draftTo,
    WalletDateTarget? datePickerTarget,
    @Default('') String datePickerInput,
    DateTime? datePickerValue,
    @Default(false) bool isDatePickerError,
    @Default(false) bool canConfirmDate,
    @Default('') String draftMin,
    @Default('') String draftMax,
    int? draftMinRial,
    int? draftMaxRial,
    num? draftMinToman,
    num? draftMaxToman,
    @Default(true) bool isMinValid,
    @Default(true) bool isMaxValid,
    @Default(false) bool isAmountRangeError,
    @Default(false) bool isDateRangeError,
    @Default(true) bool canApply,
    Failure? failure,
    String? message,
  }) = _WalletTransactionsState;
}
