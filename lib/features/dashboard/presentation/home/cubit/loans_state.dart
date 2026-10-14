part of 'loans_cubit.dart';

@freezed
abstract class LoansState with _$LoansState {
  const factory LoansState.initial({
    @Default(RequestStatus.initial) RequestStatus status,
    List<BankLoan>? items,
    String? selectedId,
    @Default(<BankLoan>[]) List<BankLoan> visibleItems,
    @Default(0) int selectedIndex,
    BankLoan? selectedLoan,
    Failure? failure,
  }) = _LoansState;
}
