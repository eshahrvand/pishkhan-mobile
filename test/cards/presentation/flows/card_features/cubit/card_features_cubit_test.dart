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
    'caller initial State retains its category and initializes display data',
    () async {
      final cubit = CardFeaturesCubit(
        repository: MockCardsRepository(),
        initialState: const CardFeaturesState(category: CardCategory.gift),
      );
      addTearDown(cubit.close);
      await cubit.load();
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
      final cubit = CardFeaturesCubit(repository: MockCardsRepository());
      expect(cubit.state.status, RequestStatus.initial);
      final pending = cubit.load();
      expect(cubit.state.status, RequestStatus.loading);
      await pending;
      expect(cubit.state.visibleCards.length, 4);
      expect(() => cubit.state.cards!.clear(), throwsUnsupportedError);
      cubit.selectCard('resalat-1');
      expect(cubit.state.selectedCard!.id, 'resalat-1');
      cubit.selectCategory(CardCategory.family);
      expect(cubit.state.visibleCards.length, 2);
      expect(cubit.state.selectedCard, isNull);
      cubit.search('۵۰۴۱ ۷۲۱۴ ۵۶۷۸۳۴۰۷');
      expect(cubit.state.visibleCards.length, 2);
      cubit.search('٥٠٤١٧٢١٤٥٦٧٨٣٤٠٧');
      expect(cubit.state.visibleCards.length, 2);
      cubit.search('no result');
      expect(cubit.state.visibleCards, isEmpty);
      await cubit.close();
    },
  );
  test(
    'filters are transactional, combine with search, and can be reset',
    () async {
      final cubit = CardFeaturesCubit(repository: MockCardsRepository());
      await cubit.load();
      cubit.beginFilter();
      cubit.setDraft(const CardFilter(status: CardStatus.blocked));
      expect(cubit.state.visibleCards.length, 4);
      cubit.cancelFilter();
      expect(cubit.state.filter.isActive, false);
      cubit.beginFilter();
      cubit.setDraft(
        const CardFilter(status: CardStatus.blocked, deposit: '10-1234567-2'),
      );
      cubit.applyFilter();
      expect(cubit.state.visibleCards.single.id, 'resalat-3');
      cubit.search('۱۰.۱۲۳۴۵۶۷.۲');
      expect(cubit.state.visibleCards.length, 1);
      cubit.beginFilter();
      cubit.clearDraftFilter();
      cubit.applyFilter();
      cubit.search('');
      expect(cubit.state.visibleCards.length, 4);
      await cubit.close();
    },
  );
  test('empty/error/retry and invalid contract IDs are distinct', () async {
    final repo = FakeCardsRepository()
      ..result = const Err(DataFailure('offline'));
    final cubit = CardFeaturesCubit(repository: repo);
    await cubit.load();
    expect(cubit.state.status, RequestStatus.failure);
    expect(cubit.state.failure!.code, 'offline');
    repo.result = const Success([]);
    await cubit.load();
    expect(cubit.state.status, RequestStatus.success);
    repo.result = Success([
      MockCardsRepository.examples.first,
      MockCardsRepository.examples.first,
    ]);
    await cubit.load();
    expect(cubit.state.failure!.code, 'cards.invalid');
    repo.throws = true;
    await cubit.load();
    expect(cubit.state.failure!.code, 'unexpected');
    repo.throws = false;
    repo.result = Success([MockCardsRepository.examples.first]);
    await cubit.load();
    expect(cubit.state.status, RequestStatus.success);
    await cubit.close();
  });
  test(
    'outdated responses and completion after close cannot change state',
    () async {
      final repo = FakeCardsRepository();
      final first = Completer<Result<List<ListedCard>>>(),
          second = Completer<Result<List<ListedCard>>>();
      repo.queue.addAll([first, second]);
      final cubit = CardFeaturesCubit(repository: repo);
      final a = cubit.load(), b = cubit.load();
      second.complete(Success([MockCardsRepository.examples[1]]));
      await b;
      first.complete(const Success([]));
      await a;
      expect(cubit.state.cards!.single.id, 'resalat-1');
      final late = Completer<Result<List<ListedCard>>>();
      repo.queue.add(late);
      final c = cubit.load();
      await cubit.close();
      late.complete(const Success([]));
      await c;
    },
  );
}
