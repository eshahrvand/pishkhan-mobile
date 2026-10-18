import 'package:pishkhan_mobile/features/deposits/presentation/deposit_list/deposit_list_action.dart';

import '../support/registered_dependency.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/deposits/data/repositories/mock_deposits_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/listed_deposit.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/deposits_repository.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/deposit_list/cubit/deposit_list_cubit.dart';

class _Repository implements DepositsRepository {
  _Repository(this.load);
  final Future<Result<List<ListedDeposit>>> Function() load;
  @override
  Future<Result<List<ListedDeposit>>> getDeposits() => load();
}

void main() {
  test(
    'type and status filters combine; clear preserves the other filter',
    () async {
      final cubit =
          withRegisteredDependency<DepositsRepository, DepositListCubit>(
            MockDepositsRepository(
              deposits: [
                ListedDeposit(id: 's', number: '001'),
                ListedDeposit(
                  id: 'c',
                  number: '002',
                  kind: DepositKind.current,
                ),
                ListedDeposit(
                  id: 'closed',
                  number: '003',
                  kind: DepositKind.current,
                  status: DepositStatus.closed,
                ),
              ],
            ),
            () => DepositListCubit(),
          );
      await cubit.fetchDeposits();
      expect(cubit.state.visibleDeposits.map((d) => d.id), ['s', 'c']);
      cubit.selectKindFilter(DepositKind.current);
      expect(cubit.state.visibleDeposits.single.id, 'c');
      cubit.selectStatusFilter(null);
      expect(cubit.state.visibleDeposits.map((d) => d.id), ['c', 'closed']);
      cubit.selectStatusFilter(DepositStatus.closed);
      cubit.selectKindFilter(null);
      expect(cubit.state.visibleDeposits.single.number, '003');
      expect(() => cubit.state.deposits.clear(), throwsUnsupportedError);
      await cubit.close();
    },
  );
  test(
    'empty, failed and invalid responses remain distinct and retryable',
    () async {
      var calls = 0;
      final cubit =
          withRegisteredDependency<DepositsRepository, DepositListCubit>(
            _Repository(() async {
              calls++;
              if (calls == 1) throw StateError('transport failed');
              if (calls == 2) return const Success([]);
              return Success([
                ListedDeposit(id: 'duplicate', number: '1'),
                ListedDeposit(id: 'duplicate', number: '2'),
              ]);
            }),
            () => DepositListCubit(),
          );
      await cubit.fetchDeposits();
      expect(cubit.state.depositsStatus, RequestStatus.failure);
      expect(cubit.state.depositsFailure, isA<UnexpectedFailure>());
      await cubit.fetchDeposits();
      expect(cubit.state.depositsStatus, RequestStatus.success);
      expect(cubit.state.deposits, isEmpty);
      await cubit.fetchDeposits();
      expect(
        cubit.state.depositsFailure,
        const DataFailure('deposits.catalog.invalid'),
      );
      await cubit.close();
    },
  );
  test(
    'actions preserve the selected deposit and cancellation emits nothing',
    () async {
      final cubit =
          withRegisteredDependency<DepositsRepository, DepositListCubit>(
            MockDepositsRepository(),
            () => DepositListCubit(),
          );
      await cubit.fetchDeposits();
      final deposit = cubit.state.visibleDeposits.first;
      cubit.requestDepositActions(deposit);
      expect((cubit.state.effect as DepositActionsRequested).deposit, deposit);
      final effectId = cubit.state.effectId;
      cubit.applyActionSelection(deposit, null);
      expect(cubit.state.effectId, effectId);
      cubit.applyActionSelection(deposit, DepositListAction.accountDetails);
      expect((cubit.state.effect as DepositDetailsRequested).deposit, deposit);
      cubit.applyActionSelection(deposit, DepositListAction.statement);
      final effect = cubit.state.effect as DepositServiceRequested;
      expect(effect.serviceId, 'deposit-statement');
      expect(effect.request.deposit, deposit);
      await cubit.close();
    },
  );
}
