import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../../domain/entities/card_service_data.dart';

part 'change_card_deposit_state.freezed.dart';

@freezed
abstract class ChangeCardDepositState with _$ChangeCardDepositState {
  const factory ChangeCardDepositState({
    @Default(RequestStatus.initial) RequestStatus status,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    CardServiceCatalog? catalog,
    String? cardId,
    ServiceBankCard? card,
    CardServiceDeposit? source,
    @Default(<CardServiceDeposit>[]) List<CardServiceDeposit> destinations,
    CardServiceDeposit? destination,
    @Default(false) bool isEmpty,
    @Default(false) bool editable,
    @Default(false) bool walletSufficient,
    @Default(false) bool canSubmit,
    String? destinationId,
    @Default(false) bool termsAccepted,
    Failure? failure,
    CardServiceReceipt? receipt,
  }) = _ChangeCardDepositState;
}
