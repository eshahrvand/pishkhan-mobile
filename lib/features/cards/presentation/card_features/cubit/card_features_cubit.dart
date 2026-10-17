import 'package:pishkhan_mobile/core/di/injection_container.dart';

import '../card_feature_action.dart';
import 'card_features_effect.dart';
export 'card_features_effect.dart';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../../domain/entities/card_filter.dart';
export '../../../domain/entities/card_filter.dart';

import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/listed_card.dart';
import '../../../domain/repositories/cards_repository.dart';
import '../../../domain/usecases/card_features.dart';

part 'card_features_state.dart';

part 'card_features_cubit.freezed.dart';

class CardFeaturesCubit extends Cubit<CardFeaturesState> {
  CardFeaturesCubit({
    CardFeaturesState initialState = const CardFeaturesState.initial(),
    this.initialCategory,
  }) : super(initialState);

  final CardCategory? initialCategory;
  bool _entryInitialized = false;

  final _repository = getIt<CardsRepository>();
  late LoadCards _loader = LoadCards(_repository);
  int _request = 0;

  Future<void> load() async {
    if (isClosed) return;
    final category = _entryInitialized
        ? state.category
        : initialCategory ?? state.category;
    _entryInitialized = true;
    final request = ++_request;
    emit(
      state.copyWith(
        status: RequestStatus.loading,
        category: category,
        footerAction: switch (category) {
          CardCategory.gift => CardFeatureAction.expiredGiftBalance,
          CardCategory.virtual => CardFeatureAction.requestVirtual,
          _ => null,
        },
        failure: null,
        draftFilter: null,
      ),
    );
    final result = await _loader();
    if (isClosed || request != _request) return;
    switch (result) {
      case Err(:final failure):
        emit(state.copyWith(status: RequestStatus.failure, failure: failure));
      case Success(:final data):
        final id = data.any((card) => card.id == state.selectedId)
            ? state.selectedId
            : null;
        final deposits = data.map((card) => card.linkedDeposit).toSet().toList()
          ..sort();
        emit(
          state.copyWith(
            status: RequestStatus.success,
            cards: data,
            failure: null,
            selectedId: id,
            selectedCard: data.where((card) => card.id == id).firstOrNull,
            visibleCards: filterCards(
              data,
              state.category,
              state.filter,
              state.query,
            ),
            deposits: deposits,
          ),
        );
    }
  }

  Future<void> changeRepository(CardsRepository repository) {
    _loader = LoadCards(repository);
    return load();
  }

  void selectCategory(CardCategory value) {
    if (isClosed) return;
    emit(
      state.copyWith(
        category: value,
        footerAction: switch (value) {
          CardCategory.gift => CardFeatureAction.expiredGiftBalance,
          CardCategory.virtual => CardFeatureAction.requestVirtual,
          _ => null,
        },
        effect: CardCategoryRevealRequested(
          value,
          scrollToEnd: value.index >= 3,
        ),
        effectId: state.effectId + 1,
        selectedId: null,
        selectedCard: null,
        visibleCards: filterCards(
          state.cards ?? const [],
          value,
          state.filter,
          state.query,
        ),
      ),
    );
  }

  void revealCategory() {
    if (isClosed) return;
    emit(
      state.copyWith(
        effect: CardCategoryRevealRequested(
          state.category,
          scrollToEnd: state.category.index >= 3,
        ),
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestMore(String cardId) {
    if (isClosed) return;
    final card = state.visibleCards
        .where((card) => card.id == cardId)
        .firstOrNull;
    if (card == null) return;
    emit(
      state.copyWith(
        selectedId: card.id,
        selectedCard: card,
        effect: CardActionsRequested(card),
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestAction(CardFeatureAction? action, {ListedCard? card}) {
    if (isClosed || action == null) return;
    if (card != null && !(state.cards?.contains(card) ?? false)) return;
    if (action == CardFeatureAction.details) {
      if (card == null) return;
      emit(
        state.copyWith(
          effect: CardDetailsRequested(card),
          effectId: state.effectId + 1,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        effect: CardServiceRequested(
          CardFeatureRequest(
            action: action,
            card: card,
            category: card?.category ?? state.category,
          ),
          serviceId: switch (action) {
            CardFeatureAction.requestVirtual => 'card-virtual-request',
            CardFeatureAction.changeDeposit => 'card-deposit',
            CardFeatureAction.expiredGiftBalance => 'card-expired-gift',
            CardFeatureAction.reissue => 'card-reissue',
            _ => null,
          },
        ),
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestFooterAction() {
    if (isClosed || state.footerAction == null) return;
    requestAction(state.footerAction!);
  }

  void search(String value) {
    emit(
      state.copyWith(
        query: value,
        visibleCards: filterCards(
          state.cards ?? const [],
          state.category,
          state.filter,
          value,
        ),
      ),
    );
  }

  void selectCard(String id) {
    if (state.visibleCards.any((card) => card.id == id)) {
      emit(
        state.copyWith(
          selectedId: id,
          selectedCard: state.cards?.where((card) => card.id == id).firstOrNull,
        ),
      );
    }
  }

  void requestFilter() {
    if (state.draftFilter != null) return;
    emit(
      state.copyWith(
        draftFilter: state.filter,
        effect: const CardFilterRequested(),
        effectId: state.effectId + 1,
      ),
    );
  }

  void updateDraftStatus(String value) {
    if (state.draftFilter == null) return;
    emit(
      state.copyWith(
        draftFilter: CardFilter(
          status: value == 'all' ? null : CardStatus.values.byName(value),
          deposit: state.draftFilter!.deposit,
        ),
      ),
    );
  }

  void updateDraftDeposit(String value) {
    if (state.draftFilter == null) return;
    emit(
      state.copyWith(
        draftFilter: CardFilter(
          status: state.draftFilter!.status,
          deposit: value == 'all' ? null : value,
        ),
      ),
    );
  }

  void filterPresentationClosed(bool? applied) {
    if (isClosed || state.draftFilter == null) return;
    if (applied == true) {
      applyFilter();
    } else {
      cancelFilter();
    }
  }

  void beginFilter() {
    emit(state.copyWith(draftFilter: state.filter));
  }

  void setDraft(CardFilter value) {
    if (state.draftFilter != null) emit(state.copyWith(draftFilter: value));
  }

  void applyFilter() {
    if (state.draftFilter == null) return;
    emit(
      state.copyWith(
        filter: state.draftFilter!,
        draftFilter: null,
        selectedId: null,
        selectedCard: null,
        visibleCards: filterCards(
          state.cards ?? const [],
          state.category,
          state.draftFilter!,
          state.query,
        ),
      ),
    );
  }

  void clearDraftFilter() {
    setDraft(const CardFilter());
  }

  void cancelFilter() {
    if (state.draftFilter == null) return;
    emit(state.copyWith(draftFilter: null));
  }

  List<ListedCard> filterCards(
    List<ListedCard> cards,
    CardCategory category,
    CardFilter filter,
    String searchQuery,
  ) {
    final query = _normalizeQuery(searchQuery);
    return cards
        .where(
          (card) =>
              card.category == category &&
              filter.matches(card) &&
              (_normalizeQuery(card.number).contains(query) ||
                  _normalizeQuery(card.linkedDeposit).contains(query)),
        )
        .toList();
  }

  @override
  Future<void> close() {
    _request++;
    return super.close();
  }

  static String _normalizeQuery(String input) {
    const persian = '۰۱۲۳۴۵۶۷۸۹', arabic = '٠١٢٣٤٥٦٧٨٩';
    var value = input;
    for (var i = 0; i < 10; i++) {
      value = value.replaceAll(persian[i], '$i').replaceAll(arabic[i], '$i');
    }
    return value.replaceAll(RegExp(r'[\s\-\.\u200c]'), '').toLowerCase();
  }
}
