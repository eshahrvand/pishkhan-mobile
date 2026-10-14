import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/bank_card.dart';
import '../../../domain/repositories/dashboard_repositories.dart';
import '../../../domain/usecases/home.dart';

part 'cards_state.dart';
part 'cards_cubit.freezed.dart';

class CardsCubit extends Cubit<CardsState> {
  CardsCubit({
    CardsState initialState = const CardsState.initial(),
    required DashboardCardsRepository repository,
  }) : _loadItems = LoadDashboardItems(repository.getCards),
       super(initialState) {
    final items = initialState.status == RequestStatus.success
        ? initialState.items ?? const <BankCard>[]
        : const <BankCard>[];
    final index = items.indexWhere(
      (item) => item.id == initialState.selectedId,
    );
    emit(
      state.copyWith(
        visibleItems: items,
        selectedIndex: index < 0 ? 0 : index,
        selectedCard: index < 0 ? null : items[index],
      ),
    );
  }

  LoadDashboardItems<BankCard> _loadItems;
  int _request = 0;

  Future<void> load() async {
    final token = ++_request;
    final previous = state;
    emit(
      state.copyWith(
        status: RequestStatus.loading,
        failure: null,
        visibleItems: const [],
        selectedIndex: 0,
        selectedCard: null,
      ),
    );
    final result = await _loadItems();
    if (isClosed || token != _request) return;
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            status: RequestStatus.failure,
            failure: failure,
            visibleItems: const [],
            selectedIndex: 0,
            selectedCard: null,
          ),
        );
      case Success(:final data):
        final id = data.any((item) => item.id == previous.selectedId)
            ? previous.selectedId
            : data.firstOrNull?.id;
        final index = data.indexWhere((item) => item.id == id);
        emit(
          state.copyWith(
            status: RequestStatus.success,
            items: data.isEmpty ? null : data,
            selectedId: id,
            visibleItems: data,
            selectedIndex: index < 0 ? 0 : index,
            selectedCard: index < 0 ? null : data[index],
            visibility: {
              for (final item in data)
                item.id: previous.visibility[item.id] ?? data.length == 1,
            },
          ),
        );
    }
  }

  Future<void> changeRepository(DashboardCardsRepository repository) {
    _loadItems = LoadDashboardItems(repository.getCards);
    return load();
  }

  void select(int index) {
    final items = state.items;
    if (state.status != RequestStatus.success ||
        items == null ||
        index < 0 ||
        index >= items.length) {
      return;
    }
    final selectedIndex = items.indexWhere(
      (item) => item.id == items[index].id,
    );
    emit(
      state.copyWith(
        selectedId: items[index].id,
        selectedIndex: selectedIndex,
        selectedCard: items[selectedIndex],
      ),
    );
  }

  void setVisibility(String id, bool value) {
    if (state.status != RequestStatus.success ||
        !(state.items?.any((item) => item.id == id) ?? false)) {
      return;
    }
    emit(state.copyWith(visibility: {...state.visibility, id: value}));
  }

  @override
  Future<void> close() {
    _request++;
    return super.close();
  }
}
