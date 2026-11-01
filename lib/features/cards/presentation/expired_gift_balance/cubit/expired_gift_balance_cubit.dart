import 'dart:math';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/flow/flow_navigation.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/card_service_data.dart';
import '../../../domain/repositories/card_services_repository.dart';
import '../../../domain/usecases/card_services_usecase.dart';
import '../models/gift_balance_deposit_filter.dart';

export 'package:pishkhan_mobile/core/flow/flow_navigation.dart';

part 'expired_gift_balance_state.dart';
part 'expired_gift_balance_cubit.freezed.dart';

class ExpiredGiftBalanceCubit extends Cubit<ExpiredGiftBalanceState> {
  ExpiredGiftBalanceCubit({
    ExpiredGiftBalanceState initialState =
        const ExpiredGiftBalanceState.initial(),
  }) : super(initialState);

  final loadCardServiceCatalogUseCase = getIt<LoadCardServiceCatalogUseCase>();
  final _repository = getIt<CardServicesRepository>();
  String? _idempotencyKey;

  Future<void> fetchCatalog() async {
    emit(state.copyWith(catalogStatus: RequestStatus.loading));
    final result = await loadCardServiceCatalogUseCase();
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            catalogStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
      case Success(:final data):
        emit(
          state.copyWith(
            catalogStatus: RequestStatus.success,
            catalog: data,
            visibleCards: _filterGiftCards(
              data,
              state.activeFilter,
              state.query,
            ),
            depositsByGiftId: _depositsByGiftId(data),
            filterOptions: [
              const GiftBalanceDepositFilter.all(),
              for (final deposit in data.deposits)
                GiftBalanceDepositFilter.forDeposit(deposit),
            ],
            isFilterAvailable: data.deposits.length >= 2,
            isCatalogEmpty: data.gifts.isEmpty || data.deposits.isEmpty,
            isEditable: true,
          ),
        );
    }
  }

  void updateSearchQuery(String query) {
    final visible = _filterGiftCards(state.catalog!, state.activeFilter, query);
    emit(
      state.copyWith(
        query: query,
        visibleCards: visible,
        isAllVisibleSelected: _allVisibleSelected(visible, state.selectedCards),
      ),
    );
  }

  void toggleCard(ExpiredGiftCard card) {
    final selected = _isCardSelected(card)
        ? state.selectedCards.where((selected) => selected != card).toList()
        : state.catalog!.gifts
              .where((gift) => gift == card || _isCardSelected(gift))
              .toList();
    _idempotencyKey = null;
    emit(
      state.copyWith(
        selectedCards: selected,
        totalRial: _totalBalance(selected),
        isAllVisibleSelected: _allVisibleSelected(state.visibleCards, selected),
        canContinue: _canEditSelection(selected),
        canReviewSelection: _canEditSelection(selected),
        termsAccepted: false,
        submissionStatus: RequestStatus.initial,
      ),
    );
  }

  void selectAllVisible(bool selected) {
    final cards = state.catalog!.gifts
        .where(
          (card) => selected
              ? _isCardSelected(card) || state.visibleCards.contains(card)
              : _isCardSelected(card) && !state.visibleCards.contains(card),
        )
        .toList();
    _idempotencyKey = null;
    emit(
      state.copyWith(
        selectedCards: cards,
        totalRial: _totalBalance(cards),
        isAllVisibleSelected: _allVisibleSelected(state.visibleCards, cards),
        canContinue: _canEditSelection(cards),
        canReviewSelection: _canEditSelection(cards),
        termsAccepted: false,
        submissionStatus: RequestStatus.initial,
      ),
    );
  }

  void requestFilter() {
    emit(
      state.copyWith(
        draftFilter: state.activeFilter,
        isEditable: false,
        canContinue: false,
        canReviewSelection: false,
        effect: GiftBalanceEffect.filter,
      ),
    );
  }

  void selectDraftFilter(GiftBalanceDepositFilter filter) {
    emit(state.copyWith(draftFilter: filter));
  }

  void applyFilterResult(bool? apply) {
    if (apply == true) {
      final visible = _filterGiftCards(
        state.catalog!,
        state.draftFilter,
        state.query,
      );
      emit(
        state.copyWith(
          activeFilter: state.draftFilter,
          visibleCards: visible,
          isAllVisibleSelected: _allVisibleSelected(
            visible,
            state.selectedCards,
          ),
          isEditable: true,
          canContinue: _hasSelection(),
          canReviewSelection: _hasSelection(),
        ),
      );
    } else {
      emit(
        state.copyWith(
          draftFilter: state.activeFilter,
          isEditable: true,
          canContinue: _hasSelection(),
          canReviewSelection: _hasSelection(),
        ),
      );
    }
  }

  void requestReview({bool advance = false}) {
    emit(
      state.copyWith(
        isEditable: false,
        canContinue: false,
        canReviewSelection: false,
        effect: GiftBalanceEffect.review,
        advanceAfterReview: advance,
      ),
    );
  }

  void removeSelectedCard(ExpiredGiftCard card) {
    final selected = state.selectedCards
        .where((selected) => selected != card)
        .toList();
    _idempotencyKey = null;
    emit(
      state.copyWith(
        selectedCards: selected,
        totalRial: _totalBalance(selected),
        isAllVisibleSelected: _allVisibleSelected(state.visibleCards, selected),
        canContinue: _canEditSelection(selected),
        canReviewSelection: _canEditSelection(selected),
        termsAccepted: false,
        submissionStatus: RequestStatus.initial,
      ),
    );
  }

  void applyReviewResult(bool? proceed) {
    final nextStep = _stepAfterReview(proceed);
    emit(
      state.copyWith(
        step: nextStep,
        stepNumber: nextStep == GiftBalanceStep.selection ? 1 : 2,
        isEditable: true,
        canReviewSelection: _hasSelection(),
        canContinue: _canContinueAtStep(nextStep),
      ),
    );
  }

  void selectDestination(CardServiceDeposit deposit) {
    _idempotencyKey = null;
    emit(
      state.copyWith(
        destination: deposit,
        termsAccepted: false,
        canContinue: false,
        submissionStatus: RequestStatus.initial,
      ),
    );
  }

  void updateTermsAcceptance(bool accepted) {
    emit(
      state.copyWith(
        termsAccepted: accepted,
        canContinue: _canContinueAtStep(
          GiftBalanceStep.destination,
          termsAccepted: accepted,
        ),
      ),
    );
  }

  Future<void> submitCurrentStep() async {
    switch (state.step) {
      case GiftBalanceStep.selection:
        requestReview(advance: true);
        return;
      case GiftBalanceStep.destination:
        await _submitTransfer();
        return;
    }
  }

  Future<void> _submitTransfer() async {
    _idempotencyKey ??= List.generate(
      16,
      (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    final request = GiftBalanceRequest(
      cardIds: state.selectedCards.map((card) => card.id),
      destinationDepositId: state.destination!.id,
      idempotencyKey: _idempotencyKey!,
    );
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        isEditable: false,
        canContinue: false,
        canReviewSelection: false,
      ),
    );
    final result = await cardServiceBoundary(
      () => _repository.transferGiftBalance(request),
    );
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.failure,
            isEditable: true,
            canReviewSelection: _hasSelection(),
            canContinue: _canContinueAtStep(state.step),
            failure: failure,
            message: getRequestErrorMessage(failure),
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

  void requestBack() {
    if (state.step == GiftBalanceStep.destination &&
        state.submissionStatus != RequestStatus.success) {
      emit(
        state.copyWith(
          step: GiftBalanceStep.selection,
          stepNumber: 1,
          termsAccepted: false,
          canContinue: state.isEditable && _hasSelection(),
        ),
      );
    } else {
      emit(
        state.copyWith(
          navigation: _needsExitConfirmation()
              ? FlowNavigation.confirmExit
              : FlowNavigation.back,
        ),
      );
    }
  }

  void applyExitConfirmation(bool? confirmed) {
    emit(
      state.copyWith(
        navigation: confirmed == true ? FlowNavigation.back : null,
      ),
    );
  }

  GiftBalanceStep _stepAfterReview(bool? proceed) {
    if (state.selectedCards.isEmpty) {
      return GiftBalanceStep.selection;
    }
    if (state.advanceAfterReview && proceed == true) {
      return GiftBalanceStep.destination;
    }
    return state.step;
  }

  bool _canContinueAtStep(GiftBalanceStep step, {bool? termsAccepted}) {
    return _hasSelection() &&
        (step == GiftBalanceStep.selection ||
            state.destination != null &&
                (termsAccepted ?? state.termsAccepted));
  }

  bool _needsExitConfirmation() {
    return state.submissionStatus != RequestStatus.success &&
        state.catalogStatus == RequestStatus.success &&
        (_hasSelection() || state.destination != null || state.termsAccepted);
  }

  Map<String, CardServiceDeposit> _depositsByGiftId(
    CardServiceCatalog catalog,
  ) {
    final depositsById = {
      for (final deposit in catalog.deposits) deposit.id: deposit,
    };
    return {
      for (final gift in catalog.gifts) gift.id: depositsById[gift.depositId]!,
    };
  }

  List<ExpiredGiftCard> _filterGiftCards(
    CardServiceCatalog catalog,
    GiftBalanceDepositFilter filter,
    String query,
  ) {
    final search = _normalizeNumber(query);
    return catalog.gifts
        .where(
          (card) =>
              card.balanceRial > 0 &&
              (filter.deposit == null ||
                  card.depositId == filter.deposit!.id) &&
              _normalizeNumber(card.number).contains(search),
        )
        .toList();
  }

  bool _isCardSelected(ExpiredGiftCard card) {
    return state.selectedCards.contains(card);
  }

  bool _hasSelection() => state.selectedCards.isNotEmpty;

  bool _canEditSelection(List<ExpiredGiftCard> cards) {
    return state.isEditable && cards.isNotEmpty;
  }

  bool _allVisibleSelected(
    List<ExpiredGiftCard> visible,
    List<ExpiredGiftCard> selected,
  ) => visible.isNotEmpty && visible.every(selected.contains);

  int _totalBalance(List<ExpiredGiftCard> cards) =>
      cards.fold(0, (total, card) => total + card.balanceRial);

  String _normalizeNumber(String value) =>
      DigitNormalizer.normalize(value).replaceAll(RegExp(r'[\s-]'), '');

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeExpiredGiftBalanceInteraction() {
    emit(state.copyWith(effect: null, navigation: null));
  }
}
