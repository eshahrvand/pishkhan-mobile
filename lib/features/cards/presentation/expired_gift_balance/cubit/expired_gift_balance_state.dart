import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../../domain/entities/card_service_data.dart';

part 'expired_gift_balance_state.freezed.dart';

enum GiftBalanceStep { selection, destination }

@freezed
abstract class ExpiredGiftBalanceState with _$ExpiredGiftBalanceState {
  const factory ExpiredGiftBalanceState({
    @Default(RequestStatus.initial) RequestStatus status,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    @Default(GiftBalanceStep.selection) GiftBalanceStep step,
    CardServiceCatalog? catalog,
    @Default(false) bool isEmpty,
    @Default(false) bool editable,
    @Default(false) bool selectionEditable,
    @Default(false) bool hasFilter,
    @Default(<ExpiredGiftCard>[]) List<ExpiredGiftCard> visibleCards,
    @Default(<ExpiredGiftCard>[]) List<ExpiredGiftCard> selectedCards,
    @Default(0) int totalRial,
    @Default(false) bool allVisibleSelected,
    CardServiceDeposit? destination,
    @Default(false) bool canContinue,
    @Default(false) bool canSubmit,
    @Default(<String>{}) Set<String> selectedIds,
    @Default('') String query,
    String? filterDepositId,
    String? draftFilterDepositId,
    @Default(false) bool filterOpen,
    @Default(false) bool reviewOpen,
    String? destinationId,
    @Default(false) bool termsAccepted,
    Failure? failure,
    CardServiceReceipt? receipt,
  }) = _ExpiredGiftBalanceState;
}
