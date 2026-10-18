import '../../../../../support/registered_dependency.dart';

import 'package:pishkhan_mobile/features/dashboard/domain/repositories/dashboard_repositories.dart';

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/dashboard/data/datasources/dashboard_mock_data.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_card.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_deposit.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_loan.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/dashboard_home_data.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/dashboard_item.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/home_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/home_effect.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/card_actions.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/deposit_actions.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_tab.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';

import '../../../../support/dashboard_test_repositories.dart';

({
  RequestStatus status,
  List<DashboardItem>? items,
  String? selectedId,
  Failure? failure,
})
snapshot(HomeState state, String tab) => switch (tab) {
  'cards' => (
    status: state.cardsStatus,
    items: state.visibleCards,
    selectedId: state.selectedCard?.id,
    failure: state.cardsFailure,
  ),
  'deposits' => (
    status: state.depositsStatus,
    items: state.visibleDeposits,
    selectedId: state.selectedDeposit?.id,
    failure: state.depositsFailure,
  ),
  _ => (
    status: state.loansStatus,
    items: state.visibleLoans,
    selectedId: state.selectedLoan?.id,
    failure: state.loansFailure,
  ),
};

HomeCubit createHome(TestRepositories repository) =>
    withRegisteredDependency<DashboardRepositories, HomeCubit>(
      homeRepositories(
        home: repository,
        cards: repository,
        deposits: repository,
        loans: repository,
      ),
      () => HomeCubit(),
    );

Future<void> loadTab(HomeCubit cubit, String tab) => switch (tab) {
  'cards' => cubit.fetchCards(),
  'deposits' => cubit.fetchDeposits(),
  _ => cubit.fetchLoans(),
};

void selectItem(HomeCubit cubit, String tab, int index) {
  switch (tab) {
    case 'cards':
      cubit.selectCard(cubit.state.visibleCards[index]);
    case 'deposits':
      cubit.selectDeposit(cubit.state.visibleDeposits[index]);
    default:
      cubit.selectLoan(cubit.state.visibleLoans[index]);
  }
}

void main() {
  for (final tab in ['cards', 'deposits', 'loans']) {
    test(
      '$tab retains selection on reorder and supports empty/error/retry independently',
      () async {
        final repository = TestRepositories();
        final cubit = createHome(repository);
        addTearDown(cubit.close);
        final loading = loadTab(cubit, tab);
        expect(snapshot(cubit.state, tab).status, RequestStatus.loading);
        await loading;
        final loaded = snapshot(cubit.state, tab).items!;
        selectItem(cubit, tab, 1);
        final selected = snapshot(cubit.state, tab).selectedId;
        switch (tab) {
          case 'cards':
            repository.cards = Success(
              loaded.reversed.cast<BankCard>().toList(),
            );
          case 'deposits':
            repository.deposits = Success(
              loaded.reversed.cast<BankDeposit>().toList(),
            );
          default:
            repository.loans = Success(
              loaded.reversed.cast<BankLoan>().toList(),
            );
        }
        await loadTab(cubit, tab);
        expect(snapshot(cubit.state, tab).selectedId, selected);
        switch (tab) {
          case 'cards':
            repository.cards = const Success([]);
          case 'deposits':
            repository.deposits = const Success([]);
          default:
            repository.loans = const Success([]);
        }
        await loadTab(cubit, tab);
        expect(snapshot(cubit.state, tab).items, isEmpty);
        switch (tab) {
          case 'cards':
            repository.cards = const Err(DataFailure('offline'));
          case 'deposits':
            repository.deposits = const Err(DataFailure('offline'));
          default:
            repository.loans = const Err(DataFailure('offline'));
        }
        await loadTab(cubit, tab);
        expect(snapshot(cubit.state, tab).failure!.code, 'offline');
        switch (tab) {
          case 'cards':
            repository.cards = const Success([DashboardMockData.singleCard]);
          case 'deposits':
            repository.deposits = const Success([
              DashboardMockData.singleDeposit,
            ]);
          default:
            repository.loans = const Success([DashboardMockData.singleLoan]);
        }
        await loadTab(cubit, tab);
        expect(snapshot(cubit.state, tab).items, hasLength(1));
        expect(snapshot(cubit.state, tab).failure, isNull);
        expect(cubit.state.homeStatus, RequestStatus.initial);
      },
    );
  }

  test(
    'four concurrent responses preserve the other tabs and draft edits',
    () async {
      final repository = TestRepositories();
      final home = Completer<Result<DashboardHomeData?>>();
      final cards = Completer<Result<List<BankCard>>>();
      final deposits = Completer<Result<List<BankDeposit>>>();
      final loans = Completer<Result<List<BankLoan>>>();
      repository.homeQueue.add(home);
      repository.cardQueue.add(cards);
      repository.depositQueue.add(deposits);
      repository.loanQueue.add(loans);
      final cubit = createHome(repository);
      addTearDown(cubit.close);
      final pending = cubit.fetchDashboard();
      expect(cubit.state.homeStatus, RequestStatus.loading);
      expect(cubit.state.cardsStatus, RequestStatus.loading);
      expect(cubit.state.depositsStatus, RequestStatus.loading);
      expect(cubit.state.loansStatus, RequestStatus.loading);
      home.complete(
        Success(
          DashboardHomeData(walletBalance: '123', favorites: ['card-issue']),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      cubit.beginFavoritesEditing();
      cubit.addFavorite(DashboardService.cardDeposit);
      cubit.selectTab(AppPrimaryTab.deposits);
      loans.complete(const Success([DashboardMockData.singleLoan]));
      cards.complete(const Err(DataFailure('offline')));
      deposits.complete(const Success([DashboardMockData.singleDeposit]));
      await pending;
      expect(cubit.state.cardsStatus, RequestStatus.failure);
      expect(cubit.state.cardsFailure!.code, 'offline');
      expect(cubit.state.homeStatus, RequestStatus.success);
      expect(cubit.state.depositsStatus, RequestStatus.success);
      expect(cubit.state.loansStatus, RequestStatus.success);
      expect(cubit.state.favoriteServices, [
        DashboardService.issue,
        DashboardService.cardDeposit,
      ]);
      expect(cubit.state.selectedTab, AppPrimaryTab.deposits);
      cubit.applyFavorites();
      await cubit.fetchCards();
      expect(cubit.state.homeData!.favorites, ['card-issue', 'card-deposit']);
      expect(
        cubit.state.selectedDeposit!.id,
        DashboardMockData.singleDeposit.id,
      );
    },
  );

  test(
    'card eligibility, request context and visibility follow selection',
    () async {
      final repository = TestRepositories()
        ..cards = const Success([
          BankCard(id: 'setup'),
          BankCard(id: 'recovery', canSetSecondPin: false),
        ]);
      final cubit = createHome(repository);
      addTearDown(cubit.close);
      await cubit.fetchCards();
      cubit.requestCardAction(CardAction.setSecondPin);
      expect(
        (cubit.state.effect as HomeCardActionRequested).request.card.id,
        'setup',
      );
      expect(
        cubit.state.pinActions,
        isNot(contains(CardAction.forgotSecondPin)),
      );
      cubit.updateCardVisibility(cubit.state.visibleCards.first, true);
      cubit.selectCard(cubit.state.visibleCards[1]);
      expect(cubit.state.cardVisibility['setup'], isTrue);
      expect(cubit.state.pinActions, isNot(contains(CardAction.setSecondPin)));
      cubit.requestCardAction(CardAction.forgotSecondPin);
      expect(
        (cubit.state.effect as HomeCardActionRequested).request.card.id,
        'recovery',
      );
      expect(() => cubit.state.pinActions.clear(), throwsUnsupportedError);
      repository.cards = const Success([BankCard(id: 'recovery')]);
      final reload = cubit.fetchCards();
      expect(cubit.state.cardActions, isEmpty);
      await reload;
      cubit.requestCardAction(CardAction.setSecondPin);
      expect(
        (cubit.state.effect as HomeCardActionRequested).request.card.id,
        'recovery',
      );
    },
  );

  test('cheque availability is prepared for the selected account', () async {
    final repository = TestRepositories()
      ..deposits = const Success([
        BankDeposit(id: 'without', hasChequeOperations: false),
        BankDeposit(id: 'with', hasChequeOperations: true),
      ]);
    final cubit = createHome(repository);
    addTearDown(cubit.close);
    await cubit.fetchDeposits();
    expect(cubit.state.depositChequeActions, isEmpty);
    cubit.selectDeposit(cubit.state.visibleDeposits[1]);
    cubit.requestDepositAction(DepositAction.issueCheque);
    expect(
      (cubit.state.effect as HomeDepositActionRequested).request.deposit.id,
      'with',
    );
    expect(cubit.state.effect, isA<HomeDepositActionRequested>());
  });

  test(
    'typed effects support repeated actions and carry the rendered models',
    () async {
      final cubit = createHome(TestRepositories());
      addTearDown(cubit.close);
      await cubit.fetchDashboard();
      cubit.requestCardAction(CardAction.block);
      final id = cubit.state.effectId;
      cubit.requestCardAction(CardAction.block);
      expect(cubit.state.effectId, id + 1);
      cubit.requestCardNumberCopy(cubit.state.selectedCard!);
      expect(
        cubit.state.effect,
        HomeCardNumberCopyRequested(cubit.state.selectedCard!.number),
      );
      cubit.requestDepositIbanCopy(cubit.state.selectedDeposit!);
      expect(
        cubit.state.effect,
        HomeDepositIbanCopyRequested(cubit.state.selectedDeposit!.iban),
      );
      cubit.requestLoanDetails(cubit.state.selectedLoan!);
      expect(
        cubit.state.effect,
        HomeLoanDetailsRequested(cubit.state.selectedLoan!),
      );
      cubit.requestMenu(AppPrimaryTab.deposits);
      expect((cubit.state.effect as HomeMenuRequested).category, isNotEmpty);
      cubit.requestAssistant();
      expect(cubit.state.selectedTab, AppPrimaryTab.dashboard);
    },
  );

  test(
    'item snapshots and visibility cannot mutate and invalid contracts fail',
    () async {
      final parts = ['1234', '5678', '9012', '3456'];
      final input = [
        BankCard(id: 'a', numberParts: parts),
        const BankCard(id: 'b'),
      ];
      final repository = TestRepositories()..cards = Success(input);
      final cubit = createHome(repository);
      addTearDown(cubit.close);
      await cubit.fetchCards();
      parts[0] = '0000';
      input.clear();
      expect(cubit.state.visibleCards[0].number, '1234567890123456');
      expect(() => cubit.state.visibleCards.clear(), throwsUnsupportedError);
      cubit.updateCardVisibility(cubit.state.visibleCards.first, true);
      expect(
        () => cubit.state.cardVisibility['a'] = false,
        throwsUnsupportedError,
      );
      repository.cards = const Success([
        BankCard(id: 'duplicate'),
        BankCard(id: 'duplicate'),
      ]);
      await cubit.fetchCards();
      expect(cubit.state.cardsFailure!.code, 'dashboard.items.invalid');
      repository.throwOnCards = true;
      await cubit.fetchCards();
      expect(cubit.state.cardsFailure!.code, 'unexpected');
    },
  );
}
