import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/card_service_data.dart';
import '../../../domain/repositories/card_services_repository.dart';
import '../../../domain/usecases/card_services.dart';
import 'expired_gift_balance_state.dart';
export 'expired_gift_balance_state.dart';

class ExpiredGiftBalanceCubit extends Cubit<ExpiredGiftBalanceState> {
  ExpiredGiftBalanceCubit({required this.repository})
    : super(const ExpiredGiftBalanceState());
  final CardServicesRepository repository;
  int _generation = 0;
  String? _key;
  Future<void> load() async {
    if (state.submissionStatus == RequestStatus.loading) return;
    final generation = ++_generation;
    _key = null;
    emit(const ExpiredGiftBalanceState(status: RequestStatus.loading));
    final result = await LoadCardServiceCatalog(repository)();
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        emit(
          ExpiredGiftBalanceState(
            status: RequestStatus.failure,
            failure: failure,
          ),
        );
      case Success(:final data):
        emit(
          ExpiredGiftBalanceState(status: RequestStatus.success, catalog: data),
        );
    }
  }

  bool get _selectionEditable =>
      state.editable &&
      state.step == GiftBalanceStep.selection &&
      !state.reviewOpen &&
      !state.filterOpen;
  void search(String query) {
    if (_selectionEditable) emit(state.copyWith(query: query));
  }

  void toggleCard(String id) {
    if (!_selectionEditable || !state.visibleCards.any((c) => c.id == id)) {
      return;
    }
    final ids = {...state.selectedIds};
    if (!ids.remove(id)) ids.add(id);
    _updateSelection(ids);
  }

  void selectAllVisible(bool value) {
    if (!_selectionEditable) return;
    final visible = state.visibleCards.map((c) => c.id).toSet();
    _updateSelection(
      value
          ? {...state.selectedIds, ...visible}
          : state.selectedIds.difference(visible),
    );
  }

  void _updateSelection(Set<String> ids) {
    _key = null;
    emit(
      state.copyWith(
        selectedIds: ids,
        termsAccepted: false,
        submissionStatus: RequestStatus.initial,
        failure: null,
      ),
    );
  }

  void beginFilter() {
    if (!_selectionEditable || !state.hasFilter) return;
    emit(
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
    emit(state.copyWith(draftFilterDepositId: id));
  }

  void applyFilter() {
    if (!state.editable || !state.filterOpen) return;
    emit(
      state.copyWith(
        filterDepositId: state.draftFilterDepositId,
        filterOpen: false,
        draftFilterDepositId: null,
      ),
    );
  }

  void cancelFilter() {
    if (state.filterOpen) {
      emit(state.copyWith(filterOpen: false, draftFilterDepositId: null));
    }
  }

  bool beginReview() {
    if (!state.canContinue || state.reviewOpen || state.filterOpen) {
      return false;
    }
    emit(state.copyWith(reviewOpen: true));
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
    emit(
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
    emit(
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
      emit(state.copyWith(termsAccepted: value));
    }
  }

  bool back() {
    if (state.submissionStatus == RequestStatus.loading) return true;
    if (state.step == GiftBalanceStep.destination &&
        state.submissionStatus != RequestStatus.success) {
      emit(
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
    emit(
      state.copyWith(submissionStatus: RequestStatus.loading, failure: null),
    );
    final result = await cardServiceBoundary(
      () => repository.transferGiftBalance(request),
    );
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.failure,
            failure: failure,
          ),
        );
      case Success(:final data):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.success,
            receipt: data,
          ),
        );
    }
  }

  @override
  Future<void> close() {
    _generation++;
    return super.close();
  }
}
