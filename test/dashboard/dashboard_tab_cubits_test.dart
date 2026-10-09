import 'package:pishkhan_mobile/features/dashboard/presentation/tabs/loans/cubit/loans_state.dart';

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/features/dashboard/data/mock/dashboard_mock_data.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_card.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_deposit.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_loan.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/dashboard_item.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/dashboard_home_data.dart';

import 'support/dashboard_test_repositories.dart';

import 'package:pishkhan_mobile/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/cubit/dashboard_tab_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/tabs/cards/cubit/cards_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/tabs/cards/cubit/cards_state.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/tabs/deposits/cubit/deposits_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/tabs/loans/cubit/loans_cubit.dart';

void main() {
  for (final kind in ['cards', 'deposits', 'loans']) {
    test(
      '$kind loads, selects, retains ID on reorder, empties, errors and retries',
      () async {
        final repository = TestRepositories();
        final DashboardTabCubit<DashboardItem> cubit = switch (kind) {
          'cards' => CardsCubit(repository: repository),
          'deposits' => DepositsCubit(repository: repository),
          _ => LoansCubit(repository: repository),
        };
        final transitions = <Object>[];
        final subscription = cubit.stream.listen(transitions.add);
        expect(cubit.state, isA<DashboardTabInitial>());
        final request = cubit.load();
        expect(cubit.state, isA<DashboardTabLoading>());
        await request;
        final loaded = cubit.state as DashboardTabLoaded;
        expect(loaded.layout, DashboardItemLayout.multiple);
        cubit.select(1);
        final id = (cubit.state as DashboardTabLoaded).selectedId;
        switch (kind) {
          case 'cards':
            repository.cards = Success(
              loaded.items.reversed.cast<BankCard>().toList(),
            );
          case 'deposits':
            repository.deposits = Success(
              loaded.items.reversed.cast<BankDeposit>().toList(),
            );
          default:
            repository.loans = Success(
              loaded.items.reversed.cast<BankLoan>().toList(),
            );
        }
        await cubit.load();
        expect((cubit.state as DashboardTabLoaded).selectedId, id);
        switch (kind) {
          case 'cards':
            repository.cards = const Success([]);
          case 'deposits':
            repository.deposits = const Success([]);
          default:
            repository.loans = const Success([]);
        }
        await cubit.load();
        expect(cubit.state, isA<DashboardTabEmpty>());
        cubit.select(99); // Selection is safe in the empty state.
        switch (kind) {
          case 'cards':
            repository.cards = const Err(DataFailure('offline'));
          case 'deposits':
            repository.deposits = const Err(DataFailure('offline'));
          default:
            repository.loans = const Err(DataFailure('offline'));
        }
        await cubit.load();
        expect((cubit.state as DashboardTabError).failure.code, 'offline');
        switch (kind) {
          case 'cards':
            repository.cards = const Success([DashboardMockData.singleCard]);
          case 'deposits':
            repository.deposits = const Success([
              DashboardMockData.singleDeposit,
            ]);
          default:
            repository.loans = const Success([DashboardMockData.singleLoan]);
        }
        await cubit.load();
        expect(
          (cubit.state as DashboardTabLoaded).layout,
          DashboardItemLayout.single,
        );
        await Future<void>.delayed(Duration.zero);
        expect(transitions.whereType<DashboardTabLoading>().length, 5);
        await subscription.cancel();
        await cubit.close();
      },
    );
  }
  test('latest load wins and completing after close cannot emit', () async {
    final repository = TestRepositories();
    final first = Completer<Result<List<BankLoan>>>();
    final second = Completer<Result<List<BankLoan>>>();
    repository.loanQueue.addAll([first, second]);
    final cubit = LoansCubit(repository: repository);
    final a = cubit.load(), b = cubit.load();
    second.complete(Success([DashboardMockData.loans[1]]));
    await b;
    first.complete(const Success([DashboardMockData.singleLoan]));
    await a;
    expect((cubit.state as LoansLoaded).selectedId, 'loan-2');
    final pending = Completer<Result<List<BankLoan>>>();
    repository.loanQueue.add(pending);
    final c = cubit.load();
    await cubit.close();
    pending.complete(const Success([]));
    await c;
  });
  test(
    'input collections detach; visibility and selection are immutable state',
    () async {
      final parts = ['1234', '5678', '9012', '3456'];
      final input = [
        BankCard(id: 'a', numberParts: parts),
        const BankCard(id: 'b'),
      ];
      final repository = TestRepositories()..cards = Success(input);
      final cubit = CardsCubit(repository: repository);
      await cubit.load();
      parts[0] = '0000';
      input.clear();
      var state = cubit.state as CardsLoaded;
      expect(state.items[0].number, '1234567890123456');
      expect(() => state.items.clear(), throwsUnsupportedError);
      expect(() => state.items[0].numberParts.clear(), throwsUnsupportedError);
      cubit.setVisibility('a', true);
      cubit.select(1);
      state = cubit.state as CardsLoaded;
      expect(state.visibility['a'], true);
      expect(state.selectedId, 'b');
      expect(() => state.visibility['a'] = false, throwsUnsupportedError);
      await cubit.close();
    },
  );
  test('invalid IDs and thrown transports become coded failures', () async {
    final repository = TestRepositories()
      ..cards = const Success([
        BankCard(id: 'duplicate'),
        BankCard(id: 'duplicate'),
      ]);
    final cubit = CardsCubit(repository: repository);
    await cubit.load();
    expect(
      (cubit.state as DashboardTabError).failure.code,
      'dashboard.items.invalid',
    );
    repository.throwOnCards = true;
    await cubit.load();
    expect((cubit.state as DashboardTabError).failure.code, 'unexpected');
    await cubit.close();
  });
  test('home initial/loading/empty/error/loaded transitions keep favorite edits transactional', () async {
    final repository = TestRepositories();
    final cubit = DashboardCubit(repository: repository);
    expect(cubit.state, isA<DashboardInitial>());
    final request = cubit.load();
    expect(cubit.state, isA<DashboardLoading>());
    await request;
    expect(cubit.state, isA<DashboardEmpty>());
    repository.home = const Err(DataFailure('offline'));
    await cubit.load();
    expect(cubit.state, isA<DashboardError>());
    repository.home = Success(
      DashboardHomeData(walletBalance: '123', favorites: ['one']),
    );
    await cubit.load();
    cubit.edit();
    cubit.add('two');
    expect(cubit.state.favorites, ['one']);
    cubit.cancel();
    expect(cubit.state.favorites, ['one']);
    cubit.edit();
    cubit.add('two');
    cubit.confirm();
    expect(cubit.state.favorites, ['one', 'two']);
    await cubit.close();
  });
}
