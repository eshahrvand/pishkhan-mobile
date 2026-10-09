import '../../../../domain/entities/bank_deposit.dart';
import '../../../../domain/repositories/dashboard_repositories.dart';
import '../../../../domain/usecases/load_dashboard_items.dart';
import '../../../cubit/dashboard_tab_cubit.dart';
import 'deposits_state.dart';

class DepositsCubit extends DashboardTabCubit<BankDeposit> {
  DepositsCubit({required DashboardDepositsRepository repository})
    : super(LoadDashboardItems(repository.getDeposits));
  Future<void> changeRepository(DashboardDepositsRepository repository) =>
      changeLoader(LoadDashboardItems(repository.getDeposits));
  @override
  DepositsLoaded loaded(
    List<BankDeposit> items,
    String id,
    DashboardTabLoaded<BankDeposit>? previous,
  ) => DepositsLoaded(items: items, selectedId: id);
}
