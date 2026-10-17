import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/flow/flow_navigation.dart';
export 'package:pishkhan_mobile/core/flow/flow_navigation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import 'dart:math';

import 'package:avp_ui/avp_ui.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/card_service_data.dart';
import '../../../domain/repositories/card_services_repository.dart';
import '../../../domain/usecases/card_services.dart';

part 'expired_gift_balance_state.dart';
part 'expired_gift_balance_cubit.freezed.dart';

class ExpiredGiftBalanceCubit extends Cubit<ExpiredGiftBalanceState> {
  ExpiredGiftBalanceCubit({
    ExpiredGiftBalanceState initialState =
        const ExpiredGiftBalanceState.initial(),
  }) : super(initialState);
  final repository = getIt<CardServicesRepository>();
  int _generation = 0;
  String? _key;
  void requestFilter() {
    if (state.filterOpen) return;
    beginFilter();
    if (!state.filterOpen) return;
    emit(
      state.copyWith(
        effect: GiftBalanceEffect.filter,
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestReview({bool advance = false}) {
    if (state.reviewOpen || !beginReview()) return;
    emit(
      state.copyWith(
        effect: GiftBalanceEffect.review,
        advanceAfterReview: advance,
        effectId: state.effectId + 1,
      ),
    );
  }

  void reviewResult(bool? proceed) {
    finishReview(advance: state.advanceAfterReview && proceed == true);
  }

  Future<void> continueFlow() {
    if (state.step == GiftBalanceStep.selection) {
      if (state.canContinue) requestReview(advance: true);
      return Future.value();
    }
    return submit();
  }

  void requestBack() {
    if (back()) return;
    if (state.navigation == FlowNavigation.confirmExit ||
        state.navigation == FlowNavigation.back) {
      return;
    }
    final needsConfirmation =
        state.submissionStatus != RequestStatus.success &&
        state.status == RequestStatus.success &&
        (state.selectedIds.isNotEmpty ||
            state.destinationId != null ||
            state.termsAccepted);
    emit(
      state.copyWith(
        navigation: needsConfirmation
            ? FlowNavigation.confirmExit
            : FlowNavigation.back,
        navigationId: state.navigationId + 1,
      ),
    );
  }

  void exitConfirmationResult(bool? confirmed) {
    emit(
      state.copyWith(
        navigation: confirmed == true ? FlowNavigation.back : null,
        navigationId: state.navigationId + 1,
      ),
    );
  }

  void requestHome() {
    emit(
      state.copyWith(
        navigation: FlowNavigation.home,
        navigationId: state.navigationId + 1,
      ),
    );
  }

  Future<void> load() {
    if (state.submissionStatus == RequestStatus.loading) return Future.value();
    final generation = ++_generation;
    _key = null;
    emit(
      _derive(
        const ExpiredGiftBalanceState.initial(
          status: RequestStatus.loading,
        ),
      ),
    );
    return LoadCardServiceCatalog(repository)().then((result) {
      if (isClosed || generation != _generation) return;
      switch (result) {
        case Err(:final failure):
          emit(
            _derive(
              ExpiredGiftBalanceState.initial(
                status: RequestStatus.failure,
                failure: failure,
              ),
            ),
          );
        case Success(:final data):
          emit(
            _derive(
              ExpiredGiftBalanceState.initial(
                status: RequestStatus.success,
                catalog: data,
                depositsByGiftId: depositsByGift(data),
              ),
            ),
          );
      }
    });
  }

  void search(String query) {
    if (!state.selectionEditable) return;
    emit(_derive(state.copyWith(query: query)));
  }

  void toggleCard(String id) {
    if (!state.selectionEditable ||
        !state.visibleCards.any((c) => c.id == id)) {
      return;
    }
    final ids = {...state.selectedIds};
    if (!ids.remove(id)) ids.add(id);
    _key = null;
    emit(
      _derive(
        state.copyWith(
          selectedIds: ids,
          termsAccepted: false,
          submissionStatus: RequestStatus.initial,
          failure: null,
        ),
      ),
    );
  }

  void selectAllVisible(bool value) {
    if (!state.selectionEditable) return;
    final visible = state.visibleCards.map((c) => c.id).toSet();
    _key = null;
    emit(
      _derive(
        state.copyWith(
          selectedIds: value
              ? {...state.selectedIds, ...visible}
              : state.selectedIds.difference(visible),
          termsAccepted: false,
          submissionStatus: RequestStatus.initial,
          failure: null,
        ),
      ),
    );
  }

  void beginFilter() {
    if (!state.selectionEditable || !state.hasFilter) return;
    emit(
      state.copyWith(
        filterOpen: true,
        draftFilterDepositId: state.filterDepositId,
        selectionEditable: false,
      ),
    );
  }

  void selectDraftFilter(String? id) {
    if (!state.editable ||
        !state.filterOpen ||
        (id != null && state.catalog?.deposits.any((d) => d.id == id) != true)) {
      return;
    }
    emit(state.copyWith(draftFilterDepositId: id));
  }

  void applyFilter() {
    if (!state.editable || !state.filterOpen) return;
    emit(
      _derive(
        state.copyWith(
          filterDepositId: state.draftFilterDepositId,
          filterOpen: false,
          draftFilterDepositId: null,
        ),
      ),
    );
  }

  void cancelFilter() {
    if (!state.filterOpen) return;
    emit(
      state.copyWith(
        filterOpen: false,
        draftFilterDepositId: null,
        selectionEditable: state.editable &&
            state.step == GiftBalanceStep.selection &&
            !state.reviewOpen,
      ),
    );
  }

  bool beginReview() {
    if (!state.canContinue || state.reviewOpen || state.filterOpen) {
      return false;
    }
    emit(
      state.copyWith(
        reviewOpen: true,
        selectionEditable: false,
        canSubmit: false,
      ),
    );
    return true;
  }

  void removeSelected(String id) {
    if (!state.editable ||
        !state.reviewOpen ||
        !state.selectedIds.contains(id)) {
      return;
    }
    final ids = {...state.selectedIds}..remove(id);
    _key = null;
    emit(
      _derive(
        state.copyWith(
          selectedIds: ids,
          termsAccepted: false,
          submissionStatus: RequestStatus.initial,
          failure: null,
        ),
      ),
    );
  }

  /// The sheet's Back action closes the review and advances only on step one.
  void finishReview({bool advance = false}) {
    if (!state.reviewOpen) return;
    final nextStep = advance && state.selectedCards.isNotEmpty
        ? GiftBalanceStep.destination
        : state.selectedCards.isEmpty
            ? GiftBalanceStep.selection
            : state.step;
    emit(
      _derive(
        state.copyWith(
          reviewOpen: false,
          step: nextStep,
        ),
      ),
    );
  }

  void selectDestination(String id) {
    if (!state.editable ||
        state.step != GiftBalanceStep.destination ||
        state.reviewOpen ||
        id == state.destinationId ||
        state.catalog?.deposits.any((d) => d.id == id) != true) {
      return;
    }
    _key = null;
    emit(
      _derive(
        state.copyWith(
          destinationId: id,
          termsAccepted: false,
          submissionStatus: RequestStatus.initial,
          failure: null,
        ),
      ),
    );
  }

  void acceptTerms(bool value) {
    if (!state.reviewOpen) {
      emit(_derive(state.copyWith(termsAccepted: value)));
    }
  }

  bool back() {
    if (state.step == GiftBalanceStep.destination &&
        state.submissionStatus != RequestStatus.success) {
      emit(
        _derive(
          state.copyWith(
            step: GiftBalanceStep.selection,
            termsAccepted: false,
          ),
        ),
      );
      return true;
    }
    return false;
  }

  Future<void> submit() {
    if (!state.canSubmit) return Future.value();
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
      _derive(
        state.copyWith(
          submissionStatus: RequestStatus.loading,
          failure: null,
        ),
      ),
    );
    return cardServiceBoundary(
      () => repository.transferGiftBalance(request),
    ).then((result) {
      if (isClosed || generation != _generation) return;
      switch (result) {
        case Err(:final failure):
          emit(
            _derive(
              state.copyWith(
                submissionStatus: RequestStatus.failure,
                failure: failure,
              ),
            ),
          );
        case Success(:final data):
          emit(
            _derive(
              state.copyWith(
                submissionStatus: RequestStatus.success,
                receipt: data,
              ),
            ),
          );
      }
    });
  }

  String _normalizeNumber(String value) =>
      DigitNormalizer.normalize(value).replaceAll(RegExp(r'[\s-]'), '');

  @override
  Future<void> close() {
    _generation++;
    return super.close();
  }

  ExpiredGiftBalanceState _derive(ExpiredGiftBalanceState s) {
    final search = _normalizeNumber(s.query);
    final visibleCards = getVisible(s.catalog, s.filterDepositId, search);
    final selectedCards = getSelected(s.catalog, s.selectedIds);
    final totalRial = selectedCards.fold<int>(
      0,
      (sum, card) => sum + card.balanceRial,
    );
    final allVisibleSelected = visibleCards.isNotEmpty &&
        visibleCards.every((c) => s.selectedIds.contains(c.id));
    final destination = getDestination(s.catalog, s.destinationId);
    final hasFilter = (s.catalog?.deposits.length ?? 0) >= 2;
    final isEmpty = s.catalog != null &&
        (s.catalog!.gifts.isEmpty || s.catalog!.deposits.isEmpty);
    final editable = checkEditable(s.status, s.submissionStatus);
    final selectionEditable = editable &&
        s.step == GiftBalanceStep.selection &&
        !s.reviewOpen &&
        !s.filterOpen;
    final canContinue = editable && selectedCards.isNotEmpty;
    final canSubmit = canContinue &&
        s.step == GiftBalanceStep.destination &&
        destination != null &&
        s.termsAccepted &&
        !s.reviewOpen;

    return s.copyWith(
      visibleCards: visibleCards,
      selectedCards: selectedCards,
      totalRial: totalRial,
      allVisibleSelected: allVisibleSelected,
      destination: destination,
      hasFilter: hasFilter,
      isEmpty: isEmpty,
      editable: editable,
      selectionEditable: selectionEditable,
      canContinue: canContinue,
      canSubmit: canSubmit,
    );
  }

  bool checkEditable(RequestStatus status, RequestStatus submissionStatus) {
    return status == RequestStatus.success &&
        submissionStatus != RequestStatus.loading &&
        submissionStatus != RequestStatus.success;
  }

  List<ExpiredGiftCard> getVisible(
    CardServiceCatalog? catalog,
    String? filterDepositId,
    String search,
  ) {
    return catalog?.gifts
            .where(
              (c) =>
                  c.balanceRial > 0 &&
                  (filterDepositId == null || c.depositId == filterDepositId) &&
                  _normalizeNumber(c.number).contains(search),
            )
            .toList() ??
        <ExpiredGiftCard>[];
  }

  List<ExpiredGiftCard> getSelected(
    CardServiceCatalog? catalog,
    Set<String> selectedIds,
  ) {
    return catalog?.gifts.where((c) => selectedIds.contains(c.id)).toList() ??
        <ExpiredGiftCard>[];
  }

  Map<String, CardServiceDeposit> depositsByGift(CardServiceCatalog catalog) {
    final depositsById = {
      for (final deposit in catalog.deposits) deposit.id: deposit,
    };
    return {
      for (final gift in catalog.gifts)
        if (depositsById[gift.depositId] != null)
          gift.id: depositsById[gift.depositId]!,
    };
  }

  CardServiceDeposit? getDestination(
    CardServiceCatalog? catalog,
    String? destinationId,
  ) {
    return catalog?.deposits.where((d) => d.id == destinationId).firstOrNull;
  }
}
