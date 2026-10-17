import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/card_filter.dart';
import '../../../domain/entities/listed_card.dart';
import '../../../domain/repositories/cards_repository.dart';
import '../../../domain/usecases/card_features.dart';
import '../card_feature_action.dart';
import 'card_features_effect.dart';

export '../../../domain/entities/card_filter.dart';
export 'card_features_effect.dart';

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
  late final _loadCards = LoadCards(_repository);
  int _cardsRequestId = 0;

  Future<void> fetchCards() {
    final category = _entryInitialized
        ? state.category
        : initialCategory ?? state.category;
    _entryInitialized = true;
    final requestId = ++_cardsRequestId;

    emit(
      state.copyWith(
        status: RequestStatus.loading,
        category: category,
        footerAction: _getCategoryFooterAction(category),
        failure: null,
        draftFilter: null,
      ),
    );

    return _loadCards().then((result) {
      if (isClosed || requestId != _cardsRequestId) return;

      switch (result) {
        case Err(:final failure):
          emit(state.copyWith(status: RequestStatus.failure, failure: failure));
        case Success(:final data):
          final selectedCard = _findCardById(data, state.selectedId);

          emit(
            state.copyWith(
              status: RequestStatus.success,
              cards: data,
              failure: null,
              selectedId: selectedCard?.id,
              selectedCard: selectedCard,
              visibleCards: _filterCards(
                data,
                state.category,
                state.filter,
                state.query,
              ),
              deposits: _getDepositNumbers(data),
            ),
          );
      }
    });
  }

  void selectCategory(CardCategory value) {
    emit(
      state.copyWith(
        category: value,
        footerAction: _getCategoryFooterAction(value),
        effect: CardCategoryRevealRequested(
          value,
          scrollToEnd: value.index >= 3,
        ),
        effectId: state.effectId + 1,
        selectedId: null,
        selectedCard: null,
        visibleCards: _filterCards(
          state.cards ?? const [],
          value,
          state.filter,
          state.query,
        ),
      ),
    );
  }

  void requestSelectedCategoryReveal() {
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

  void requestCardActions(ListedCard card) {
    emit(
      state.copyWith(
        selectedId: card.id,
        selectedCard: card,
        effect: CardActionsRequested(card),
        effectId: state.effectId + 1,
      ),
    );
  }

  void handleCardActionSelection(
    CardFeatureAction? action, {
    required ListedCard card,
  }) {
    switch (action) {
      case null:
        break;
      case CardFeatureAction.details:
        requestCardDetails(card);
      default:
        requestCardService(action, card: card);
    }
  }

  void requestCardDetails(ListedCard card) {
    emit(
      state.copyWith(
        effect: CardDetailsRequested(card),
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestCardService(CardFeatureAction action, {ListedCard? card}) {
    emit(
      state.copyWith(
        effect: CardServiceRequested(
          CardFeatureRequest(
            action: action,
            card: card,
            category: card?.category ?? state.category,
          ),
          serviceId: _getCardServiceId(action),
        ),
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestFooterAction() {
    requestCardService(state.footerAction!);
  }

  void updateSearchQuery(String value) {
    emit(
      state.copyWith(
        query: value,
        visibleCards: _filterCards(
          state.cards ?? const [],
          state.category,
          state.filter,
          value,
        ),
      ),
    );
  }

  void requestFilter() {
    emit(
      state.copyWith(
        draftFilter: state.filter,
        effect: const CardFilterRequested(),
        effectId: state.effectId + 1,
      ),
    );
  }

  void updateDraftCardStatus(String value) {
    emit(
      state.copyWith(
        draftFilter: CardFilter(
          status: value == 'all' ? null : CardStatus.values.byName(value),
          deposit: state.draftFilter!.deposit,
        ),
      ),
    );
  }

  void updateDraftDepositNumber(String value) {
    emit(
      state.copyWith(
        draftFilter: CardFilter(
          status: state.draftFilter!.status,
          deposit: value == 'all' ? null : value,
        ),
      ),
    );
  }

  void handleFilterSheetResult(bool? applied) {
    if (applied == true) {
      applyFilter();
    } else {
      cancelFilter();
    }
  }

  void applyFilter() {
    emit(
      state.copyWith(
        filter: state.draftFilter!,
        draftFilter: null,
        selectedId: null,
        selectedCard: null,
        visibleCards: _filterCards(
          state.cards ?? const [],
          state.category,
          state.draftFilter!,
          state.query,
        ),
      ),
    );
  }

  void resetDraftFilter() {
    emit(state.copyWith(draftFilter: const CardFilter()));
  }

  void cancelFilter() {
    emit(state.copyWith(draftFilter: null));
  }

  ListedCard? _findCardById(List<ListedCard> cards, String? cardId) {
    return cards.where((card) => card.id == cardId).firstOrNull;
  }

  List<String> _getDepositNumbers(List<ListedCard> cards) {
    return cards.map((card) => card.linkedDeposit).toSet().toList()..sort();
  }

  CardFeatureAction? _getCategoryFooterAction(CardCategory category) {
    return switch (category) {
      CardCategory.gift => CardFeatureAction.expiredGiftBalance,
      CardCategory.virtual => CardFeatureAction.requestVirtual,
      _ => null,
    };
  }

  String? _getCardServiceId(CardFeatureAction action) {
    return switch (action) {
      CardFeatureAction.requestVirtual => 'card-virtual-request',
      CardFeatureAction.changeDeposit => 'card-deposit',
      CardFeatureAction.expiredGiftBalance => 'card-expired-gift',
      CardFeatureAction.reissue => 'card-reissue',
      _ => null,
    };
  }

  List<ListedCard> _filterCards(
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
    _cardsRequestId++;
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
