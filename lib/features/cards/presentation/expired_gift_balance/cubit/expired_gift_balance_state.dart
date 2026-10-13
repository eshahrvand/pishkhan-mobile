import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../../domain/entities/card_service_data.dart';

import 'package:avp_ui/avp_ui.dart';

part 'expired_gift_balance_state.freezed.dart';

enum GiftBalanceStep { selection, destination }

@freezed
abstract class ExpiredGiftBalanceState with _$ExpiredGiftBalanceState {
  const ExpiredGiftBalanceState._();
  const factory ExpiredGiftBalanceState({
    @Default(RequestStatus.initial) RequestStatus status,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    @Default(GiftBalanceStep.selection) GiftBalanceStep step,
    CardServiceCatalog? catalog,
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

  bool get editable =>
      status == RequestStatus.success &&
      submissionStatus != RequestStatus.loading &&
      submissionStatus != RequestStatus.success;
  bool get hasFilter => (catalog?.deposits.length ?? 0) >= 2;
  List<ExpiredGiftCard> get visibleCards {
    final search = normalizeGiftNumber(query);
    return catalog?.gifts
            .where(
              (c) =>
                  c.balanceRial > 0 &&
                  (filterDepositId == null || c.depositId == filterDepositId) &&
                  normalizeGiftNumber(c.number).contains(search),
            )
            .toList() ??
        [];
  }

  List<ExpiredGiftCard> get selectedCards =>
      catalog?.gifts.where((c) => selectedIds.contains(c.id)).toList() ?? [];
  int get totalRial =>
      selectedCards.fold(0, (sum, card) => sum + card.balanceRial);
  bool get allVisibleSelected =>
      visibleCards.isNotEmpty &&
      visibleCards.every((c) => selectedIds.contains(c.id));
  CardServiceDeposit? get destination =>
      catalog?.deposits.where((d) => d.id == destinationId).firstOrNull;
  bool get canContinue => editable && selectedCards.isNotEmpty;
  bool get canSubmit =>
      canContinue &&
      step == GiftBalanceStep.destination &&
      destination != null &&
      termsAccepted &&
      !reviewOpen;
}

String normalizeGiftNumber(String value) =>
    DigitNormalizer.normalize(value).replaceAll(RegExp(r'[\s-]'), '');
