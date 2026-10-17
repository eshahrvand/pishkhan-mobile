import '../../support/registered_dependency.dart';

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/cards/data/repositories/mock_card_services_repository.dart';
import 'package:pishkhan_mobile/features/cards/domain/entities/card_service_data.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/card_services_repository.dart';
import 'package:pishkhan_mobile/features/cards/presentation/change_card_deposit/cubit/change_card_deposit_cubit.dart';
import 'package:pishkhan_mobile/features/cards/presentation/expired_gift_balance/cubit/expired_gift_balance_cubit.dart';

class TestCardServicesRepository implements CardServicesRepository {
  TestCardServicesRepository({CardServiceCatalog? catalog})
    : mock = MockCardServicesRepository(catalog: catalog);
  final MockCardServicesRepository mock;
  int loadCalls = 0;
  Completer<Result<CardServiceCatalog>>? pendingLoad;
  Completer<Result<CardServiceReceipt>>? pendingSubmit;
  bool failSubmit = false, throwLoad = false;
  final changes = <ChangeCardDepositRequest>[];
  final transfers = <GiftBalanceRequest>[];
  @override
  Future<Result<CardServiceCatalog>> load() async {
    loadCalls++;
    if (throwLoad) throw StateError('unavailable');
    return pendingLoad?.future ?? mock.load();
  }

  @override
  Future<Result<CardServiceReceipt>> changeDeposit(
    ChangeCardDepositRequest request,
  ) async {
    changes.add(request);
    return pendingSubmit?.future ??
        (failSubmit
            ? const Err(DataFailure('offline'))
            : mock.changeDeposit(request));
  }

  @override
  Future<Result<CardServiceReceipt>> transferGiftBalance(
    GiftBalanceRequest request,
  ) async {
    transfers.add(request);
    return pendingSubmit?.future ??
        (failSubmit
            ? const Err(DataFailure('offline'))
            : mock.transferGiftBalance(request));
  }
}

CardServiceCatalog singleAccountCatalog() {
  final sample = MockCardServicesRepository.examples;
  return CardServiceCatalog(
    deposits: [sample.deposits.first],
    cards: [],
    gifts: [
      for (final c in sample.gifts)
        ExpiredGiftCard(
          id: c.id,
          number: c.number,
          depositId: sample.deposits.first.id,
          balanceRial: c.balanceRial,
        ),
    ],
    changeDepositFeeRial: 0,
    walletBalanceRial: 0,
  );
}

void main() {
  test('change deposit starts empty, requires a new deposit and terms, resets on card change', () async {
    final repo = TestCardServicesRepository();
    final cubit =
        withRegisteredDependency<
          CardServicesRepository,
          ChangeCardDepositCubit
        >(repo, () => ChangeCardDepositCubit());
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.card, isNull);
    expect(cubit.state.canSubmit, isFalse);
    cubit.selectCard('card-1');
    expect(cubit.state.source!.id, 'deposit-1');
    cubit.selectDestination('deposit-1');
    expect(cubit.state.destinationId, isNull);
    cubit.selectDestination('deposit-2');
    expect(cubit.state.canSubmit, isFalse);
    cubit.acceptTerms(true);
    expect(cubit.state.canSubmit, isTrue);
    cubit.selectCard('card-3');
    expect(cubit.state.source!.id, 'deposit-2');
    expect(cubit.state.destinationId, isNull);
    expect(cubit.state.termsAccepted, isFalse);
    cubit.selectCard('unknown');
    expect(cubit.state.cardId, 'card-3');
  });
  test('selected card seed normalizes Persian digits and grouping', () async {
    final c =
        withRegisteredDependency<
          CardServicesRepository,
          ChangeCardDepositCubit
        >(
          TestCardServicesRepository(),
          () =>
              ChangeCardDepositCubit(initialCardNumber: '۵۰۴۱ ۷۲۱۲ ۲۳۴۵ ۶۷۸۷'),
        );
    addTearDown(c.close);
    await c.load();
    expect(c.state.cardId, 'card-1');
  });
  test('insufficient wallet prevents submission', () async {
    final sample = MockCardServicesRepository.examples;
    final c =
        withRegisteredDependency<
          CardServicesRepository,
          ChangeCardDepositCubit
        >(
          TestCardServicesRepository(
            catalog: CardServiceCatalog(
              deposits: sample.deposits,
              cards: sample.cards,
              gifts: sample.gifts,
              changeDepositFeeRial: 10,
              walletBalanceRial: 9,
            ),
          ),
          () => ChangeCardDepositCubit(),
        );
    addTearDown(c.close);
    await c.load();
    c.selectCard('card-1');
    c.selectDestination('deposit-2');
    c.acceptTerms(true);
    expect(c.state.canSubmit, isFalse);
  });
  test(
    'duplicate submits and edits are blocked, retry reuses request key',
    () async {
      final repo = TestCardServicesRepository()..failSubmit = true;
      final c =
          withRegisteredDependency<
            CardServicesRepository,
            ChangeCardDepositCubit
          >(repo, () => ChangeCardDepositCubit());
      addTearDown(c.close);
      await c.load();
      c.selectCard('card-1');
      c.selectDestination('deposit-2');
      c.acceptTerms(true);
      await c.submit();
      expect(c.state.submissionStatus, RequestStatus.failure);
      repo.failSubmit = false;
      repo.pendingSubmit = Completer();
      final submit = c.submit();
      c.selectCard('card-3');
      await c.submit();
      await c.load();
      expect(repo.changes.length, 2);
      expect(c.state.cardId, 'card-1');
      expect(
        repo.changes.first.idempotencyKey,
        repo.changes.last.idempotencyKey,
      );
      repo.pendingSubmit!.complete(
        const Success(CardServiceReceipt(reference: 'demo', isMock: true)),
      );
      await submit;
      expect(c.state.receipt!.reference, 'demo');
      expect(c.state.editable, isFalse);
    },
  );
  test('gifts normalize search and toggle all visible without losing hidden selection', () async {
    final c =
        withRegisteredDependency<
          CardServicesRepository,
          ExpiredGiftBalanceCubit
        >(TestCardServicesRepository(), () => ExpiredGiftBalanceCubit());
    addTearDown(c.close);
    await c.load();
    expect(c.state.hasFilter, isTrue);
    c.toggleCard('gift-1');
    c.search('۵۰۴۱-۷۲۱۴ ۵۶۷۸۳۴۰۷');
    expect(c.state.visibleCards.map((c) => c.id), ['gift-0']);
    c.selectAllVisible(true);
    expect(c.state.selectedIds, {'gift-0', 'gift-1'});
    expect(c.state.totalRial, 2000000);
    c.selectAllVisible(false);
    expect(c.state.selectedIds, {'gift-1'});
  });
  test('filter is staged and cancellable, selections survive applying and clearing', () async {
    final c =
        withRegisteredDependency<
          CardServicesRepository,
          ExpiredGiftBalanceCubit
        >(TestCardServicesRepository(), () => ExpiredGiftBalanceCubit());
    addTearDown(c.close);
    await c.load();
    c.toggleCard('gift-1');
    c.beginFilter();
    c.selectDraftFilter('deposit-1');
    expect(c.state.visibleCards.length, 5);
    c.cancelFilter();
    expect(c.state.filterDepositId, isNull);
    c.beginFilter();
    c.selectDraftFilter('deposit-1');
    c.applyFilter();
    expect(c.state.visibleCards.map((c) => c.id), [
      'gift-0',
      'gift-2',
      'gift-4',
    ]);
    expect(c.state.selectedIds, {'gift-1'});
    c.beginFilter();
    c.selectDraftFilter(null);
    c.applyFilter();
    expect(c.state.visibleCards.length, 5);
  });
  test('one account hides and disables the filter', () async {
    final c =
        withRegisteredDependency<
          CardServicesRepository,
          ExpiredGiftBalanceCubit
        >(
          TestCardServicesRepository(catalog: singleAccountCatalog()),
          () => ExpiredGiftBalanceCubit(),
        );
    addTearDown(c.close);
    await c.load();
    expect(c.state.hasFilter, isFalse);
    c.beginFilter();
    expect(c.state.filterOpen, isFalse);
  });
  test('review removes cards, dismiss stays on selection, Back advances and total remains accurate', () async {
    final c =
        withRegisteredDependency<
          CardServicesRepository,
          ExpiredGiftBalanceCubit
        >(TestCardServicesRepository(), () => ExpiredGiftBalanceCubit());
    addTearDown(c.close);
    await c.load();
    expect(c.beginReview(), isFalse);
    c.selectAllVisible(true);
    expect(c.beginReview(), isTrue);
    c.removeSelected('gift-2');
    c.search('999');
    expect(c.state.query, '');
    expect(c.state.totalRial, 4000000);
    c.finishReview();
    expect(c.state.step, GiftBalanceStep.selection);
    c.beginReview();
    c.finishReview(advance: true);
    expect(c.state.step, GiftBalanceStep.destination);
    c.selectDestination('deposit-2');
    c.acceptTerms(true);
    expect(c.state.canSubmit, isTrue);
    c.beginReview();
    c.removeSelected('gift-1');
    c.finishReview();
    expect(c.state.termsAccepted, isFalse);
    expect(c.state.totalRial, 3000000);
    c.acceptTerms(true);
    await c.submit();
    expect(c.state.receipt!.isMock, isTrue);
  });
  test(
    'removing the last card from destination review returns to selection',
    () async {
      final c =
          withRegisteredDependency<
            CardServicesRepository,
            ExpiredGiftBalanceCubit
          >(TestCardServicesRepository(), () => ExpiredGiftBalanceCubit());
      addTearDown(c.close);
      await c.load();
      c.toggleCard('gift-0');
      c.beginReview();
      c.finishReview(advance: true);
      c.beginReview();
      c.removeSelected('gift-0');
      c.finishReview();
      expect(c.state.step, GiftBalanceStep.selection);
      expect(c.state.canContinue, isFalse);
    },
  );
  test(
    'back preserves cards and destination but requires consent again',
    () async {
      final c =
          withRegisteredDependency<
            CardServicesRepository,
            ExpiredGiftBalanceCubit
          >(TestCardServicesRepository(), () => ExpiredGiftBalanceCubit());
      addTearDown(c.close);
      await c.load();
      c.toggleCard('gift-0');
      c.beginReview();
      c.finishReview(advance: true);
      c.selectDestination('deposit-2');
      c.acceptTerms(true);
      expect(c.back(), isTrue);
      expect(c.state.selectedIds, {'gift-0'});
      expect(c.state.termsAccepted, isFalse);
      expect(c.back(), isFalse);
    },
  );
  test(
    'gift submission gates edits and duplicate transfer and retries safely',
    () async {
      final repo = TestCardServicesRepository()..failSubmit = true;
      final c =
          withRegisteredDependency<
            CardServicesRepository,
            ExpiredGiftBalanceCubit
          >(repo, () => ExpiredGiftBalanceCubit());
      addTearDown(c.close);
      await c.load();
      c.toggleCard('gift-0');
      c.beginReview();
      c.finishReview(advance: true);
      c.selectDestination('deposit-2');
      c.acceptTerms(true);
      await c.submit();
      expect(c.state.submissionStatus, RequestStatus.failure);
      repo.pendingSubmit = Completer();
      final pending = c.submit();
      c.selectDestination('deposit-1');
      c.acceptTerms(false);
      await c.submit();
      expect(c.state.destinationId, 'deposit-2');
      expect(repo.transfers.length, 2);
      expect(
        repo.transfers.first.idempotencyKey,
        repo.transfers.last.idempotencyKey,
      );
      repo.pendingSubmit!.complete(
        const Success(CardServiceReceipt(reference: 'GB-demo', isMock: true)),
      );
      await pending;
      expect(c.state.receipt!.reference, 'GB-demo');
    },
  );
  test('latest load wins and a closed cubit ignores delayed results', () async {
    final firstLoad = Completer<Result<CardServiceCatalog>>();
    final repo = TestCardServicesRepository()..pendingLoad = firstLoad;
    final c =
        withRegisteredDependency<
          CardServicesRepository,
          ExpiredGiftBalanceCubit
        >(repo, () => ExpiredGiftBalanceCubit());
    final pending = c.load();
    repo.pendingLoad = null;
    await c.load();
    expect(c.state.status, RequestStatus.success);
    await c.close();
    firstLoad.complete(const Err(DataFailure('superseded')));
    await pending;
    final closedRepo = TestCardServicesRepository();
    final completer = Completer<Result<CardServiceCatalog>>();
    closedRepo.pendingLoad = completer;
    final closed =
        withRegisteredDependency<
          CardServicesRepository,
          ChangeCardDepositCubit
        >(closedRepo, () => ChangeCardDepositCubit());
    final load = closed.load();
    await closed.close();
    completer.complete(Success(closedRepo.mock.catalog));
    await load;
    expect(c.state.status, RequestStatus.success);
  });
  test(
    'repository exception and invalid catalog become recoverable failures',
    () async {
      final repo = TestCardServicesRepository()..throwLoad = true;
      final c =
          withRegisteredDependency<
            CardServicesRepository,
            ChangeCardDepositCubit
          >(repo, () => ChangeCardDepositCubit());
      addTearDown(c.close);
      await c.load();
      expect(c.state.status, RequestStatus.failure);
      repo.throwLoad = false;
      await c.load();
      expect(c.state.status, RequestStatus.success);
      final invalid =
          withRegisteredDependency<
            CardServicesRepository,
            ExpiredGiftBalanceCubit
          >(
            TestCardServicesRepository(
              catalog: CardServiceCatalog(
                deposits: [],
                cards: [],
                gifts: [
                  const ExpiredGiftCard(
                    id: 'g',
                    number: '1',
                    depositId: 'missing',
                    balanceRial: 1,
                  ),
                ],
                changeDepositFeeRial: 0,
                walletBalanceRial: 0,
              ),
            ),
            () => ExpiredGiftBalanceCubit(),
          );
      addTearDown(invalid.close);
      await invalid.load();
      expect(invalid.state.status, RequestStatus.failure);
    },
  );
}
