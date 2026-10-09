import '../../../../domain/entities/bank_card.dart';
import '../../../../domain/repositories/dashboard_repositories.dart';
import '../../../../domain/usecases/load_dashboard_items.dart';
import '../../../cubit/dashboard_tab_cubit.dart';
import 'cards_state.dart';

class CardsCubit extends DashboardTabCubit<BankCard> {
  CardsCubit({required DashboardCardsRepository repository})
    : super(LoadDashboardItems(repository.getCards));
  Future<void> changeRepository(DashboardCardsRepository repository) =>
      changeLoader(LoadDashboardItems(repository.getCards));
  @override
  CardsLoaded loaded(
    List<BankCard> items,
    String id,
    DashboardTabLoaded<BankCard>? previous,
  ) => CardsLoaded(
    items: items,
    selectedId: id,
    visibility: {
      for (final item in items)
        item.id: previous is CardsLoaded
            ? previous.visibility[item.id] ?? items.length == 1
            : items.length == 1,
    },
  );
  void setVisibility(String id, bool value) {
    final current = state;
    if (current is! CardsLoaded ||
        !current.items.any((item) => item.id == id)) {
      return;
    }
    emit(
      CardsLoaded(
        items: current.items,
        selectedId: current.selectedId,
        visibility: {...current.visibility, id: value},
      ),
    );
  }
}
