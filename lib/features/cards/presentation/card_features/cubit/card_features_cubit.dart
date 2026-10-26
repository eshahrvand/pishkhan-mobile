import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';
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
          category: category,
          footerAction: _categoryFooterAction(category),
        ),
      );
    }
    return _fetchCardsForCategory();
  }

  Future<void> _fetchCardsForCategory() {
    emit(
      state.copyWith(
        cardsStatus: RequestStatus.loading,
        failure: null,
        message: null,
      ),
    );
    return _loadCards().then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              cardsStatus: RequestStatus.failure,
              failure: failure,
              message: getRequestErrorMessage(failure),
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
        effect: _categoryRevealEffect(value),
        selectedCard: null,
        visibleCards: _filterCards(
          state.cards,
          value,
          state.filter,
          state.searchQuery,
        ),
        message: null,
      ),
    );
  }

  void requestSelectedCategoryReveal() {
    emit(
      state.copyWith(
        effect: _categoryRevealEffect(state.category),
        message: null,
      ),
    );
  }

  void requestCardActions(ListedCard card) {
    emit(
      state.copyWith(
        selectedCard: card,
        effect: CardActionsRequested(card),
        message: null,
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
    emit(state.copyWith(effect: CardDetailsRequested(card), message: null));
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
        message: null,
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
        message: null,
      ),
    );
  }

  void selectDraftCardStatus(String value) {
    emit(
      state.copyWith(
        draftFilter: CardFilter(
          status: _isAllFilterOption(value)
              ? null
              : CardStatus.values.byName(value),
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
          deposit: _isAllFilterOption(value) ? null : value,
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

  CardCategoryRevealRequested _categoryRevealEffect(CardCategory category) {
    return CardCategoryRevealRequested(
      category,
      scrollToEnd: _isTrailingCategory(category),
    );
  }

  bool _isAllFilterOption(String value) => value == 'all';

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

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeCardFeaturesInteraction() {
    emit(state.copyWith(effect: null));
  }
}
