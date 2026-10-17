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
    if (isClosed ||
        state.filterOpen ||
        state.submissionStatus == RequestStatus.loading) {
      return;
    }
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
    if (isClosed || state.reviewOpen || !beginReview()) return;
    emit(
      state.copyWith(
        effect: GiftBalanceEffect.review,
        advanceAfterReview: advance,
        effectId: state.effectId + 1,
      ),
    );
  }

  void reviewResult(bool? proceed) {
    if (isClosed) return;
    finishReview(advance: state.advanceAfterReview && proceed == true);
  }

  Future<void> continueFlow() async {
    if (isClosed) return;
    if (state.step == GiftBalanceStep.selection) {
      if (state.canContinue) requestReview(advance: true);
    } else if (state.canSubmit) {
      await submit();
    }
  }

  void requestBack() {
    if (isClosed || state.submissionStatus == RequestStatus.loading) return;
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
    if (isClosed ||
        state.navigation != FlowNavigation.confirmExit ||
        state.submissionStatus == RequestStatus.loading) {
      return;
    }
    emit(
      state.copyWith(
        navigation: confirmed == true ? FlowNavigation.back : null,

        navigationId: state.navigationId + 1,
      ),
    );
  }

  void requestHome() {
    if (isClosed || state.submissionStatus == RequestStatus.loading) return;
    emit(
      state.copyWith(
        navigation: FlowNavigation.home,
        navigationId: state.navigationId + 1,
      ),
    );
  }

  Future<void> load() async {
    if (state.submissionStatus == RequestStatus.loading) return;
    final generation = ++_generation;
    _key = null;
    {
      final nextEditable = checkEditable(
        (RequestStatus.loading),
        (RequestStatus.initial),
      );
      final nextSearch = _normalizeNumber((''));
      final nextVisible = getVisible(
        (null as CardServiceCatalog?),
        (null as String?),
        nextSearch,
      );
      final nextSelected = getSelected(
        (null as CardServiceCatalog?),
        (<String>{}),
      );
      final nextDestination = getDestination(
        (null as CardServiceCatalog?),
        (null as String?),
      );
      final nextCanContinue = nextEditable && nextSelected.isNotEmpty;
      emit(
        ExpiredGiftBalanceState.initial(
          status: RequestStatus.loading,
          isEmpty:
              (null as CardServiceCatalog?)?.gifts.isEmpty == true ||
              (null as CardServiceCatalog?)?.deposits.isEmpty == true,
          editable: nextEditable,
          selectionEditable:
              nextEditable &&
              (GiftBalanceStep.selection) == GiftBalanceStep.selection &&
              true &&
              true,
          hasFilter: ((null as CardServiceCatalog?)?.deposits.length ?? 0) >= 2,
          visibleCards: nextVisible,
          selectedCards: nextSelected,
          totalRial: nextSelected.fold<int>(
            0,
            (sum, card) => sum + card.balanceRial,
          ),
          allVisibleSelected:
              nextVisible.isNotEmpty &&
              nextVisible.every((c) => (<String>{}).contains(c.id)),
          destination: nextDestination,
          canContinue: nextCanContinue,
          canSubmit: false,
        ),
      );
    }
    final result = await LoadCardServiceCatalog(repository)();
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        {
          final nextEditable = checkEditable(
            (RequestStatus.failure),
            (RequestStatus.initial),
          );
          final nextSearch = _normalizeNumber((''));
          final nextVisible = getVisible(
            (null as CardServiceCatalog?),
            (null as String?),
            nextSearch,
          );
          final nextSelected = getSelected(
            (null as CardServiceCatalog?),
            (<String>{}),
          );
          final nextDestination = getDestination(
            (null as CardServiceCatalog?),
            (null as String?),
          );
          final nextCanContinue = nextEditable && nextSelected.isNotEmpty;
          emit(
            ExpiredGiftBalanceState.initial(
              status: RequestStatus.failure,
              failure: failure,
              isEmpty:
                  (null as CardServiceCatalog?)?.gifts.isEmpty == true ||
                  (null as CardServiceCatalog?)?.deposits.isEmpty == true,
              editable: nextEditable,
              selectionEditable:
                  nextEditable &&
                  (GiftBalanceStep.selection) == GiftBalanceStep.selection &&
                  true &&
                  true,
              hasFilter:
                  ((null as CardServiceCatalog?)?.deposits.length ?? 0) >= 2,
              visibleCards: nextVisible,
              selectedCards: nextSelected,
              totalRial: nextSelected.fold<int>(
                0,
                (sum, card) => sum + card.balanceRial,
              ),
              allVisibleSelected:
                  nextVisible.isNotEmpty &&
                  nextVisible.every((c) => (<String>{}).contains(c.id)),
              destination: nextDestination,
              canContinue: nextCanContinue,
              canSubmit: false,
            ),
          );
        }
      case Success(:final data):
        {
          final nextEditable = checkEditable(
            (RequestStatus.success),
            (RequestStatus.initial),
          );
          final nextSearch = _normalizeNumber((''));
          final nextVisible = getVisible((data), (null as String?), nextSearch);
          final nextSelected = getSelected((data), (<String>{}));
          final nextDestination = getDestination((data), (null as String?));
          final nextCanContinue = nextEditable && nextSelected.isNotEmpty;
          emit(
            ExpiredGiftBalanceState.initial(
              status: RequestStatus.success,
              catalog: data,
              depositsByGiftId: depositsByGift(data),
              isEmpty:
                  (data).gifts.isEmpty == true ||
                  (data).deposits.isEmpty == true,
              editable: nextEditable,
              selectionEditable:
                  nextEditable &&
                  (GiftBalanceStep.selection) == GiftBalanceStep.selection &&
                  true &&
                  true,
              hasFilter: (data.deposits.length) >= 2,
              visibleCards: nextVisible,
              selectedCards: nextSelected,
              totalRial: nextSelected.fold<int>(
                0,
                (sum, card) => sum + card.balanceRial,
              ),
              allVisibleSelected:
                  nextVisible.isNotEmpty &&
                  nextVisible.every((c) => (<String>{}).contains(c.id)),
              destination: nextDestination,
              canContinue: nextCanContinue,
              canSubmit: false,
            ),
          );
        }
    }
  }

  void search(String query) {
    if (state.selectionEditable) {
      final nextSearch = _normalizeNumber((query));
      final nextVisible = getVisible(
        state.catalog,
        state.filterDepositId,
        nextSearch,
      );
      emit(
        state.copyWith(
          query: query,
          visibleCards: nextVisible,
          allVisibleSelected:
              nextVisible.isNotEmpty &&
              nextVisible.every((c) => state.selectedIds.contains(c.id)),
        ),
      );
    }
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
    {
      final nextEditable = checkEditable(state.status, (RequestStatus.initial));
      final nextSelected = getSelected(state.catalog, (ids));
      final nextCanContinue = nextEditable && nextSelected.isNotEmpty;
      emit(
        state.copyWith(
          selectedIds: ids,
          termsAccepted: false,
          submissionStatus: RequestStatus.initial,
          failure: null,
          editable: nextEditable,
          selectionEditable:
              nextEditable &&
              state.step == GiftBalanceStep.selection &&
              !state.reviewOpen &&
              !state.filterOpen,
          selectedCards: nextSelected,
          totalRial: nextSelected.fold<int>(
            0,
            (sum, card) => sum + card.balanceRial,
          ),
          allVisibleSelected:
              state.visibleCards.isNotEmpty &&
              state.visibleCards.every((c) => (ids).contains(c.id)),
          canContinue: nextCanContinue,
          canSubmit: false,
        ),
      );
    }
  }

  void beginFilter() {
    if (!state.selectionEditable || !state.hasFilter) return;
    {
      emit(
        state.copyWith(
          filterOpen: true,
          draftFilterDepositId: state.filterDepositId,
          selectionEditable: false,
        ),
      );
    }
  }

  void selectDraftFilter(String? id) {
    if (!state.editable ||
        !state.filterOpen ||
        (id != null && !state.catalog!.deposits.any((d) => d.id == id))) {
      return;
    }
    {
      emit(state.copyWith(draftFilterDepositId: id));
    }
  }

  void applyFilter() {
    if (!state.editable || !state.filterOpen) return;
    {
      final nextSearch = _normalizeNumber(state.query);
      final nextVisible = getVisible(
        state.catalog,
        (state.draftFilterDepositId),
        nextSearch,
      );
      emit(
        state.copyWith(
          filterDepositId: state.draftFilterDepositId,
          filterOpen: false,
          draftFilterDepositId: null,
          selectionEditable:
              state.editable &&
              state.step == GiftBalanceStep.selection &&
              !state.reviewOpen &&
              true,
          visibleCards: nextVisible,
          allVisibleSelected:
              nextVisible.isNotEmpty &&
              nextVisible.every((c) => state.selectedIds.contains(c.id)),
        ),
      );
    }
  }

  void cancelFilter() {
    if (state.filterOpen) {
      {
        emit(
          state.copyWith(
            filterOpen: false,
            draftFilterDepositId: null,
            selectionEditable:
                state.editable &&
                state.step == GiftBalanceStep.selection &&
                !state.reviewOpen &&
                true,
          ),
        );
      }
    }
  }

  bool beginReview() {
    if (!state.canContinue || state.reviewOpen || state.filterOpen) {
      return false;
    }
    {
      emit(
        state.copyWith(
          reviewOpen: true,
          selectionEditable: false,
          canSubmit: false,
        ),
      );
    }
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
    {
      emit(
        state.copyWith(
          reviewOpen: false,
          step: advance && state.selectedCards.isNotEmpty
              ? GiftBalanceStep.destination
              : state.selectedCards.isEmpty
              ? GiftBalanceStep.selection
              : state.step,
          selectionEditable:
              state.editable &&
              (advance && state.selectedCards.isNotEmpty
                      ? GiftBalanceStep.destination
                      : state.selectedCards.isEmpty
                      ? GiftBalanceStep.selection
                      : state.step) ==
                  GiftBalanceStep.selection &&
              true &&
              !state.filterOpen,
          canSubmit:
              state.canContinue &&
              (advance && state.selectedCards.isNotEmpty
                      ? GiftBalanceStep.destination
                      : state.selectedCards.isEmpty
                      ? GiftBalanceStep.selection
                      : state.step) ==
                  GiftBalanceStep.destination &&
              state.destination != null &&
              state.termsAccepted &&
              true,
        ),
      );
    }
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
    {
      final nextEditable = checkEditable(state.status, (RequestStatus.initial));
      final nextDestination = getDestination(state.catalog, (id));
      final nextCanContinue = nextEditable && state.selectedCards.isNotEmpty;
      emit(
        state.copyWith(
          destinationId: id,
          termsAccepted: false,
          submissionStatus: RequestStatus.initial,
          failure: null,
          editable: nextEditable,
          selectionEditable:
              nextEditable &&
              state.step == GiftBalanceStep.selection &&
              !state.reviewOpen &&
              !state.filterOpen,
          destination: nextDestination,
          canContinue: nextCanContinue,
          canSubmit: false,
        ),
      );
    }
  }

  void acceptTerms(bool value) {
    if (state.editable &&
        state.step == GiftBalanceStep.destination &&
        !state.reviewOpen) {
      {
        emit(
          state.copyWith(
            termsAccepted: value,
            canSubmit:
                state.canContinue &&
                state.step == GiftBalanceStep.destination &&
                state.destination != null &&
                (value) &&
                !state.reviewOpen,
          ),
        );
      }
    }
  }

  bool back() {
    if (state.submissionStatus == RequestStatus.loading) return true;
    if (state.step == GiftBalanceStep.destination &&
        state.submissionStatus != RequestStatus.success) {
      {
        emit(
          state.copyWith(
            step: GiftBalanceStep.selection,
            termsAccepted: false,
            selectionEditable:
                state.editable &&
                (GiftBalanceStep.selection) == GiftBalanceStep.selection &&
                !state.reviewOpen &&
                !state.filterOpen,
            canSubmit: false,
          ),
        );
      }
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
    {
      final nextEditable = checkEditable(state.status, (RequestStatus.loading));
      final nextCanContinue = nextEditable && state.selectedCards.isNotEmpty;
      emit(
        state.copyWith(
          submissionStatus: RequestStatus.loading,
          failure: null,
          editable: nextEditable,
          selectionEditable:
              nextEditable &&
              state.step == GiftBalanceStep.selection &&
              !state.reviewOpen &&
              !state.filterOpen,
          canContinue: nextCanContinue,
          canSubmit:
              nextCanContinue &&
              state.step == GiftBalanceStep.destination &&
              state.destination != null &&
              state.termsAccepted &&
              !state.reviewOpen,
        ),
      );
    }
    final result = await cardServiceBoundary(
      () => repository.transferGiftBalance(request),
    );
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        {
          final nextEditable = checkEditable(
            state.status,
            (RequestStatus.failure),
          );
          final nextCanContinue =
              nextEditable && state.selectedCards.isNotEmpty;
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.failure,
              failure: failure,
              editable: nextEditable,
              selectionEditable:
                  nextEditable &&
                  state.step == GiftBalanceStep.selection &&
                  !state.reviewOpen &&
                  !state.filterOpen,
              canContinue: nextCanContinue,
              canSubmit:
                  nextCanContinue &&
                  state.step == GiftBalanceStep.destination &&
                  state.destination != null &&
                  state.termsAccepted &&
                  !state.reviewOpen,
            ),
          );
        }
      case Success(:final data):
        {
          final nextEditable = checkEditable(
            state.status,
            (RequestStatus.success),
          );
          final nextCanContinue =
              nextEditable && state.selectedCards.isNotEmpty;
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.success,
              receipt: data,
              editable: nextEditable,
              selectionEditable:
                  nextEditable &&
                  state.step == GiftBalanceStep.selection &&
                  !state.reviewOpen &&
                  !state.filterOpen,
              canContinue: nextCanContinue,
              canSubmit:
                  nextCanContinue &&
                  state.step == GiftBalanceStep.destination &&
                  state.destination != null &&
                  state.termsAccepted &&
                  !state.reviewOpen,
            ),
          );
        }
    }
  }

  String _normalizeNumber(String value) =>
      DigitNormalizer.normalize(value).replaceAll(RegExp(r'[\s-]'), '');

  // Search, selection totals and action eligibility belong to the Cubit.

  @override
  Future<void> close() {
    _generation++;
    return super.close();
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
      for (final gift in catalog.gifts) gift.id: ?depositsById[gift.depositId],
    };
  }

  CardServiceDeposit? getDestination(
    CardServiceCatalog? catalog,
    String? destinationId,
  ) {
    return catalog?.deposits.where((d) => d.id == destinationId).firstOrNull;
  }
}
