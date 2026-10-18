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
    await cubit.fetchCatalog();
    expect(cubit.state.card, isNull);
    expect(cubit.state.canSubmit, isFalse);
    cubit.selectCard(
      cubit.state.catalog!.cards.firstWhere((card) => card.id == 'card-1'),
    );
    expect(cubit.state.source!.id, 'deposit-1');
    expect(
      cubit.state.destinations.map((deposit) => deposit.id),
      isNot(contains('deposit-1')),
    );
    cubit.selectDestination(
      cubit.state.destinations.firstWhere(
        (deposit) => deposit.id == 'deposit-2',
      ),
    );
    expect(cubit.state.canSubmit, isFalse);
    cubit.updateTermsAcceptance(true);
    expect(cubit.state.canSubmit, isTrue);
    cubit.selectCard(
      cubit.state.catalog!.cards.firstWhere((card) => card.id == 'card-3'),
    );
    expect(cubit.state.source!.id, 'deposit-2');
    expect(cubit.state.destination?.id, isNull);
    expect(cubit.state.termsAccepted, isFalse);
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
    await c.fetchCatalog();
    expect(c.state.card?.id, 'card-1');
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
    await c.fetchCatalog();
    c.selectCard(
      c.state.catalog!.cards.firstWhere((card) => card.id == 'card-1'),
    );
    c.selectDestination(
      c.state.destinations.firstWhere((deposit) => deposit.id == 'deposit-2'),
    );
    c.updateTermsAcceptance(true);
    expect(c.state.canSubmit, isFalse);
  });
  test('submission disables editing and retry reuses request key', () async {
    final repo = TestCardServicesRepository()..failSubmit = true;
    final c =
        withRegisteredDependency<
          CardServicesRepository,
          ChangeCardDepositCubit
        >(repo, () => ChangeCardDepositCubit());
    addTearDown(c.close);
    await c.fetchCatalog();
    c.selectCard(
      c.state.catalog!.cards.firstWhere((card) => card.id == 'card-1'),
    );
    c.selectDestination(
      c.state.destinations.firstWhere((deposit) => deposit.id == 'deposit-2'),
    );
    c.updateTermsAcceptance(true);
    await c.submitDepositChange();
    expect(c.state.submissionStatus, RequestStatus.failure);
    repo.failSubmit = false;
    repo.pendingSubmit = Completer();
    final submit = c.submitDepositChange();
    expect(c.state.isEditable, isFalse);
    expect(c.state.canSubmit, isFalse);
    expect(repo.changes.length, 2);
    expect(c.state.card?.id, 'card-1');
    expect(repo.changes.first.idempotencyKey, repo.changes.last.idempotencyKey);
    repo.pendingSubmit!.complete(
      const Success(CardServiceReceipt(reference: 'demo', isMock: true)),
    );
    await submit;
    expect(c.state.receipt!.reference, 'demo');
    expect(c.state.isEditable, isFalse);
  });
  test(
    'deposit change preserves supplied state without loading in constructor',
    () async {
      final repo = TestCardServicesRepository();
      const initialState = ChangeCardDepositState.initial(termsAccepted: true);
      final cubit =
          withRegisteredDependency<
            CardServicesRepository,
            ChangeCardDepositCubit
          >(repo, () => ChangeCardDepositCubit(initialState: initialState));
      addTearDown(cubit.close);
      expect(cubit.state, same(initialState));
      expect(repo.loadCalls, 0);
    },
  );

  test(
    'editing a failed request clears its error and creates a new request key',
    () async {
      final repo = TestCardServicesRepository()..failSubmit = true;
      final cubit =
          withRegisteredDependency<
            CardServicesRepository,
            ChangeCardDepositCubit
          >(repo, () => ChangeCardDepositCubit());
      addTearDown(cubit.close);
      await cubit.fetchCatalog();
      cubit.selectCard(cubit.state.catalog!.cards.first);
      cubit.selectDestination(cubit.state.destinations.first);
      cubit.updateTermsAcceptance(true);
      await cubit.submitDepositChange();
      expect(cubit.state.catalogStatus, RequestStatus.success);
      expect(cubit.state.catalogFailure, isNull);
      expect(cubit.state.submissionFailure, isA<DataFailure>());
      expect(cubit.state.canSubmit, isTrue);
      cubit.selectCard(
        cubit.state.catalog!.cards.firstWhere((card) => card.id == 'card-3'),
      );
      expect(cubit.state.submissionFailure, isNull);
      expect(cubit.state.destination, isNull);
      cubit.selectDestination(cubit.state.destinations.first);
      cubit.updateTermsAcceptance(true);
      await cubit.submitDepositChange();
      expect(
        repo.changes.last.idempotencyKey,
        isNot(repo.changes.first.idempotencyKey),
      );
      expect(repo.changes.last.cardId, 'card-3');
      expect(repo.changes.last.sourceDepositId, 'deposit-2');
    },
  );

  test('changing destination resets consent and request identity', () async {
    final sample = MockCardServicesRepository.examples;
    final repo = TestCardServicesRepository(
      catalog: CardServiceCatalog(
        deposits: [
          ...sample.deposits,
          const CardServiceDeposit(id: 'deposit-3', number: '10.123456.3'),
        ],
        cards: sample.cards,
        gifts: sample.gifts,
        changeDepositFeeRial: sample.changeDepositFeeRial,
        walletBalanceRial: sample.walletBalanceRial,
      ),
    )..failSubmit = true;
    final cubit =
        withRegisteredDependency<
          CardServicesRepository,
          ChangeCardDepositCubit
        >(repo, () => ChangeCardDepositCubit());
    addTearDown(cubit.close);
    await cubit.fetchCatalog();
    cubit.selectCard(cubit.state.catalog!.cards.first);
    cubit.selectDestination(cubit.state.destinations.first);
    cubit.updateTermsAcceptance(true);
    await cubit.submitDepositChange();
    // Pick another rendered deposit after a failed attempt.
    cubit.selectDestination(cubit.state.destinations.last);
    expect(cubit.state.termsAccepted, isFalse);
    expect(cubit.state.canSubmit, isFalse);
    expect(cubit.state.submissionFailure, isNull);
    cubit.updateTermsAcceptance(true);
    await cubit.submitDepositChange();
    expect(
      repo.changes.last.idempotencyKey,
      isNot(repo.changes.first.idempotencyKey),
    );
    expect(repo.changes.last.destinationDepositId, cubit.state.destination!.id);
  });

  test(
    'a seeded card is a clean entry and cancelled exit preserves destination',
    () async {
      final cubit =
          withRegisteredDependency<
            CardServicesRepository,
            ChangeCardDepositCubit
          >(
            TestCardServicesRepository(),
            () => ChangeCardDepositCubit(
              initialCardNumber: '۵۰۴۱ ۷۲۱۲ ۲۳۴۵ ۶۷۸۷',
            ),
          );
      addTearDown(cubit.close);
      await cubit.fetchCatalog();
      cubit.requestBack();
      expect(cubit.state.navigation, FlowNavigation.back);
      cubit.selectDestination(cubit.state.destinations.first);
      cubit.requestBack();
      expect(cubit.state.navigation, FlowNavigation.confirmExit);
      cubit.applyExitConfirmation(null);
      expect(cubit.state.navigation, isNull);
      expect(cubit.state.destination, isNotNull);
    },
  );

  test(
    'invalid change catalog is a catalog failure without submission failure',
    () async {
      final sample = MockCardServicesRepository.examples;
      final cubit =
          withRegisteredDependency<
            CardServicesRepository,
            ChangeCardDepositCubit
          >(
            TestCardServicesRepository(
              catalog: CardServiceCatalog(
                deposits: [],
                cards: sample.cards,
                gifts: [],
                changeDepositFeeRial: 0,
                walletBalanceRial: 0,
              ),
            ),
            () => ChangeCardDepositCubit(),
          );
      addTearDown(cubit.close);
      await cubit.fetchCatalog();
      expect(cubit.state.catalogStatus, RequestStatus.failure);
      expect(cubit.state.catalogFailure, isA<DataFailure>());
      expect(cubit.state.submissionStatus, RequestStatus.initial);
      expect(cubit.state.submissionFailure, isNull);
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
  test(
    'latest gift load wins and a closed gift cubit ignores delayed results',
    () async {
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
      expect(c.state.status, RequestStatus.success);
    },
  );
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
      await c.fetchCatalog();
      expect(c.state.catalogStatus, RequestStatus.failure);
      repo.throwLoad = false;
      await c.fetchCatalog();
      expect(c.state.catalogStatus, RequestStatus.success);
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
