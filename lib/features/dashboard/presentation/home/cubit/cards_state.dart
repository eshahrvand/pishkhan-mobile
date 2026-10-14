part of 'cards_cubit.dart';

@freezed
abstract class CardsState with _$CardsState {
  const factory CardsState.initial({
    @Default(RequestStatus.initial) RequestStatus status,
    List<BankCard>? items,
    String? selectedId,
    @Default(<BankCard>[]) List<BankCard> visibleItems,
    @Default(0) int selectedIndex,
    BankCard? selectedCard,
    @Default({}) Map<String, bool> visibility,
    Failure? failure,
  }) = _CardsState;
}
