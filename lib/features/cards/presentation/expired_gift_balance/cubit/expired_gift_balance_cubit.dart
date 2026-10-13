import 'dart:math';

import 'package:avp_ui/avp_ui.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/card_service_data.dart';
import '../../../domain/repositories/card_services_repository.dart';
import '../../../domain/usecases/card_services.dart';
import 'expired_gift_balance_state.dart';
export 'expired_gift_balance_state.dart';

class ExpiredGiftBalanceCubit extends Cubit<ExpiredGiftBalanceState> {
  ExpiredGiftBalanceCubit({
    ExpiredGiftBalanceState initialState = const ExpiredGiftBalanceState(),
    required this.repository,
  }) : super(initialState);
  final CardServicesRepository repository;
  int _generation = 0;
  String? _key;
  Future<void> load() async {
    if (state.submissionStatus == RequestStatus.loading) return;
    final generation = ++_generation;
    _key = null;
    _updateState(const ExpiredGiftBalanceState(status: RequestStatus.loading));
    final result = await LoadCardServiceCatalog(repository)();
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        _updateState(
          ExpiredGiftBalanceState(
            status: RequestStatus.failure,
            failure: failure,
          ),
        );
      case Success(:final data):
        _updateState(
          ExpiredGiftBalanceState(status: RequestStatus.success, catalog: data),
        );
    }
  }

  void search(String query) {
    if (state.selectionEditable) _updateState(state.copyWith(query: query));
  }

  void toggleCard(String id) {
    if (!state.selectionEditable ||
        !state.visibleCards.any((c) => c.id == id)) {
      return;
    }
    final ids = {...state.selectedIds};
    if (!ids.remove(id)) ids.add(id);
    _updateSelection(ids);
  }

  void selectAllVisible(bool value) {
    if (!state.selectionEditable) return;
    final visible = state.visibleCards.map((c) => c.id).toSet();
    _updateSelection(
      value
          ? {...state.selectedIds, ...visible}
          : state.selectedIds.difference(visible),
    );
  }

  void _updateSelection(Set<String> ids) {
    _key = null;
    _updateState(
      state.copyWith(
        selectedIds: ids,
        termsAccepted: false,
        submissionStatus: RequestStatus.initial,
        failure: null,
      ),
    );
  }

  void beginFilter() {
    if (!state.selectionEditable || !state.hasFilter) return;
    _updateState(
      state.copyWith(
        filterOpen: true,
        draftFilterDepositId: state.filterDepositId,
      ),
    );
  }

  void selectDraftFilter(String? id) {
    if (!state.editable ||
        !state.filterOpen ||
        (id != null && !state.catalog!.deposits.any((d) => d.id == id))) {
      return;
    }
    _updateState(state.copyWith(draftFilterDepositId: id));
  }

  void applyFilter() {
    if (!state.editable || !state.filterOpen) return;
    _updateState(
      state.copyWith(
        filterDepositId: state.draftFilterDepositId,
        filterOpen: false,
        draftFilterDepositId: null,
      ),
    );
  }

  void cancelFilter() {
    if (state.filterOpen) {
      _updateState(
        state.copyWith(filterOpen: false, draftFilterDepositId: null),
      );
    }
  }

  bool beginReview() {
    if (!state.canContinue || state.reviewOpen || state.filterOpen) {
      return false;
    }
    _updateState(state.copyWith(reviewOpen: true));
    return true;
  }

  void removeSelected(String id) {
    if (!state.editable ||
        !state.reviewOpen ||
        !state.selectedIds.contains(id)) {
      return;
    }
    _updateSelection({...state.selectedIds}..remove(id));
  }

  /// The sheet's Back action closes the review and advances only on step one.
  void finishReview({bool advance = false}) {
    if (!state.reviewOpen) return;
    _updateState(
      state.copyWith(
        reviewOpen: false,
        step: advance && state.selectedCards.isNotEmpty
            ? GiftBalanceStep.destination
            : state.selectedCards.isEmpty
            ? GiftBalanceStep.selection
            : state.step,
      ),
    );
  }

  void selectDestination(String id) {
    if (!state.editable ||
        state.step != GiftBalanceStep.destination ||
        state.reviewOpen ||
        id == state.destinationId ||
        !state.catalog!.deposits.any((d) => d.id == id)) {
      return;
    }
    _key = null;
    _updateState(
      state.copyWith(
        destinationId: id,
        termsAccepted: false,
        submissionStatus: RequestStatus.initial,
        failure: null,
      ),
    );
  }

  void acceptTerms(bool value) {
    if (state.editable &&
        state.step == GiftBalanceStep.destination &&
        !state.reviewOpen) {
      _updateState(state.copyWith(termsAccepted: value));
    }
  }

  bool back() {
    if (state.submissionStatus == RequestStatus.loading) return true;
    if (state.step == GiftBalanceStep.destination &&
        state.submissionStatus != RequestStatus.success) {
      _updateState(
        state.copyWith(step: GiftBalanceStep.selection, termsAccepted: false),
      );
      return true;
    }
    return false;
  }

  Future<void> submit() async {
    if (!state.canSubmit) return;
    _key ??= List.generate(
      16,
      (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    final request = GiftBalanceRequest(
      cardIds: state.selectedCards.map((c) => c.id),
      destinationDepositId: state.destinationId!,
      idempotencyKey: _key!,
    );
    final generation = ++_generation;
    _updateState(
      state.copyWith(submissionStatus: RequestStatus.loading, failure: null),
    );
    final result = await cardServiceBoundary(
      () => repository.transferGiftBalance(request),
    );
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        _updateState(
          state.copyWith(
            submissionStatus: RequestStatus.failure,
            failure: failure,
          ),
        );
      case Success(:final data):
        _updateState(
          state.copyWith(
            submissionStatus: RequestStatus.success,
            receipt: data,
          ),
        );
    }
  }

  String _normalizeNumber(String value) =>
      DigitNormalizer.normalize(value).replaceAll(RegExp(r'[\s-]'), '');

  // Search, selection totals and action eligibility belong to the Cubit.
  void _updateState(ExpiredGiftBalanceState next) {
    final editable =
        next.status == RequestStatus.success &&
        next.submissionStatus != RequestStatus.loading &&
        next.submissionStatus != RequestStatus.success;
    final search = _normalizeNumber(next.query);
    final visible =
        next.catalog?.gifts
            .where(
              (c) =>
                  c.balanceRial > 0 &&
                  (next.filterDepositId == null ||
                      c.depositId == next.filterDepositId) &&
                  _normalizeNumber(c.number).contains(search),
            )
            .toList() ??
        <ExpiredGiftCard>[];
    final selected =
        next.catalog?.gifts
            .where((c) => next.selectedIds.contains(c.id))
            .toList() ??
        <ExpiredGiftCard>[];
    final destination = next.catalog?.deposits
        .where((d) => d.id == next.destinationId)
        .firstOrNull;
    final canContinue = editable && selected.isNotEmpty;
    emit(
      next.copyWith(
        isEmpty:
            next.catalog?.gifts.isEmpty == true ||
            next.catalog?.deposits.isEmpty == true,
        editable: editable,
        selectionEditable:
            editable &&
            next.step == GiftBalanceStep.selection &&
            !next.reviewOpen &&
            !next.filterOpen,
        hasFilter: (next.catalog?.deposits.length ?? 0) >= 2,
        visibleCards: visible,
        selectedCards: selected,
        totalRial: selected.fold<int>(0, (sum, card) => sum + card.balanceRial),
        allVisibleSelected:
            visible.isNotEmpty &&
            visible.every((c) => next.selectedIds.contains(c.id)),
        destination: destination,
        canContinue: canContinue,
        canSubmit:
            canContinue &&
            next.step == GiftBalanceStep.destination &&
            destination != null &&
            next.termsAccepted &&
            !next.reviewOpen,
      ),
    );
  }

  @override
  Future<void> close() {
    _generation++;
    return super.close();
  }
}
