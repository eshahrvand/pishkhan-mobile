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
import '../../../domain/usecases/card_services.dart';
import '../models/gift_balance_deposit_filter.dart';

export 'package:pishkhan_mobile/core/flow/flow_navigation.dart';

part 'expired_gift_balance_state.dart';
part 'expired_gift_balance_cubit.freezed.dart';

class ExpiredGiftBalanceCubit extends Cubit<ExpiredGiftBalanceState> {
  ExpiredGiftBalanceCubit({
    ExpiredGiftBalanceState initialState =
        const ExpiredGiftBalanceState.initial(),
  }) : super(initialState);

  final _repository = getIt<CardServicesRepository>();
  String? _idempotencyKey;

  Future<void> fetchCatalog() {
    emit(
      state.copyWith(
        catalogStatus: RequestStatus.loading,
        failure: null,
        message: null,
      ),
    );
    return LoadCardServiceCatalog(_repository)().then((result) {
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
          final depositsById = {
            for (final deposit in data.deposits) deposit.id: deposit,
          };
          emit(
            state.copyWith(
              catalogStatus: RequestStatus.success,
              catalog: data,
              visibleCards: _filterGiftCards(
                data,
                state.activeFilter,
                state.query,
              ),
              depositsByGiftId: {
                for (final gift in data.gifts)
                  gift.id: depositsById[gift.depositId]!,
              },
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
    });
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
    _selectGiftCards(selected);
  }

  void selectAllVisible(bool selected) {
    final cards = state.catalog!.gifts
        .where(
          (card) => selected
              ? _isCardSelected(card) || state.visibleCards.contains(card)
              : _isCardSelected(card) && !state.visibleCards.contains(card),
        )
        .toList();
    _selectGiftCards(cards);
  }

  void _selectGiftCards(List<ExpiredGiftCard> cards) {
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
        failure: null,
        message: null,
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
        message: null,
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
        message: null,
      ),
    );
  }

  void removeSelectedCard(ExpiredGiftCard card) {
    final selected = state.selectedCards
        .where((selected) => selected != card)
        .toList();
    _selectGiftCards(selected);
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
        failure: null,
        message: null,
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

  Future<void> submitCurrentStep() {
    switch (state.step) {
      case GiftBalanceStep.selection:
        requestReview(advance: true);
        return Future.value();
      case GiftBalanceStep.destination:
        return _submitTransfer();
    }
  }

  Future<void> _submitTransfer() {
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
        failure: null,
        message: null,
      ),
    );
    return cardServiceBoundary(() => _repository.transferGiftBalance(request))
        .then((result) {
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
        });
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
          message: null,
        ),
      );
    }
  }

  void applyExitConfirmation(bool? confirmed) {
    emit(
      state.copyWith(
        navigation: confirmed == true ? FlowNavigation.back : null,
        message: null,
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
