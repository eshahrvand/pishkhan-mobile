import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../../domain/entities/card_service_data.dart';

part 'change_card_deposit_state.freezed.dart';

@freezed
abstract class ChangeCardDepositState with _$ChangeCardDepositState {
  const ChangeCardDepositState._();
  const factory ChangeCardDepositState({
    @Default(RequestStatus.initial) RequestStatus status,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    CardServiceCatalog? catalog,
    String? cardId,
    String? destinationId,
    @Default(false) bool termsAccepted,
    Failure? failure,
    CardServiceReceipt? receipt,
  }) = _ChangeCardDepositState;

  ServiceBankCard? get card =>
      catalog?.cards.where((c) => c.id == cardId).firstOrNull;
  CardServiceDeposit? get source =>
      catalog?.deposits.where((d) => d.id == card?.depositId).firstOrNull;
  List<CardServiceDeposit> get destinations =>
      catalog?.deposits.where((d) => d.id != source?.id).toList() ?? [];
  CardServiceDeposit? get destination =>
      destinations.where((d) => d.id == destinationId).firstOrNull;
  bool get editable =>
      status == RequestStatus.success &&
      submissionStatus != RequestStatus.loading &&
      submissionStatus != RequestStatus.success;
  bool get walletSufficient =>
      catalog != null &&
      catalog!.walletBalanceRial >= catalog!.changeDepositFeeRial;
  bool get canSubmit =>
      editable &&
      card != null &&
      source != null &&
      destination != null &&
      termsAccepted &&
      walletSufficient;
}
