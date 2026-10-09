import '../../../cubit/dashboard_tab_state.dart';
import '../../../../domain/entities/bank_card.dart';
export '../../../cubit/dashboard_tab_state.dart';

typedef CardsState = DashboardTabState<BankCard>;

final class CardsLoaded extends DashboardTabLoaded<BankCard> {
  CardsLoaded({
    required super.items,
    required super.selectedId,
    Map<String, bool> visibility = const {},
  }) : visibility = Map.unmodifiable(visibility);
  final Map<String, bool> visibility;
  @override
  List<Object?> get props => [...super.props, visibility];
}
