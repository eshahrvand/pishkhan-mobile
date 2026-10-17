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

import '../../../../support/dashboard_test_repositories.dart';
import '../../../../support/home_tab_test_scope.dart';

({
  RequestStatus status,
  List<DashboardItem>? items,
  String? selectedId,
  Failure? failure,
})
snapshot(HomeState state, String tab) => switch (tab) {
  'cards' => (
    status: state.cardsStatus,
    items: state.cards,
    selectedId: state.selectedCardId,
    failure: state.cardsFailure,
  ),
  'deposits' => (
    status: state.depositsStatus,
    items: state.deposits,
    selectedId: state.selectedDepositId,
    failure: state.depositsFailure,
  ),
  _ => (
    status: state.loansStatus,
    items: state.loans,
    selectedId: state.selectedLoanId,
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
  'cards' => cubit.loadCards(),
  'deposits' => cubit.loadDeposits(),
  _ => cubit.loadLoans(),
};

void selectItem(HomeCubit cubit, String tab, int index) {
  switch (tab) {
    case 'cards':
      cubit.selectCard(index);
    case 'deposits':
      cubit.selectDeposit(index);
    default:
      cubit.selectLoan(index);
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
        expect(snapshot(cubit.state, tab).items, isNull);
        selectItem(cubit, tab, 99);
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
      final pending = cubit.load();
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
      cubit.editFavorites();
      cubit.addFavorite('card-deposit');
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
      expect(cubit.state.draft, ['card-issue', 'card-deposit']);
      expect(cubit.state.selectedTab, AppPrimaryTab.deposits);
      cubit.confirmFavorites();
      await cubit.loadCards();
      expect(cubit.state.homeData!.favorites, ['card-issue', 'card-deposit']);
      expect(
        cubit.state.selectedDeposit!.id,
        DashboardMockData.singleDeposit.id,
      );
    },
  );

  test(
    'latest requests win per tab; closing prevents all pending completions',
    () async {
      final repository = TestRepositories();
      final oldCard = Completer<Result<List<BankCard>>>();
      final newCard = Completer<Result<List<BankCard>>>();
      final oldLoan = Completer<Result<List<BankLoan>>>();
      final newLoan = Completer<Result<List<BankLoan>>>();
      repository.cardQueue.addAll([oldCard, newCard]);
      repository.loanQueue.addAll([oldLoan, newLoan]);
      final cubit = createHome(repository);
      final oldCardsLoad = cubit.loadCards(), oldLoansLoad = cubit.loadLoans();
      final latestCardsLoad = cubit.loadCards(),
          latestLoansLoad = cubit.loadLoans();
      newCard.complete(const Success([BankCard(id: 'latest')]));
      newLoan.complete(Success([DashboardMockData.loans[1]]));
      await Future.wait([latestCardsLoad, latestLoansLoad]);
      oldCard.complete(const Err(DataFailure('old')));
      oldLoan.complete(const Success([]));
      await Future.wait([oldCardsLoad, oldLoansLoad]);
      expect(cubit.state.selectedCardId, 'latest');
      expect(cubit.state.selectedLoanId, DashboardMockData.loans[1].id);
      final pending = Completer<Result<List<BankDeposit>>>();
      repository.depositQueue.add(pending);
      final load = cubit.loadDeposits();
      await cubit.close();
      pending.complete(const Success([]));
      await load;
      expect(cubit.state.depositsStatus, RequestStatus.loading);
    },
  );

  test(
    'replacing one repository reloads only that tab and rejects old responses',
    () async {
      final old = TestRepositories()
        ..home = Success(
          DashboardHomeData(walletBalance: '123', favorites: ['card-issue']),
        );
      final pending = Completer<Result<List<BankCard>>>();
      old.cardQueue.add(pending);
      final cubit = createHome(old);
      addTearDown(cubit.close);
      await cubit.loadHome();
      await cubit.loadDeposits();
      cubit.editFavorites();
      cubit.selectTab(AppPrimaryTab.loans);
      final oldLoad = cubit.loadCards();
      final replacement = TestRepositories()
        ..cards = const Success([BankCard(id: 'new')]);
      final untouched = Completer<Result<List<BankDeposit>>>();
      old.depositQueue.add(untouched);
      await cubit.changeRepositories(
        homeRepositories(
          home: old,
          cards: replacement,
          deposits: old,
          loans: old,
        ),
      );
      expect(old.depositQueue, hasLength(1));
      pending.complete(const Success([BankCard(id: 'old')]));
      await oldLoad;
      expect(cubit.state.selectedCardId, 'new');
      expect(cubit.state.draft, isNotNull);
      expect(cubit.state.selectedTab, AppPrimaryTab.loans);
      expect(cubit.state.depositsStatus, RequestStatus.success);
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
      expect(cubit.requestCardAction(CardAction.block), isNull);
      await cubit.loadCards();
      expect(
        cubit.requestCardAction(CardAction.setSecondPin)?.card.id,
        'setup',
      );
      expect(cubit.requestCardAction(CardAction.forgotSecondPin), isNull);
      cubit.setCardVisibility('setup', true);
      cubit.selectCard(1);
      expect(cubit.state.cardVisibility['setup'], isTrue);
      expect(cubit.requestCardAction(CardAction.setSecondPin), isNull);
      expect(
        cubit.requestCardAction(CardAction.forgotSecondPin)?.card.id,
        'recovery',
      );
      expect(() => cubit.state.pinActions.clear(), throwsUnsupportedError);
      repository.cards = const Success([BankCard(id: 'recovery')]);
      final reload = cubit.loadCards();
      expect(cubit.state.cardActions, isEmpty);
      expect(cubit.requestCardAction(CardAction.block), isNull);
      await reload;
      expect(
        cubit.requestCardAction(CardAction.setSecondPin)?.card.id,
        'recovery',
      );
    },
  );

  test(
    'cheque eligibility is independent of account count and guarded by Cubit',
    () async {
      final repository = TestRepositories()
        ..deposits = const Success([
          BankDeposit(id: 'without', hasChequeOperations: false),
          BankDeposit(id: 'with', hasChequeOperations: true),
        ]);
      final cubit = createHome(repository);
      addTearDown(cubit.close);
      await cubit.loadDeposits();
      expect(cubit.state.depositChequeActions, isEmpty);
      expect(cubit.requestDepositAction(DepositAction.issueCheque), isNull);
      cubit.selectDeposit(1);
      expect(
        cubit.requestDepositAction(DepositAction.issueCheque)?.deposit.id,
        'with',
      );
      expect(cubit.state.effect, isA<HomeDepositActionRequested>());
    },
  );

  test(
    'typed effects support repeated actions and validate copied item IDs',
    () async {
      final cubit = createHome(TestRepositories());
      addTearDown(cubit.close);
      await cubit.load();
      cubit.requestCardAction(CardAction.block);
      final id = cubit.state.effectId;
      cubit.requestCardAction(CardAction.block);
      expect(cubit.state.effectId, id + 1);
      cubit.copyCardNumber(cubit.state.selectedCard!.id);
      expect(
        cubit.state.effect,
        HomeCardNumberCopyRequested(cubit.state.selectedCard!.number),
      );
      cubit.copyDepositIban(cubit.state.selectedDeposit!.id);
      expect(
        cubit.state.effect,
        HomeDepositIbanCopyRequested(cubit.state.selectedDeposit!.iban),
      );
      cubit.requestLoanDetails(cubit.state.selectedLoan!.id);
      expect(
        cubit.state.effect,
        HomeLoanDetailsRequested(cubit.state.selectedLoan!),
      );
      final before = cubit.state.effectId;
      cubit.copyLoanNumber('unknown');
      cubit.copyCardNumber('unknown');
      expect(cubit.state.effectId, before);
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
      await cubit.loadCards();
      parts[0] = '0000';
      input.clear();
      expect(cubit.state.cards![0].number, '1234567890123456');
      expect(() => cubit.state.cards!.clear(), throwsUnsupportedError);
      cubit.setCardVisibility('a', true);
      expect(
        () => cubit.state.cardVisibility['a'] = false,
        throwsUnsupportedError,
      );
      repository.cards = const Success([
        BankCard(id: 'duplicate'),
        BankCard(id: 'duplicate'),
      ]);
      await cubit.loadCards();
      expect(cubit.state.cardsFailure!.code, 'dashboard.items.invalid');
      repository.throwOnCards = true;
      await cubit.loadCards();
      expect(cubit.state.cardsFailure!.code, 'unexpected');
    },
  );
}
