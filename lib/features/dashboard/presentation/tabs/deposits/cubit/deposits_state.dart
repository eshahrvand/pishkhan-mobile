import '../../../cubit/dashboard_tab_state.dart';
import '../../../../domain/entities/bank_deposit.dart';
export '../../../cubit/dashboard_tab_state.dart';

typedef DepositsState = DashboardTabState<BankDeposit>;

final class DepositsLoaded extends DashboardTabLoaded<BankDeposit> {
  DepositsLoaded({required super.items, required super.selectedId});
}
