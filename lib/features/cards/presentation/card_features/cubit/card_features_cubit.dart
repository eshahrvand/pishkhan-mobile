import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/listed_card.dart';
import '../../../domain/repositories/cards_repository.dart';
import '../../../domain/usecases/card_features.dart';
import 'card_features_state.dart';
export 'card_features_state.dart';

class CardFeaturesCubit extends Cubit<CardFeaturesState> {
  CardFeaturesCubit({
    CardFeaturesState initialState = const CardFeaturesState(),
    required CardsRepository repository,
    CardCategory? initialCategory,
  }) : _loader = LoadCards(repository),
       super(
         _prepareState(
           initialState.copyWith(
             category: initialCategory ?? initialState.category,
           ),
         ),
       );
  LoadCards _loader;
  int _request = 0;
  Future<void> load() async {
    final request = ++_request;
    emit(
      _prepareState(
        state.copyWith(
          status: RequestStatus.loading,
          failure: null,
          draftFilter: null,
        ),
      ),
    );
    final result = await _loader();
    if (isClosed || request != _request) return;
    switch (result) {
      case Err(:final failure):
        emit(
          _prepareState(
            state.copyWith(status: RequestStatus.failure, failure: failure),
          ),
        );
      case Success(:final data):
        emit(
          _prepareState(
            state.copyWith(
              status: RequestStatus.success,
              cards: data,
              failure: null,
              selectedId: data.any((c) => c.id == state.selectedId)
                  ? state.selectedId
                  : null,
            ),
          ),
        );
    }
  }

  Future<void> changeRepository(CardsRepository repository) {
    _loader = LoadCards(repository);
    return load();
  }

  void selectCategory(CardCategory value) =>
      emit(_prepareState(state.copyWith(category: value, selectedId: null)));
  void search(String value) =>
      emit(_prepareState(state.copyWith(query: value)));
  void selectCard(String id) {
    if (state.visibleCards.any((card) => card.id == id)) {
      emit(_prepareState(state.copyWith(selectedId: id)));
    }
  }

  void beginFilter() =>
      emit(_prepareState(state.copyWith(draftFilter: state.filter)));
  void setDraft(CardFilter value) {
    if (state.draftFilter != null) {
      emit(_prepareState(state.copyWith(draftFilter: value)));
    }
  }

  void applyFilter() {
    if (state.draftFilter != null) {
      emit(
        _prepareState(
          state.copyWith(
            filter: state.draftFilter!,
            draftFilter: null,
            selectedId: null,
          ),
        ),
      );
    }
  }

  void clearDraftFilter() => setDraft(const CardFilter());
  void cancelFilter() => emit(_prepareState(state.copyWith(draftFilter: null)));
  @override
  Future<void> close() {
    _request++;
    return super.close();
  }

  static CardFeaturesState _prepareState(CardFeaturesState next) {
    final query = _normalizeQuery(next.query);
    final cards = next.cards ?? const <ListedCard>[];
    final deposits = cards.map((c) => c.linkedDeposit).toSet().toList()..sort();
    return next.copyWith(
      selectedCard: cards.where((c) => c.id == next.selectedId).firstOrNull,
      visibleCards: cards
          .where(
            (c) =>
                c.category == next.category &&
                next.filter.matches(c) &&
                (_normalizeQuery(c.number).contains(query) ||
                    _normalizeQuery(c.linkedDeposit).contains(query)),
          )
          .toList(),
      deposits: deposits,
    );
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
