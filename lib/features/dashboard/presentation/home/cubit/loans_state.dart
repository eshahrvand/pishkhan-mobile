import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../../domain/entities/bank_loan.dart';

part 'loans_state.freezed.dart';

@freezed
abstract class LoansState with _$LoansState {
  const factory LoansState({
    @Default(RequestStatus.initial) RequestStatus status,
    List<BankLoan>? items,
    String? selectedId,
    Failure? failure,
  }) = _LoansState;
}
