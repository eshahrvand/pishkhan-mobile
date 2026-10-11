import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../../../domain/entities/bank_deposit.dart';

part 'deposits_state.freezed.dart';

@freezed
abstract class DepositsState with _$DepositsState {
  const factory DepositsState({
    @Default(RequestStatus.initial) RequestStatus status,
    List<BankDeposit>? items,
    String? selectedId,
    Failure? failure,
  }) = _DepositsState;
}
