import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/listed_card.dart';
import '../../domain/repositories/cards_repository.dart';
import '../../domain/usecases/load_cards.dart';
import 'card_features_state.dart';
export 'card_features_state.dart';

class CardFeaturesCubit extends Cubit<CardFeaturesState> {
  CardFeaturesCubit({
    required CardsRepository repository,
    CardCategory initialCategory = CardCategory.resalat,
  }) : _loader = LoadCards(repository),
       super(CardFeaturesState(category: initialCategory));
  LoadCards _loader;
  int _request = 0;
  Future<void> load() async {
    final request = ++_request;
    emit(
      state.copyWith(
        status: CardsLoadStatus.loading,
        clearFailure: true,
        clearDraft: true,
      ),
    );
    final result = await _loader();
    if (isClosed || request != _request) return;
    switch (result) {
      case Err(:final failure):
        emit(state.copyWith(status: CardsLoadStatus.error, failure: failure));
      case Success(:final data):
        emit(
          state.copyWith(
            status: data.isEmpty
                ? CardsLoadStatus.empty
                : CardsLoadStatus.loaded,
            cards: data,
            clearFailure: true,
            clearSelection: !data.any((c) => c.id == state.selectedId),
          ),
        );
    }
  }

  Future<void> changeRepository(CardsRepository repository) {
    _loader = LoadCards(repository);
    return load();
  }

  void selectCategory(CardCategory value) =>
      emit(state.copyWith(category: value, clearSelection: true));
  void search(String value) => emit(state.copyWith(query: value));
  void selectCard(String id) {
    if (state.visibleCards.any((card) => card.id == id)) {
      emit(state.copyWith(selectedId: id));
    }
  }

  void beginFilter() => emit(state.copyWith(draftFilter: state.filter));
  void setDraft(CardFilter value) {
    if (state.draftFilter != null) emit(state.copyWith(draftFilter: value));
  }

  void applyFilter() {
    if (state.draftFilter != null) {
      emit(
        state.copyWith(
          filter: state.draftFilter,
          clearDraft: true,
          clearSelection: true,
        ),
      );
    }
  }

  void clearDraftFilter() => setDraft(const CardFilter());
  void cancelFilter() => emit(state.copyWith(clearDraft: true));
  @override
  Future<void> close() {
    _request++;
    return super.close();
  }
}
