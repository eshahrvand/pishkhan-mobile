part of 'virtual_card_cubit.dart';

@freezed
abstract class VirtualCardState with _$VirtualCardState {
  const factory VirtualCardState.initial({
    int? count,
    @Default(false) bool validCount,
    @Default(false) bool editable,
    @Default(false) bool canSubmit,
    @Default(RequestStatus.initial) RequestStatus status,
    @Default(RequestStatus.initial) RequestStatus quoteStatus,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    VirtualCardCatalog? catalog,
    String? depositId,
    @Default('') String countText,
    VirtualCardQuote? quote,
    @Default(false) bool terms,
    @Default(true) bool expanded,
    Failure? failure,
    VirtualCardReceipt? receipt,
  }) = _VirtualCardState;
}
