import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../../domain/entities/bank_card.dart';

part 'cards_state.freezed.dart';

@freezed
abstract class CardsState with _$CardsState {
  const factory CardsState({
    @Default(RequestStatus.initial) RequestStatus status,
    List<BankCard>? items,
    String? selectedId,
    @Default({}) Map<String, bool> visibility,
    Failure? failure,
  }) = _CardsState;
}
