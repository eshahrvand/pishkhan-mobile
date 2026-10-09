import '../../../../domain/entities/bank_loan.dart';
import '../../../../domain/repositories/dashboard_repositories.dart';
import '../../../../domain/usecases/load_dashboard_items.dart';
import '../../../cubit/dashboard_tab_cubit.dart';
import 'loans_state.dart';

class LoansCubit extends DashboardTabCubit<BankLoan> {
  LoansCubit({required DashboardLoansRepository repository})
    : super(LoadDashboardItems(repository.getLoans));
  Future<void> changeRepository(DashboardLoansRepository repository) =>
      changeLoader(LoadDashboardItems(repository.getLoans));
  @override
  LoansLoaded loaded(
    List<BankLoan> items,
    String id,
    DashboardTabLoaded<BankLoan>? previous,
  ) => LoansLoaded(items: items, selectedId: id);
}
