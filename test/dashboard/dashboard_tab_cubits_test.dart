import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/dashboard/data/mock/dashboard_mock_data.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_card.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_deposit.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_loan.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/dashboard_home_data.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/dashboard_item.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/tabs/cards/cubit/cards_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/tabs/cards/cubit/cards_state.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/tabs/deposits/cubit/deposits_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/tabs/deposits/cubit/deposits_state.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/tabs/loans/cubit/loans_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/tabs/loans/cubit/loans_state.dart';

import 'support/dashboard_test_repositories.dart';

({
  RequestStatus status,
  List<DashboardItem>? items,
  String? selectedId,
  Failure? failure,
})
snapshot(Object state) => switch (state) {
  CardsState() => (
    status: state.status,
    items: state.items,
    selectedId: state.selectedId,
    failure: state.failure,
  ),
  DepositsState() => (
    status: state.status,
    items: state.items,
    selectedId: state.selectedId,
    failure: state.failure,
  ),
  LoansState() => (
    status: state.status,
    items: state.items,
    selectedId: state.selectedId,
    failure: state.failure,
  ),
  _ => throw StateError('Unexpected tab state: $state'),
};

void main() {
  for (final kind in ['cards', 'deposits', 'loans']) {
    test(
      '$kind loads, selects, retains ID on reorder, empties, errors and retries',
      () async {
        final repository = TestRepositories();
        final Cubit<Object> cubit = switch (kind) {
          'cards' => CardsCubit(repository: repository),
          'deposits' => DepositsCubit(repository: repository),
          _ => LoansCubit(repository: repository),
        };
        Future<void> load() => switch (cubit) {
          CardsCubit() => cubit.load(),
          DepositsCubit() => cubit.load(),
          LoansCubit() => cubit.load(),
          _ => throw StateError('Unexpected Cubit'),
        };
        void select(int index) {
          switch (cubit) {
            case CardsCubit():
              cubit.select(index);
            case DepositsCubit():
              cubit.select(index);
            case LoansCubit():
              cubit.select(index);
          }
        }

        final transitions = <Object>[];
        final subscription = cubit.stream.listen(transitions.add);
        expect(snapshot(cubit.state).status, RequestStatus.initial);
        final request = load();
        expect(snapshot(cubit.state).status, RequestStatus.loading);
        await request;
        final loaded = snapshot(cubit.state);
        expect(loaded.status, RequestStatus.success);
        expect(loaded.items!.length, greaterThan(1));
        select(1);
        final id = snapshot(cubit.state).selectedId;
        switch (kind) {
          case 'cards':
            repository.cards = Success(
              loaded.items!.reversed.cast<BankCard>().toList(),
            );
          case 'deposits':
            repository.deposits = Success(
              loaded.items!.reversed.cast<BankDeposit>().toList(),
            );
          default:
            repository.loans = Success(
              loaded.items!.reversed.cast<BankLoan>().toList(),
            );
        }
        final reorder = load();
        expect(snapshot(cubit.state).status, RequestStatus.loading);
        expect(snapshot(cubit.state).selectedId, id);
        expect(snapshot(cubit.state).items, loaded.items);
        await reorder;
        expect(snapshot(cubit.state).selectedId, id);
        switch (kind) {
          case 'cards':
            repository.cards = const Success([]);
          case 'deposits':
            repository.deposits = const Success([]);
          default:
            repository.loans = const Success([]);
        }
        await load();
        expect(snapshot(cubit.state).status, RequestStatus.success);
        expect(snapshot(cubit.state).items, isNull);
        select(99); // Selection is safe in the empty state.
        switch (kind) {
          case 'cards':
            repository.cards = const Err(DataFailure('offline'));
          case 'deposits':
            repository.deposits = const Err(DataFailure('offline'));
          default:
            repository.loans = const Err(DataFailure('offline'));
        }
        await load();
        expect(snapshot(cubit.state).failure!.code, 'offline');
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
        final retry = load();
        expect(snapshot(cubit.state).status, RequestStatus.loading);
        expect(snapshot(cubit.state).failure, isNull);
        await retry;
        expect(snapshot(cubit.state).items!.length, 1);
        expect(snapshot(cubit.state).failure, isNull);
        await Future<void>.delayed(Duration.zero);
        expect(
          transitions
              .where((state) => snapshot(state).status == RequestStatus.loading)
              .length,
          5,
        );
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
    expect(cubit.state.selectedId, 'loan-2');
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
      var state = cubit.state;
      expect(state.items![0].number, '1234567890123456');
      expect(() => state.items!.clear(), throwsUnsupportedError);
      expect(() => state.items![0].numberParts.clear(), throwsUnsupportedError);
      cubit.setVisibility('a', true);
      cubit.select(1);
      state = cubit.state;
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
    expect(snapshot(cubit.state).failure!.code, 'dashboard.items.invalid');
    repository.throwOnCards = true;
    await cubit.load();
    expect(snapshot(cubit.state).failure!.code, 'unexpected');
    await cubit.close();
  });
  test('home initial/loading/empty/error/loaded transitions keep favorite edits transactional', () async {
    final repository = TestRepositories();
    final cubit = DashboardCubit(repository: repository);
    expect(cubit.state.status, RequestStatus.initial);
    final request = cubit.load();
    expect(cubit.state.status, RequestStatus.loading);
    await request;
    expect(cubit.state.status, RequestStatus.success);
    expect(cubit.state.data, isNull);
    repository.home = const Err(DataFailure('offline'));
    await cubit.load();
    expect(cubit.state.status, RequestStatus.failure);
    repository.home = Success(
      DashboardHomeData(walletBalance: '123', favorites: ['one']),
    );
    await cubit.load();
    cubit.edit();
    cubit.add('two');
    expect(cubit.state.data!.favorites, ['one']);
    cubit.cancel();
    expect(cubit.state.data!.favorites, ['one']);
    cubit.edit();
    cubit.add('two');
    cubit.confirm();
    expect(cubit.state.data!.favorites, ['one', 'two']);
    await cubit.close();
  });
}
