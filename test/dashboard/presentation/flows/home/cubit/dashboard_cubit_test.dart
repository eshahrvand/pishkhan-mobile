import 'dart:async';

import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/dashboard_home_data.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/repositories/dashboard_repositories.dart';

import 'package:pishkhan_mobile/features/dashboard/data/repositories/mock_dashboard_repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/dashboard_cubit.dart';

class ControlledHomeRepository implements DashboardHomeRepository {
  final requests = <Completer<Result<DashboardHomeData?>>>[];

  @override
  Future<Result<DashboardHomeData?>> getHome() => requests.removeAt(0).future;
}

void main() {
  test(
    'reload clears data, draft and failure and emits the new state shape',
    () async {
      final repository = ControlledHomeRepository();
      final cubit = DashboardCubit(repository: repository);
      final states = <DashboardState>[];
      final subscription = cubit.stream.listen(states.add);
      addTearDown(() async {
        await subscription.cancel();
        await cubit.close();
      });
      expect(cubit.state, const DashboardState.initial());
      final first = Completer<Result<DashboardHomeData?>>();
      repository.requests.add(first);
      final load = cubit.load();
      first.complete(
        Success(DashboardHomeData(walletBalance: '123', favorites: ['one'])),
      );
      await load;
      final data = cubit.state.data!;
      cubit.edit();
      cubit.add('two');

      final failed = Completer<Result<DashboardHomeData?>>();
      repository.requests.add(failed);
      final reload = cubit.load();
      expect(
        cubit.state,
        const DashboardState.initial(status: RequestStatus.loading),
      );
      failed.complete(const Err(DataFailure('offline')));
      await reload;
      expect(
        cubit.state,
        const DashboardState.initial(
          status: RequestStatus.failure,
          failure: DataFailure('offline'),
        ),
      );

      final empty = Completer<Result<DashboardHomeData?>>();
      repository.requests.add(empty);
      final retry = cubit.load();
      expect(
        cubit.state,
        const DashboardState.initial(status: RequestStatus.loading),
      );
      empty.complete(const Success(null));
      await retry;
      await Future<void>.delayed(Duration.zero);
      expect(states, [
        const DashboardState.initial(status: RequestStatus.loading),
        DashboardState.initial(status: RequestStatus.success, data: data, activeFavorites: ['one']),
        DashboardState.initial(
          status: RequestStatus.success,
          data: data,
          draft: ['one'],
          activeFavorites: ['one'],
        ),
        DashboardState.initial(
          status: RequestStatus.success,
          data: data,
          draft: ['one', 'two'],
          activeFavorites: ['one', 'two'],
        ),
        const DashboardState.initial(status: RequestStatus.loading),
        const DashboardState.initial(
          status: RequestStatus.failure,
          failure: DataFailure('offline'),
        ),
        const DashboardState.initial(status: RequestStatus.loading),
        const DashboardState.initial(status: RequestStatus.success),
      ]);
    },
  );

  test('Home ignores stale loads and completions after close', () async {
    final repository = ControlledHomeRepository();
    final cubit = DashboardCubit(repository: repository);
    final stale = Completer<Result<DashboardHomeData?>>();
    final latest = Completer<Result<DashboardHomeData?>>();
    repository.requests.addAll([stale, latest]);
    final firstLoad = cubit.load();
    final secondLoad = cubit.load();
    latest.complete(Success(DashboardHomeData(walletBalance: 'latest')));
    await secondLoad;
    stale.complete(const Err(DataFailure('stale')));
    await firstLoad;
    expect(cubit.state.status, RequestStatus.success);
    expect(cubit.state.data!.walletBalance, 'latest');
    expect(cubit.state.failure, isNull);

    final pending = Completer<Result<DashboardHomeData?>>();
    repository.requests.add(pending);
    final pendingLoad = cubit.load();
    await cubit.close();
    pending.complete(const Success(null));
    await pendingLoad;
    expect(cubit.state.status, RequestStatus.loading);
  });

  test('draft edits are unique, limited to eight, and transactional', () async {
    final cubit = DashboardCubit(
      repository: const MockDashboardHomeRepository(favorites: ['one']),
    );
    await cubit.load();
    cubit.add('ignored');
    cubit.edit();
    for (final id in [
      'one',
      'two',
      'three',
      'four',
      'five',
      'six',
      'seven',
      'eight',
      'nine',
    ]) {
      cubit.add(id);
    }
    expect(cubit.state.draft, [
      'one',
      'two',
      'three',
      'four',
      'five',
      'six',
      'seven',
      'eight',
    ]);
    expect(cubit.state.data!.favorites, ['one']);
    cubit.remove('two');
    cubit.add('nine');
    cubit.confirm();
    expect(cubit.state.data!.favorites, [
      'one',
      'three',
      'four',
      'five',
      'six',
      'seven',
      'eight',
      'nine',
    ]);
    cubit.edit();
    cubit.remove('one');
    cubit.cancel();
    expect(cubit.state.data!.favorites.length, 8);
    cubit.reset();
    expect(cubit.state.data!.favorites, isEmpty);
    expect(cubit.state.draft, isNull);
    await cubit.close();
  });
  test('suggestions remain uncommitted until confirmation', () async {
    final cubit = DashboardCubit(
      repository: const MockDashboardHomeRepository(),
    );
    await cubit.load();
    cubit.edit(suggestions: ['a', 'b', 'c']);
    expect(cubit.state.data!.favorites, isEmpty);
    expect(cubit.state.draft, ['a', 'b', 'c']);
    cubit.cancel();
    expect(cubit.state.data!.favorites, isEmpty);
    cubit.edit(suggestions: ['a']);
    cubit.confirm();
    cubit.edit(suggestions: ['b']);
    expect(cubit.state.draft, ['a']);
    await cubit.close();
  });
}
