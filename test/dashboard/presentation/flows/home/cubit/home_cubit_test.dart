import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_card.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_deposit.dart';

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/dashboard/data/repositories/mock_dashboard_repositories.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/dashboard_home_data.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/repositories/dashboard_repositories.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/home_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/home_effect.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_tab.dart';

import '../../../../../support/registered_dependency.dart';
import '../../../../support/dashboard_test_repositories.dart';

class ControlledHomeRepository implements DashboardHomeRepository {
  final requests = <Completer<Result<DashboardHomeData?>>>[];

  @override
  Future<Result<DashboardHomeData?>> getHome() => requests.removeAt(0).future;
}

HomeCubit createHome({DashboardHomeRepository? repository}) {
  final cubit = withRegisteredDependency<DashboardRepositories, HomeCubit>(
    homeRepositories(home: repository),
    () => HomeCubit(),
  );
  addTearDown(cubit.close);
  return cubit;
}

void main() {
  test('concurrent failures notify independently and an identical retry notifies again', () async {
    final repository = TestRepositories();
    final cards = Completer<Result<List<BankCard>>>();
    final deposits = Completer<Result<List<BankDeposit>>>();
    repository.cardQueue.add(cards);
    repository.depositQueue.add(deposits);
    final cubit = withRegisteredDependency<DashboardRepositories, HomeCubit>(
      homeRepositories(cards: repository, deposits: repository),
      () => HomeCubit(),
    );
    addTearDown(cubit.close);
    final notifications = <String>[];
    var previous = cubit.state;
    final subscription = cubit.stream.listen((current) {
      if ((previous.cardsStatus != current.cardsStatus &&
              current.cardsStatus == RequestStatus.failure) ||
          (previous.depositsStatus != current.depositsStatus &&
              current.depositsStatus == RequestStatus.failure)) {
        notifications.add(current.message!);
      }
      previous = current;
    });
    addTearDown(subscription.cancel);
    final cardRequest = cubit.fetchCards();
    final depositRequest = cubit.fetchDeposits();
    cards.complete(const Err(DataFailure('network.offline')));
    await cardRequest;
    expect(cubit.state.depositsStatus, RequestStatus.loading);
    deposits.complete(const Err(DataFailure('unknown-bank-code')));
    await depositRequest;
    await Future<void>.delayed(Duration.zero);
    expect(notifications, [
      'ارتباط با سرور برقرار نشد. دوباره تلاش کنید.',
      'درخواست انجام نشد. دوباره تلاش کنید.',
    ]);
    final retry = Completer<Result<List<BankDeposit>>>();
    repository.depositQueue.add(retry);
    final pending = cubit.fetchDeposits();
    expect(cubit.state.message, isNull);
    expect(cubit.state.failure, isNull);
    expect(cubit.state.cardsStatus, RequestStatus.failure);
    retry.complete(const Err(DataFailure('unknown-bank-code')));
    await pending;
    await Future<void>.delayed(Duration.zero);
    expect(notifications, hasLength(3));
    expect(notifications.last, notifications[1]);
    cubit.requestFavoritePicker();
    expect(cubit.state.message, isNull);
    expect(cubit.state.effect, isA<HomeFavoritePickerRequested>());
    cubit.consumeHomeInteraction();
    expect(cubit.state.effect, isNull);
    cubit.requestFavoritePicker();
    expect(cubit.state.effect, isA<HomeFavoritePickerRequested>());
  });

  test(
    'prompt eligibility and repeated submission belong to the home flow',
    () {
      final cubit = createHome();
      cubit.updatePrompt('   ');
      expect(cubit.state.canSubmitPrompt, isFalse);
      cubit.updatePrompt('  سوال من  ');
      expect(cubit.state.canSubmitPrompt, isTrue);
      cubit.submitPrompt();
      expect(cubit.state.submittedPrompt, 'سوال من');
      expect(cubit.state.effect, const HomePromptSubmitted('سوال من'));
      final effectBeforeRepeat = cubit.state.effect;
      cubit.consumeHomeInteraction();
      expect(cubit.state.effect, isNull);
      cubit.submitPrompt();
      expect(cubit.state.effect.runtimeType, effectBeforeRepeat.runtimeType);
    },
  );

  test('assistant service selects Home and prepares a focus effect', () {
    final cubit = createHome();
    cubit.selectTab(AppPrimaryTab.deposits);
    cubit.requestService(DashboardService.assistant);
    expect(cubit.state.selectedTab, AppPrimaryTab.dashboard);
    expect(cubit.state.effect, const HomeAssistantRequested());
    cubit.requestAllServices();
    expect(cubit.state.effect, isA<HomeAllServicesRequested>());
  });

  test(
    'picker cancellation preserves the draft and reset requires confirmation',
    () async {
      final cubit = createHome(
        repository: const MockDashboardHomeRepository(
          favorites: ['card-issue'],
        ),
      );
      await cubit.fetchHome();
      cubit.beginFavoritesEditing();
      cubit.requestFavoritePicker();
      expect(cubit.state.effect, isA<HomeFavoritePickerRequested>());
      expect(
        cubit.state.servicePickerGroups
            .expand((group) => group.choices)
            .singleWhere((choice) => choice.service == DashboardService.issue)
            .canSelect,
        isFalse,
      );
      cubit.applyFavoriteSelection(null);
      expect(cubit.state.favoriteServices, [DashboardService.issue]);
      cubit.applyFavoriteSelection(DashboardService.cardDeposit);
      expect(cubit.state.homeData!.favorites, ['card-issue']);
      cubit.requestFavoritesReset();
      cubit.applyResetConfirmation(false);
      expect(cubit.state.isEditingFavorites, isTrue);
      expect(cubit.state.favoriteServices, hasLength(2));
      cubit.applyResetConfirmation(true);
      expect(cubit.state.homeData!.favorites, isEmpty);
      expect(cubit.state.isEditingFavorites, isFalse);
    },
  );

  test(
    'home failure retries without changing another tab or its failure',
    () async {
      final repository = ControlledHomeRepository();
      final cubit = createHome(repository: repository);
      await cubit.fetchCards();
      final failed = Completer<Result<DashboardHomeData?>>();
      repository.requests.add(failed);
      final pending = cubit.fetchHome();
      expect(cubit.state.homeStatus, RequestStatus.loading);
      failed.complete(const Err(DataFailure('offline')));
      await pending;
      expect(cubit.state.failure?.code, 'offline');
      expect(cubit.state.cardsStatus, RequestStatus.success);
      expect(cubit.state.visibleCards, isNotEmpty);
      final empty = Completer<Result<DashboardHomeData?>>();
      repository.requests.add(empty);
      final retry = cubit.fetchHome();
      empty.complete(const Success(null));
      await retry;
      expect(cubit.state.homeStatus, RequestStatus.success);
      expect(cubit.state.failure, isNull);
      expect(cubit.state.homeData, isNull);
    },
  );

  test(
    'favorite edits reach the limit, commit, cancel and reset transactionally',
    () async {
      final cubit = createHome(
        repository: const MockDashboardHomeRepository(
          favorites: ['card-issue'],
        ),
      );
      await cubit.fetchHome();
      cubit.beginFavoritesEditing();
      final additions = DashboardService.values
          .where((service) => service != DashboardService.issue)
          .take(7);
      for (final service in additions) {
        cubit.addFavorite(service);
      }
      expect(cubit.state.favoriteServices, hasLength(8));
      expect(cubit.state.isFavoritesLimitReached, isTrue);
      expect(cubit.state.canAddFavorite, isFalse);
      expect(cubit.state.homeData!.favorites, ['card-issue']);
      cubit.removeFavorite(cubit.state.favoriteServices.last);
      expect(cubit.state.canAddFavorite, isTrue);
      cubit.applyFavorites();
      final saved = cubit.state.homeData!.favorites;
      cubit.beginFavoritesEditing();
      cubit.removeFavorite(cubit.state.favoriteServices.first);
      cubit.cancelFavorites();
      expect(cubit.state.favoriteServices.map((service) => service.id), saved);
      cubit.beginFavoritesEditing();
      cubit.resetFavorites();
      expect(cubit.state.homeData!.favorites, isEmpty);
      expect(cubit.state.favoriteServices, isEmpty);
      expect(cubit.state.isEditingFavorites, isFalse);
    },
  );

  test('suggestions remain uncommitted until confirmation', () async {
    final cubit = createHome();
    await cubit.fetchHome();
    cubit.beginFavoritesEditing();
    expect(cubit.state.homeData!.favorites, isEmpty);
    expect(cubit.state.favoriteServices, [
      DashboardService.issue,
      DashboardService.consolidation,
      DashboardService.cardDeposit,
    ]);
    cubit.cancelFavorites();
    expect(cubit.state.favoriteServices, isEmpty);
    cubit.beginFavoritesEditing();
    cubit.applyFavorites();
    expect(cubit.state.homeData!.favorites, [
      'card-issue',
      'loan-consolidate',
      'card-deposit',
    ]);
  });
}
