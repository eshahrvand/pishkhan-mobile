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

  final _repository = getIt<CardsRepository>();
  late final _loadCards = LoadCards(_repository);

  Future<void> fetchCards() {
    if (state.cardsStatus == RequestStatus.initial) {
      final category = initialCategory ?? state.category;
      emit(
        state.copyWith(
          cardsStatus: RequestStatus.loading,
          category: category,
          footerAction: _categoryFooterAction(category),
        ),
      );
    } else {
      emit(
        state.copyWith(cardsStatus: RequestStatus.loading, cardsFailure: null),
      );
    }

    return _loadCards().then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              cardsStatus: RequestStatus.failure,
              cardsFailure: failure,
            ),
          );
        case Success(:final data):
          emit(
            state.copyWith(
              cardsStatus: RequestStatus.success,
              cards: data,
              selectedCard: data
                  .where((card) => card.id == state.selectedCard?.id)
                  .firstOrNull,
              visibleCards: _filterCards(
                data,
                state.category,
                state.filter,
                state.searchQuery,
              ),
              depositNumbers: _depositNumbers(data),
            ),
          );
      }
    });
  }

  void selectCategory(CardCategory value) {
    emit(
      state.copyWith(
        category: value,
        footerAction: _categoryFooterAction(value),
        effect: CardCategoryRevealRequested(
          value,
          scrollToEnd: _isTrailingCategory(value),
        ),
        effectId: state.effectId + 1,
        selectedCard: null,
        visibleCards: _filterCards(
          state.cards,
          value,
          state.filter,
          state.searchQuery,
        ),
      ),
    );
  }

  void requestSelectedCategoryReveal() {
    emit(
      state.copyWith(
        effect: CardCategoryRevealRequested(
          state.category,
          scrollToEnd: _isTrailingCategory(state.category),
        ),
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestCardActions(ListedCard card) {
    emit(
      state.copyWith(
        selectedCard: card,
        effect: CardActionsRequested(card),
        effectId: state.effectId + 1,
      ),
    );
  }

  void selectCardAction(CardFeatureAction? action, {required ListedCard card}) {
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
          serviceId: _cardServiceId(action),
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
        searchQuery: value,
        visibleCards: _filterCards(
          state.cards,
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

  void selectDraftCardStatus(String value) {
    emit(
      state.copyWith(
        draftFilter: CardFilter(
          status: value == 'all' ? null : CardStatus.values.byName(value),
          deposit: state.draftFilter!.deposit,
        ),
      ),
    );
  }

  void selectDraftDepositNumber(String value) {
    emit(
      state.copyWith(
        draftFilter: CardFilter(
          status: state.draftFilter!.status,
          deposit: value == 'all' ? null : value,
        ),
      ),
    );
  }

  void applyFilterSheetResult(bool? applied) {
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
        selectedCard: null,
        visibleCards: _filterCards(
          state.cards,
          state.category,
          state.draftFilter!,
          state.searchQuery,
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

  List<String> _depositNumbers(List<ListedCard> cards) {
    return cards.map((card) => card.linkedDeposit).toSet().toList()..sort();
  }

  CardFeatureAction? _categoryFooterAction(CardCategory category) {
    return switch (category) {
      CardCategory.gift => CardFeatureAction.expiredGiftBalance,
      CardCategory.virtual => CardFeatureAction.requestVirtual,
      _ => null,
    };
  }

  String? _cardServiceId(CardFeatureAction action) {
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

  bool _isTrailingCategory(CardCategory category) {
    return category == CardCategory.coupon || category == CardCategory.family;
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
