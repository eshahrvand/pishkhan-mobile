import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/bank_card.dart';
import '../../../domain/repositories/dashboard_repositories.dart';
import '../../../domain/usecases/home.dart';
import 'cards_state.dart';
export 'cards_state.dart';

class CardsCubit extends Cubit<CardsState> {
  CardsCubit({
    CardsState initialState = const CardsState(),
    required DashboardCardsRepository repository,
  }) : _loadItems = LoadDashboardItems(repository.getCards),
       super(_prepareState(initialState));

  LoadDashboardItems<BankCard> _loadItems;
  int _request = 0;

  Future<void> load() async {
    final token = ++_request;
    final previous = state;
    emit(
      _prepareState(
        state.copyWith(status: RequestStatus.loading, failure: null),
      ),
    );
    final result = await _loadItems();
    if (isClosed || token != _request) return;
    switch (result) {
      case Err(:final failure):
        emit(
          _prepareState(
            state.copyWith(status: RequestStatus.failure, failure: failure),
          ),
        );
      case Success(:final data):
        final items = data.isEmpty ? null : data;
        final id = data.any((item) => item.id == previous.selectedId)
            ? previous.selectedId
            : data.firstOrNull?.id;
        emit(
          _prepareState(
            state.copyWith(
              status: RequestStatus.success,
              items: items,
              selectedId: id,
              visibility: {
                for (final item in data)
                  item.id: previous.visibility[item.id] ?? data.length == 1,
              },
            ),
          ),
        );
    }
  }

  Future<void> changeRepository(DashboardCardsRepository repository) {
    _loadItems = LoadDashboardItems(repository.getCards);
    return load();
  }

  void select(int index) {
    final current = state;
    final items = current.items;
    if (current.status != RequestStatus.success ||
        items == null ||
        index < 0 ||
        index >= items.length) {
      return;
    }
    emit(_prepareState(current.copyWith(selectedId: items[index].id)));
  }

  void setVisibility(String id, bool value) {
    final current = state;
    if (current.status != RequestStatus.success ||
        !(current.items?.any((item) => item.id == id) ?? false)) {
      return;
    }
    emit(
      _prepareState(
        current.copyWith(visibility: {...current.visibility, id: value}),
      ),
    );
  }

  @override
  Future<void> close() {
    _request++;
    return super.close();
  }

  static CardsState _prepareState(CardsState next) {
    final items = next.status == RequestStatus.success
        ? next.items ?? const <BankCard>[]
        : const <BankCard>[];
    final selectedIndex = items.indexWhere(
      (item) => item.id == next.selectedId,
    );
    return next.copyWith(
      visibleItems: items,
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      selectedCard: selectedIndex < 0 ? null : items[selectedIndex],
    );
  }
}
