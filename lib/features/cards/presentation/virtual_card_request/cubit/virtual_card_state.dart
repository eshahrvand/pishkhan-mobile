import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../../domain/entities/virtual_card_data.dart';

part 'virtual_card_state.freezed.dart';

@freezed
abstract class VirtualCardState with _$VirtualCardState {
  const factory VirtualCardState({
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
