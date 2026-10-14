part of 'deposits_cubit.dart';

@freezed
abstract class DepositsState with _$DepositsState {
  const factory DepositsState.initial({
    @Default(RequestStatus.initial) RequestStatus status,
    List<BankDeposit>? items,
    String? selectedId,
    @Default(<BankDeposit>[]) List<BankDeposit> visibleItems,
    @Default(0) int selectedIndex,
    BankDeposit? selectedDeposit,
    Failure? failure,
  }) = _DepositsState;
}
