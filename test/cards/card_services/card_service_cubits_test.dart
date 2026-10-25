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
  Completer<Result<CardServiceReceipt>>? pendingSubmit;
  bool failSubmit = false, throwLoad = false;
  final changes = <ChangeCardDepositRequest>[];
  final transfers = <GiftBalanceRequest>[];
  @override
  Future<Result<CardServiceCatalog>> load() async {
    loadCalls++;
    if (throwLoad) throw StateError('unavailable');
    return mock.load();
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
      expect(cubit.state.failure, isA<DataFailure>());
      expect(cubit.state.canSubmit, isTrue);
      cubit.selectCard(
        cubit.state.catalog!.cards.firstWhere((card) => card.id == 'card-3'),
      );
      expect(cubit.state.failure, isNull);
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
    expect(cubit.state.failure, isNull);
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
      expect(cubit.state.failure, isA<DataFailure>());
      expect(cubit.state.submissionStatus, RequestStatus.initial);
    },
  );

  Future<ExpiredGiftBalanceCubit> createGiftCubit({
    TestCardServicesRepository? repository,
  }) async {
    final cubit =
        withRegisteredDependency<
          CardServicesRepository,
          ExpiredGiftBalanceCubit
        >(
          repository ?? TestCardServicesRepository(),
          () => ExpiredGiftBalanceCubit(),
        );
    addTearDown(cubit.close);
    await cubit.fetchCatalog();
    return cubit;
  }

  test('gifts normalize search and toggle visible cards without losing hidden selection', () async {
    final cubit = await createGiftCubit();
    cubit.toggleCard(cubit.state.visibleCards[1]);
    cubit.updateSearchQuery('۵۰۴۱-۷۲۱۴ ۵۶۷۸۳۴۰۷');
    expect(cubit.state.visibleCards.map((card) => card.id), ['gift-0']);
    cubit.selectAllVisible(true);
    expect(cubit.state.selectedCards.map((card) => card.id), [
      'gift-0',
      'gift-1',
    ]);
    expect(cubit.state.totalRial, 2000000);
    expect(cubit.state.isAllVisibleSelected, isTrue);
    cubit.selectAllVisible(false);
    expect(cubit.state.selectedCards.map((card) => card.id), ['gift-1']);
    expect(cubit.state.totalRial, 1000000);
    expect(cubit.state.isAllVisibleSelected, isFalse);
  });

  test(
    'filter drafts apply or cancel without dropping hidden selected cards',
    () async {
      final cubit = await createGiftCubit();
      cubit.toggleCard(cubit.state.visibleCards[1]);
      cubit.requestFilter();
      cubit.selectDraftFilter(cubit.state.filterOptions[1]);
      expect(cubit.state.visibleCards.length, 5);
      expect(cubit.state.isEditable, isFalse);
      cubit.applyFilterResult(null);
      expect(cubit.state.activeFilter.deposit, isNull);
      expect(cubit.state.draftFilter.deposit, isNull);
      expect(cubit.state.isEditable, isTrue);
      cubit.requestFilter();
      cubit.selectDraftFilter(cubit.state.filterOptions[1]);
      cubit.applyFilterResult(true);
      expect(cubit.state.visibleCards.map((card) => card.id), [
        'gift-0',
        'gift-2',
        'gift-4',
      ]);
      expect(cubit.state.selectedCards.map((card) => card.id), ['gift-1']);
      cubit.requestFilter();
      cubit.selectDraftFilter(cubit.state.filterOptions.first);
      cubit.applyFilterResult(false);
      expect(cubit.state.activeFilter.deposit!.id, 'deposit-1');
      cubit.requestFilter();
      cubit.selectDraftFilter(cubit.state.filterOptions.first);
      cubit.applyFilterResult(true);
      expect(cubit.state.visibleCards.length, 5);
    },
  );

  test('one account has no available filter control', () async {
    final cubit = await createGiftCubit(
      repository: TestCardServicesRepository(catalog: singleAccountCatalog()),
    );
    expect(cubit.state.isFilterAvailable, isFalse);
  });

  test('review removes cards, dismissal stays on selection and confirmation advances', () async {
    final cubit = await createGiftCubit();
    cubit.selectAllVisible(true);
    await cubit.submitCurrentStep();
    expect(cubit.state.effect, GiftBalanceEffect.review);
    expect(cubit.state.isEditable, isFalse);
    cubit.removeSelectedCard(cubit.state.selectedCards[2]);
    expect(cubit.state.totalRial, 4000000);
    cubit.applyReviewResult(null);
    expect(cubit.state.step, GiftBalanceStep.selection);
    expect(cubit.state.canContinue, isTrue);
    await cubit.submitCurrentStep();
    cubit.applyReviewResult(true);
    expect(cubit.state.step, GiftBalanceStep.destination);
    expect(cubit.state.canContinue, isFalse);
    cubit.selectDestination(cubit.state.catalog!.deposits[1]);
    cubit.updateTermsAcceptance(true);
    expect(cubit.state.canContinue, isTrue);
    cubit.requestReview();
    cubit.removeSelectedCard(cubit.state.selectedCards[1]);
    cubit.applyReviewResult(true);
    expect(cubit.state.step, GiftBalanceStep.destination);
    expect(cubit.state.termsAccepted, isFalse);
    expect(cubit.state.totalRial, 3000000);
    cubit.updateTermsAcceptance(true);
    await cubit.submitCurrentStep();
    expect(cubit.state.receipt!.isMock, isTrue);
    expect(cubit.state.canContinue, isFalse);
    expect(cubit.state.canReviewSelection, isFalse);
  });

  test(
    'removing the last card in destination review returns to selection',
    () async {
      final cubit = await createGiftCubit();
      cubit.toggleCard(cubit.state.visibleCards.first);
      await cubit.submitCurrentStep();
      cubit.applyReviewResult(true);
      cubit.requestReview();
      cubit.removeSelectedCard(cubit.state.selectedCards.first);
      cubit.applyReviewResult(null);
      expect(cubit.state.step, GiftBalanceStep.selection);
      expect(cubit.state.totalRial, 0);
      expect(cubit.state.canContinue, isFalse);
      expect(cubit.state.canReviewSelection, isFalse);
    },
  );

  test('Back preserves cards and destination but clears consent', () async {
    final cubit = await createGiftCubit();
    cubit.toggleCard(cubit.state.visibleCards.first);
    await cubit.submitCurrentStep();
    cubit.applyReviewResult(true);
    cubit.selectDestination(cubit.state.catalog!.deposits[1]);
    cubit.updateTermsAcceptance(true);
    cubit.requestBack();
    expect(cubit.state.step, GiftBalanceStep.selection);
    expect(cubit.state.selectedCards.map((card) => card.id), ['gift-0']);
    expect(cubit.state.destination!.id, 'deposit-2');
    expect(cubit.state.termsAccepted, isFalse);
    cubit.requestBack();
    expect(cubit.state.navigation, FlowNavigation.confirmExit);
    cubit.applyExitConfirmation(false);
    expect(cubit.state.navigation, isNull);
  });

  test('gift submission preserves retry identity and prepares independent statuses', () async {
    final repository = TestCardServicesRepository()..failSubmit = true;
    final cubit = await createGiftCubit(repository: repository);
    cubit.toggleCard(cubit.state.visibleCards.first);
    await cubit.submitCurrentStep();
    cubit.applyReviewResult(true);
    cubit.selectDestination(cubit.state.catalog!.deposits[1]);
    cubit.updateTermsAcceptance(true);
    await cubit.submitCurrentStep();
    expect(cubit.state.submissionStatus, RequestStatus.failure);
    expect(cubit.state.failure, isA<DataFailure>());
    expect(cubit.state.catalogStatus, RequestStatus.success);
    expect(cubit.state.canContinue, isTrue);
    // Consent and an unchanged review do not alter the payload.
    cubit.updateTermsAcceptance(false);
    cubit.updateTermsAcceptance(true);
    cubit.requestReview();
    cubit.applyReviewResult(null);
    repository.pendingSubmit = Completer();
    final pending = cubit.submitCurrentStep();
    expect(cubit.state.isEditable, isFalse);
    expect(cubit.state.canContinue, isFalse);
    expect(cubit.state.canReviewSelection, isFalse);
    expect(repository.transfers, hasLength(2));
    expect(
      repository.transfers.first.idempotencyKey,
      repository.transfers.last.idempotencyKey,
    );
    repository.pendingSubmit!.complete(
      const Success(CardServiceReceipt(reference: 'GB-demo', isMock: true)),
    );
    await pending;
    expect(cubit.state.receipt!.reference, 'GB-demo');
    cubit.requestBack();
    expect(cubit.state.navigation, FlowNavigation.back);
  });

  test('changing destination or selected cards creates a new gift request identity', () async {
    final repository = TestCardServicesRepository()..failSubmit = true;
    final cubit = await createGiftCubit(repository: repository);
    cubit.selectAllVisible(true);
    await cubit.submitCurrentStep();
    cubit.applyReviewResult(true);
    cubit.selectDestination(cubit.state.catalog!.deposits.first);
    cubit.updateTermsAcceptance(true);
    await cubit.submitCurrentStep();
    cubit.selectDestination(cubit.state.catalog!.deposits.last);
    expect(cubit.state.termsAccepted, isFalse);
    expect(cubit.state.failure, isNull);
    cubit.updateTermsAcceptance(true);
    await cubit.submitCurrentStep();
    expect(
      repository.transfers[1].idempotencyKey,
      isNot(repository.transfers[0].idempotencyKey),
    );
    cubit.requestReview();
    cubit.removeSelectedCard(cubit.state.selectedCards.first);
    cubit.applyReviewResult(true);
    expect(cubit.state.canContinue, isFalse);
    cubit.updateTermsAcceptance(true);
    await cubit.submitCurrentStep();
    expect(
      repository.transfers[2].idempotencyKey,
      isNot(repository.transfers[1].idempotencyKey),
    );
    expect(repository.transfers.last.cardIds, [
      'gift-1',
      'gift-2',
      'gift-3',
      'gift-4',
    ]);
  });

  test(
    'gift constructor preserves supplied state and fetch failures can retry',
    () async {
      final repository = TestCardServicesRepository()..throwLoad = true;
      const initialState = ExpiredGiftBalanceState.initial(query: '۵۰۴۱');
      final cubit =
          withRegisteredDependency<
            CardServicesRepository,
            ExpiredGiftBalanceCubit
          >(
            repository,
            () => ExpiredGiftBalanceCubit(initialState: initialState),
          );
      addTearDown(cubit.close);
      expect(cubit.state, same(initialState));
      expect(repository.loadCalls, 0);
      await cubit.fetchCatalog();
      expect(cubit.state.catalogStatus, RequestStatus.failure);
      expect(cubit.state.failure, isA<UnexpectedFailure>());
      repository.throwLoad = false;
      await cubit.fetchCatalog();
      expect(cubit.state.catalogStatus, RequestStatus.success);
      expect(cubit.state.failure, isNull);
      expect(cubit.state.query, '۵۰۴۱');
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
      await invalid.fetchCatalog();
      expect(invalid.state.catalogStatus, RequestStatus.failure);
    },
  );
}
