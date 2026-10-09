import '../../../cubit/dashboard_tab_state.dart';
import '../../../../domain/entities/bank_loan.dart';
export '../../../cubit/dashboard_tab_state.dart';

typedef LoansState = DashboardTabState<BankLoan>;

final class LoansLoaded extends DashboardTabLoaded<BankLoan> {
  LoansLoaded({required super.items, required super.selectedId});
}
