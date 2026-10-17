import '../../../../../support/registered_dependency.dart';

import 'package:pishkhan_mobile/core/enums/request_status.dart';

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/cards/cards.dart';
import 'package:pishkhan_mobile/features/cards/data/repositories/mock_cards_repository.dart';
import 'package:pishkhan_mobile/features/cards/presentation/card_features/cubit/card_features_cubit.dart';

import '../support/test_cards_repository.dart';

void main() {
  test(
    'interaction effects retain card context and repeat identical requests',
    () async {
      final cubit =
          withRegisteredDependency<CardsRepository, CardFeaturesCubit>(
            MockCardsRepository(),
            () => CardFeaturesCubit(),
          );
      addTearDown(cubit.close);
      await cubit.fetchCards();
      cubit.requestCardActions('unknown');
      expect(cubit.state.effect, isNull);
      cubit.requestCardActions('resalat-0');
      final card = (cubit.state.effect as CardActionsRequested).card;
      expect(cubit.state.selectedCard, card);
      final previousId = cubit.state.effectId;
      cubit.requestCardActions(card.id);
      expect(cubit.state.effectId, previousId + 1);
      cubit.handleCardActionSelection(CardFeatureAction.details, card: card);
      expect((cubit.state.effect as CardDetailsRequested).card, card);
      for (final entry in {
        CardFeatureAction.reissue: 'card-reissue',
        CardFeatureAction.changeDeposit: 'card-deposit',
        CardFeatureAction.block: null,
      }.entries) {
        cubit.handleCardActionSelection(entry.key, card: card);
        final effect = cubit.state.effect as CardServiceRequested;
        expect(effect.serviceId, entry.value);
        expect(effect.request.card, card);
        expect(effect.request.category, card.category);
      }
    },
  );

  test(
    'category selection owns footer and reveal effects without clearing search',
    () async {
      final cubit =
          withRegisteredDependency<CardsRepository, CardFeaturesCubit>(
            MockCardsRepository(),
            () => CardFeaturesCubit(initialCategory: CardCategory.family),
          );
      await cubit.fetchCards();
      cubit.requestSelectedCategoryReveal();
      expect(
        (cubit.state.effect as CardCategoryRevealRequested).scrollToEnd,
        isTrue,
      );
      expect(cubit.state.footerAction, isNull);
      cubit.updateSearchQuery('123');
      for (final entry in {
        CardCategory.gift: CardFeatureAction.expiredGiftBalance,
        CardCategory.virtual: CardFeatureAction.requestVirtual,
      }.entries) {
        cubit.selectCategory(entry.key);
        expect(cubit.state.query, '123');
        expect(cubit.state.footerAction, entry.value);
        expect(
          (cubit.state.effect as CardCategoryRevealRequested).category,
          entry.key,
        );
        cubit.requestFooterAction();
        final effect = cubit.state.effect as CardServiceRequested;
        expect(effect.request.action, entry.value);
        expect(effect.request.category, entry.key);
        expect(effect.request.card, isNull);
      }
      await cubit.close();
    },
  );

  test(
    'caller initial State retains its category and initializes display data',
    () async {
      final cubit =
          withRegisteredDependency<CardsRepository, CardFeaturesCubit>(
            MockCardsRepository(),
            () => CardFeaturesCubit(
              initialState: const CardFeaturesState.initial(
                category: CardCategory.gift,
              ),
            ),
          );
      addTearDown(cubit.close);
      await cubit.fetchCards();
      expect(cubit.state.category, CardCategory.gift);
      expect(cubit.state.visibleCards, hasLength(4));
      expect(
        cubit.state.visibleCards.every((c) => c.category == CardCategory.gift),
        isTrue,
      );
    },
  );
  test(
    'loads immutable data and keeps independent category/query/selected state',
    () async {
      final cubit =
          withRegisteredDependency<CardsRepository, CardFeaturesCubit>(
            MockCardsRepository(),
            () => CardFeaturesCubit(),
          );
      expect(cubit.state.status, RequestStatus.initial);
      final pending = cubit.fetchCards();
      expect(cubit.state.status, RequestStatus.loading);
      await pending;
      expect(cubit.state.visibleCards.length, 4);
      expect(() => cubit.state.cards!.clear(), throwsUnsupportedError);
      cubit.requestCardActions('resalat-1');
      expect(cubit.state.selectedCard!.id, 'resalat-1');
      cubit.selectCategory(CardCategory.family);
      expect(cubit.state.visibleCards.length, 2);
      expect(cubit.state.selectedCard, isNull);
      cubit.updateSearchQuery('۵۰۴۱ ۷۲۱۴ ۵۶۷۸۳۴۰۷');
      expect(cubit.state.visibleCards.length, 2);
      cubit.updateSearchQuery('٥٠٤١٧٢١٤٥٦٧٨٣٤٠٧');
      expect(cubit.state.visibleCards.length, 2);
      cubit.updateSearchQuery('no result');
      expect(cubit.state.visibleCards, isEmpty);
      await cubit.close();
    },
  );
  test(
    'filters are transactional, combine with search, and can be reset',
    () async {
      final cubit =
          withRegisteredDependency<CardsRepository, CardFeaturesCubit>(
            MockCardsRepository(),
            () => CardFeaturesCubit(),
          );
      await cubit.fetchCards();
      cubit.requestFilter();
      cubit.updateDraftCardStatus('blocked');
      expect(cubit.state.visibleCards.length, 4);
      cubit.cancelFilter();
      expect(cubit.state.filter.isActive, false);
      cubit.requestFilter();
      cubit.updateDraftCardStatus('blocked');
      cubit.updateDraftDepositNumber('10-1234567-2');
      cubit.handleFilterSheetResult(true);
      expect(cubit.state.visibleCards.single.id, 'resalat-3');
      cubit.updateSearchQuery('۱۰.۱۲۳۴۵۶۷.۲');
      expect(cubit.state.visibleCards.length, 1);
      cubit.requestFilter();
      cubit.resetDraftFilter();
      expect(cubit.state.filter.status, CardStatus.blocked);
      expect(cubit.state.visibleCards.single.id, 'resalat-3');
      cubit.handleFilterSheetResult(true);
      cubit.updateSearchQuery('');
      expect(cubit.state.visibleCards.length, 4);
      await cubit.close();
    },
  );
  test('empty/error/retry and invalid contract IDs are distinct', () async {
    final repo = FakeCardsRepository()
      ..result = const Err(DataFailure('offline'));
    final cubit = withRegisteredDependency<CardsRepository, CardFeaturesCubit>(
      repo,
      () => CardFeaturesCubit(),
    );
    await cubit.fetchCards();
    expect(cubit.state.status, RequestStatus.failure);
    expect(cubit.state.failure!.code, 'offline');
    repo.result = const Success([]);
    await cubit.fetchCards();
    expect(cubit.state.status, RequestStatus.success);
    repo.result = Success([
      MockCardsRepository.examples.first,
      MockCardsRepository.examples.first,
    ]);
    await cubit.fetchCards();
    expect(cubit.state.failure!.code, 'cards.invalid');
    repo.throws = true;
    await cubit.fetchCards();
    expect(cubit.state.failure!.code, 'unexpected');
    repo.throws = false;
    repo.result = Success([MockCardsRepository.examples.first]);
    await cubit.fetchCards();
    expect(cubit.state.status, RequestStatus.success);
    await cubit.close();
  });
  test('reload preserves the current category and resolves the selected card from fresh data', () async {
    final repository = FakeCardsRepository();
    final cubit = withRegisteredDependency<CardsRepository, CardFeaturesCubit>(
      repository,
      () => CardFeaturesCubit(initialCategory: CardCategory.family),
    );
    addTearDown(cubit.close);
    await cubit.fetchCards();
    cubit.selectCategory(CardCategory.resalat);
    cubit.requestCardActions('resalat-1');
    final selectedCard = cubit.state.selectedCard!;
    final updatedCard = ListedCard(
      id: selectedCard.id,
      category: selectedCard.category,
      number: selectedCard.number,
      linkedDeposit: 'updated-deposit',
      iban: selectedCard.iban,
      expiry: selectedCard.expiry,
      depositTypeKey: selectedCard.depositTypeKey,
      status: selectedCard.status,
    );
    repository.result = Success([updatedCard]);

    await cubit.fetchCards();

    expect(cubit.state.category, CardCategory.resalat);
    expect(cubit.state.footerAction, isNull);
    expect(cubit.state.selectedId, selectedCard.id);
    expect(cubit.state.selectedCard, updatedCard);
    expect(cubit.state.deposits, ['updated-deposit']);

    repository.result = const Success([]);
    await cubit.fetchCards();
    expect(cubit.state.selectedId, isNull);
    expect(cubit.state.selectedCard, isNull);
  });
  test(
    'pending fetch uses the latest category, query and filter on completion',
    () async {
      final repository = FakeCardsRepository();
      final response = Completer<Result<List<ListedCard>>>();
      repository.queue.add(response);
      final cubit =
          withRegisteredDependency<CardsRepository, CardFeaturesCubit>(
            repository,
            () => CardFeaturesCubit(initialCategory: CardCategory.family),
          );
      addTearDown(cubit.close);

      final pending = cubit.fetchCards();
      cubit.selectCategory(CardCategory.resalat);
      cubit.updateSearchQuery('۱۰.۱۲۳۴۵۶۷.۲');
      cubit.requestFilter();
      cubit.updateDraftCardStatus('blocked');
      cubit.handleFilterSheetResult(true);
      response.complete(Success(MockCardsRepository.examples));
      await pending;

      expect(cubit.state.status, RequestStatus.success);
      expect(cubit.state.category, CardCategory.resalat);
      expect(cubit.state.query, '۱۰.۱۲۳۴۵۶۷.۲');
      expect(cubit.state.filter.status, CardStatus.blocked);
      expect(cubit.state.visibleCards.single.id, 'resalat-3');
    },
  );
  test(
    'cancelled actions and cards absent from the catalog publish no new effect',
    () async {
      final repository = FakeCardsRepository();
      final cubit =
          withRegisteredDependency<CardsRepository, CardFeaturesCubit>(
            repository,
            () => CardFeaturesCubit(),
          );
      addTearDown(cubit.close);
      await cubit.fetchCards();
      cubit.requestCardActions('resalat-0');
      final previousCard = cubit.state.selectedCard!;
      final actionEffectId = cubit.state.effectId;
      cubit.handleCardActionSelection(null, card: previousCard);
      cubit.handleCardActionSelection(CardFeatureAction.details);
      expect(cubit.state.effectId, actionEffectId);

      repository.result = const Success([]);
      await cubit.fetchCards();
      final effectId = cubit.state.effectId;
      cubit.handleCardActionSelection(
        CardFeatureAction.details,
        card: previousCard,
      );
      cubit.handleCardActionSelection(
        CardFeatureAction.reissue,
        card: previousCard,
      );
      expect(cubit.state.effectId, effectId);
    },
  );
  test(
    'outdated responses and completion after close cannot change state',
    () async {
      final repo = FakeCardsRepository();
      final first = Completer<Result<List<ListedCard>>>(),
          second = Completer<Result<List<ListedCard>>>();
      repo.queue.addAll([first, second]);
      final cubit =
          withRegisteredDependency<CardsRepository, CardFeaturesCubit>(
            repo,
            () => CardFeaturesCubit(),
          );
      final a = cubit.fetchCards(), b = cubit.fetchCards();
      second.complete(Success([MockCardsRepository.examples[1]]));
      await b;
      first.complete(const Success([]));
      await a;
      expect(cubit.state.cards!.single.id, 'resalat-1');
      final late = Completer<Result<List<ListedCard>>>();
      repo.queue.add(late);
      final c = cubit.fetchCards();
      await cubit.close();
      final closedState = cubit.state;
      late.complete(const Success([]));
      await c;
      expect(cubit.state, closedState);
    },
  );
}
