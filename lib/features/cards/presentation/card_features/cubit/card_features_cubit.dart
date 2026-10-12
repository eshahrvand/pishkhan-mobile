import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/features/cards/presentation/card_features/cubit/card_features_rules.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/listed_card.dart';
import '../../../domain/repositories/cards_repository.dart';
import '../../../domain/usecases/card_features.dart';
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
        status: RequestStatus.loading,
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
        emit(
          state.copyWith(
            status: RequestStatus.success,
            cards: data,
            failure: null,
            selectedId: data.any((c) => c.id == state.selectedId)
                ? state.selectedId
                : null,
          ),
        );
    }
  }

  Future<void> changeRepository(CardsRepository repository) {
    _loader = LoadCards(repository);
    return load();
  }

  void selectCategory(CardCategory value) =>
      emit(state.copyWith(category: value, selectedId: null));
  void search(String value) => emit(state.copyWith(query: value));
  void selectCard(String id) {
    if (cardFeaturesVisibleCards(state).any((card) => card.id == id)) {
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
          filter: state.draftFilter!,
          draftFilter: null,
          selectedId: null,
        ),
      );
    }
  }

  void clearDraftFilter() => setDraft(const CardFilter());
  void cancelFilter() => emit(state.copyWith(draftFilter: null));
  @override
  Future<void> close() {
    _request++;
    return super.close();
  }
}
