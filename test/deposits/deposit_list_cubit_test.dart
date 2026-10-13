import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/deposits/deposits.dart';
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
      final cubit = DepositListCubit(
        repository: MockDepositsRepository(
          deposits: [
            ListedDeposit(id: 's', number: '001'),
            ListedDeposit(id: 'c', number: '002', kind: DepositKind.current),
            ListedDeposit(
              id: 'closed',
              number: '003',
              kind: DepositKind.current,
              status: DepositStatus.closed,
            ),
          ],
        ),
      );
      await cubit.load();
      expect(cubit.state.visibleDeposits.map((d) => d.id), ['s', 'c']);
      cubit.filterKind(DepositKind.current);
      expect(cubit.state.visibleDeposits.single.id, 'c');
      cubit.filterStatus(null);
      expect(cubit.state.visibleDeposits.map((d) => d.id), ['c', 'closed']);
      cubit.filterStatus(DepositStatus.closed);
      cubit.filterKind(null);
      expect(cubit.state.visibleDeposits.single.number, '003');
      expect(() => cubit.state.deposits.clear(), throwsUnsupportedError);
      await cubit.close();
    },
  );
  test(
    'empty, failed and invalid responses remain distinct and retryable',
    () async {
      var calls = 0;
      final cubit = DepositListCubit(
        repository: _Repository(() async {
          calls++;
          if (calls == 1) throw StateError('transport failed');
          if (calls == 2) return const Success([]);
          return Success([
            ListedDeposit(id: 'duplicate', number: '1'),
            ListedDeposit(id: 'duplicate', number: '2'),
          ]);
        }),
      );
      await cubit.load();
      expect(cubit.state.status, RequestStatus.failure);
      expect(cubit.state.failure, isA<UnexpectedFailure>());
      await cubit.load();
      expect(cubit.state.status, RequestStatus.success);
      expect(cubit.state.deposits, isEmpty);
      await cubit.load();
      expect(
        cubit.state.failure,
        const DataFailure('deposits.catalog.invalid'),
      );
      await cubit.close();
    },
  );
  test(
    'newest response wins and disposed Cubit ignores pending work',
    () async {
      final responses = <Completer<Result<List<ListedDeposit>>>>[];
      final cubit = DepositListCubit(
        repository: _Repository(() {
          final pending = Completer<Result<List<ListedDeposit>>>();
          responses.add(pending);
          return pending.future;
        }),
      );
      final first = cubit.load(), second = cubit.load();
      responses[1].complete(Success([ListedDeposit(id: 'new', number: '2')]));
      await second;
      responses[0].complete(Success([ListedDeposit(id: 'old', number: '1')]));
      await first;
      expect(cubit.state.deposits.single.id, 'new');
      final third = cubit.load();
      await cubit.close();
      responses[2].complete(const Success([]));
      await third;
    },
  );
}
