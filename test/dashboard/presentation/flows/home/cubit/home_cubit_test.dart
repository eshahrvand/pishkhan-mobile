import '../../../../support/home_tab_test_scope.dart';

import 'dart:async';

import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/dashboard_home_data.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/repositories/dashboard_repositories.dart';

import 'package:pishkhan_mobile/features/dashboard/data/repositories/mock_dashboard_repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/home_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/home_effect.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_tab.dart';

class ControlledHomeRepository implements DashboardHomeRepository {
  final requests = <Completer<Result<DashboardHomeData?>>>[];

  @override
  Future<Result<DashboardHomeData?>> getHome() => requests.removeAt(0).future;
}

void main() {
  test(
    'blank prompts are ignored and repeated submissions remain observable',
    () async {
      final cubit = HomeCubit(repositories: homeRepositories());
      addTearDown(cubit.close);
      cubit.submitPrompt('   ');
      expect(cubit.state.effectId, 0);
      cubit.submitPrompt('  سوال من  ');
      expect(cubit.state.submittedPrompt, 'سوال من');
      expect(cubit.state.effect, const HomePromptSubmitted('سوال من'));
      final firstId = cubit.state.effectId;
      cubit.submitPrompt('سوال من');
      expect(cubit.state.effectId, firstId + 1);
    },
  );

  test(
    'assistant service returns from a banking tab through Home state',
    () async {
      final cubit = HomeCubit(repositories: homeRepositories());
      addTearDown(cubit.close);
      cubit.selectTab(AppPrimaryTab.deposits);
      cubit.requestService(DashboardService.assistant);
      expect(cubit.state.selectedTab, AppPrimaryTab.dashboard);
      expect(cubit.state.effect, const HomeAssistantRequested());
    },
  );

  test(
    'favorite picker and reset require an active edit transaction',
    () async {
      final cubit = HomeCubit(repositories: homeRepositories());
      addTearDown(cubit.close);
      cubit.requestFavoritePicker();
      cubit.requestFavoritesReset();
      expect(cubit.state.effectId, 0);
      await cubit.loadHome();
      cubit.editFavorites();
      cubit.requestFavoritePicker();
      expect(cubit.state.effect, const HomeFavoritePickerRequested());
      cubit.requestFavoritesReset();
      expect(cubit.state.effect, const HomeFavoritesResetRequested());
      cubit.cancelFavorites();
      final lastId = cubit.state.effectId;
      cubit.requestFavoritePicker();
      cubit.requestFavoritesReset();
      expect(cubit.state.effectId, lastId);
    },
  );

  test(
    'reload clears data, draft and failure and emits the new state shape',
    () async {
      final repository = ControlledHomeRepository();
      final cubit = HomeCubit(repositories: homeRepositories(home: repository));
      final states = <HomeState>[];
      final subscription = cubit.stream.listen(states.add);
      addTearDown(() async {
        await subscription.cancel();
        await cubit.close();
      });
      expect(cubit.state, const HomeState.initial());
      final first = Completer<Result<DashboardHomeData?>>();
      repository.requests.add(first);
      final load = cubit.loadHome();
      first.complete(
        Success(DashboardHomeData(walletBalance: '123', favorites: ['one'])),
      );
      await load;
      final data = cubit.state.homeData!;
      cubit.editFavorites();
      cubit.addFavorite('two');

      final failed = Completer<Result<DashboardHomeData?>>();
      repository.requests.add(failed);
      final reload = cubit.loadHome();
      expect(
        cubit.state,
        const HomeState.initial(homeStatus: RequestStatus.loading),
      );
      failed.complete(const Err(DataFailure('offline')));
      await reload;
      expect(
        cubit.state,
        const HomeState.initial(
          homeStatus: RequestStatus.failure,
          homeFailure: DataFailure('offline'),
        ),
      );

      final empty = Completer<Result<DashboardHomeData?>>();
      repository.requests.add(empty);
      final retry = cubit.loadHome();
      expect(
        cubit.state,
        const HomeState.initial(homeStatus: RequestStatus.loading),
      );
      empty.complete(const Success(null));
      await retry;
      await Future<void>.delayed(Duration.zero);
      expect(states, [
        const HomeState.initial(homeStatus: RequestStatus.loading),
        HomeState.initial(
          homeStatus: RequestStatus.success,
          homeData: data,
          activeFavorites: ['one'],
        ),
        HomeState.initial(
          homeStatus: RequestStatus.success,
          homeData: data,
          draft: ['one'],
          activeFavorites: ['one'],
        ),
        HomeState.initial(
          homeStatus: RequestStatus.success,
          homeData: data,
          draft: ['one', 'two'],
          activeFavorites: ['one', 'two'],
        ),
        const HomeState.initial(homeStatus: RequestStatus.loading),
        const HomeState.initial(
          homeStatus: RequestStatus.failure,
          homeFailure: DataFailure('offline'),
        ),
        const HomeState.initial(homeStatus: RequestStatus.loading),
        const HomeState.initial(homeStatus: RequestStatus.success),
      ]);
    },
  );

  test('Home ignores stale loads and completions after close', () async {
    final repository = ControlledHomeRepository();
    final cubit = HomeCubit(repositories: homeRepositories(home: repository));
    final stale = Completer<Result<DashboardHomeData?>>();
    final latest = Completer<Result<DashboardHomeData?>>();
    repository.requests.addAll([stale, latest]);
    final firstLoad = cubit.loadHome();
    final secondLoad = cubit.loadHome();
    latest.complete(Success(DashboardHomeData(walletBalance: 'latest')));
    await secondLoad;
    stale.complete(const Err(DataFailure('stale')));
    await firstLoad;
    expect(cubit.state.homeStatus, RequestStatus.success);
    expect(cubit.state.homeData!.walletBalance, 'latest');
    expect(cubit.state.homeFailure, isNull);

    final pending = Completer<Result<DashboardHomeData?>>();
    repository.requests.add(pending);
    final pendingLoad = cubit.loadHome();
    await cubit.close();
    pending.complete(const Success(null));
    await pendingLoad;
    expect(cubit.state.homeStatus, RequestStatus.loading);
  });

  test('draft edits are unique, limited to eight, and transactional', () async {
    final cubit = HomeCubit(
      repositories: homeRepositories(
        home: const MockDashboardHomeRepository(favorites: ['one']),
      ),
    );
    await cubit.loadHome();
    cubit.addFavorite('ignored');
    cubit.editFavorites();
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
      cubit.addFavorite(id);
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
    expect(cubit.state.homeData!.favorites, ['one']);
    cubit.removeFavorite('two');
    cubit.addFavorite('nine');
    cubit.confirmFavorites();
    expect(cubit.state.homeData!.favorites, [
      'one',
      'three',
      'four',
      'five',
      'six',
      'seven',
      'eight',
      'nine',
    ]);
    cubit.editFavorites();
    cubit.removeFavorite('one');
    cubit.cancelFavorites();
    expect(cubit.state.homeData!.favorites.length, 8);
    cubit.resetFavorites();
    expect(cubit.state.homeData!.favorites, isEmpty);
    expect(cubit.state.draft, isNull);
    await cubit.close();
  });
  test('suggestions remain uncommitted until confirmation', () async {
    final cubit = HomeCubit(
      repositories: homeRepositories(home: const MockDashboardHomeRepository()),
    );
    await cubit.loadHome();
    cubit.editFavorites();
    expect(cubit.state.homeData!.favorites, isEmpty);
    expect(cubit.state.draft, [
      'card-issue',
      'loan-consolidate',
      'card-deposit',
    ]);
    cubit.cancelFavorites();
    expect(cubit.state.homeData!.favorites, isEmpty);
    cubit.editFavorites();
    cubit.confirmFavorites();
    cubit.editFavorites();
    expect(cubit.state.draft, [
      'card-issue',
      'loan-consolidate',
      'card-deposit',
    ]);
    await cubit.close();
  });
}
