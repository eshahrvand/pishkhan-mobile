import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/cards/data/repositories/mock_card_restrictions_repository.dart';
import 'package:pishkhan_mobile/features/cards/domain/entities/card_restriction.dart';
import 'package:pishkhan_mobile/features/cards/domain/entities/card_service_data.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/card_restrictions_repository.dart';
import 'package:pishkhan_mobile/features/cards/presentation/card_restriction/cubit/card_restriction_cubit.dart';

import 'card_restriction_test_support.dart';

void main() {
  setUp(configureDependencies);
  tearDown(() => getIt.reset());

  CardRestrictionCubit create(
    CardRestrictionOperation operation, {
    String? initialCardNumber,
  }) {
    final cubit = CardRestrictionCubit(
      operation: operation,
      initialCardNumber: initialCardNumber,
    );
    addTearDown(cubit.close);
    return cubit;
  }

  void completeForm(CardRestrictionCubit cubit) {
    cubit.selectCard(cubit.state.catalog!.cards.first);
    cubit.selectReason(cubit.state.catalog!.reasons.first);
    cubit.updateDescription(' شخصی ');
    cubit.updateTermsAcceptance(true);
  }

  test('construction preserves initial State and fetching resolves normalized card context', () async {
    final cubit = create(
      CardRestrictionOperation.block,
      initialCardNumber: '۵۰۴۱ ۷۲۱۲ ۲۳۴۵ ۶۷۸۷',
    );
    expect(cubit.state, const CardRestrictionState.initial());
    await cubit.fetchCatalog();
    expect(cubit.state.card!.number, '5041721223456787');
    expect(
      cubit.state.catalog!.cards.every((card) => card.blockDetails == null),
      isTrue,
    );
    expect(cubit.state.canSubmit, isFalse);
  });

  test(
    'block confirmation can cancel/dismiss/reopen without submitting',
    () async {
      final repository = ControlledCardRestrictionsRepository();
      installRestrictionsRepository(repository);
      final cubit = create(CardRestrictionOperation.block);
      await cubit.fetchCatalog();
      completeForm(cubit);
      expect(cubit.state.canSubmit, isTrue);
      for (final result in [false, null]) {
        await cubit.requestSubmission();
        expect(cubit.state.effect, CardRestrictionEffect.confirmBlock);
        cubit.consumeInteraction();
        await cubit.applyBlockConfirmation(result);
        expect(repository.requests, isEmpty);
        expect(cubit.state.description, ' شخصی ');
      }
      await cubit.requestSubmission();
      cubit.consumeInteraction();
      await cubit.applyBlockConfirmation(true);
      expect(repository.requests.single.description, 'شخصی');
      expect(cubit.state.receipt!.isMock, isTrue);
      expect(cubit.state.canSubmit, isFalse);
      cubit.requestBack();
      expect(cubit.state.effect, CardRestrictionEffect.home);
    },
  );

  test('unblock exposes previous block details and submits without block confirmation', () async {
    final repository = ControlledCardRestrictionsRepository();
    installRestrictionsRepository(repository);
    final cubit = create(CardRestrictionOperation.unblock);
    await cubit.fetchCatalog();
    completeForm(cubit);
    expect(cubit.state.card!.blockDetails, isNotNull);
    await cubit.requestSubmission();
    expect(
      repository.requests.single.operation,
      CardRestrictionOperation.unblock,
    );
    expect(cubit.state.submissionStatus, RequestStatus.success);
    expect(cubit.state.effect, isNull);
  });

  test('failure retains retry payload/key; repeated failures transition and success retains latest message', () async {
    final repository = ControlledCardRestrictionsRepository()
      ..failSubmission = true;
    installRestrictionsRepository(repository);
    final cubit = create(CardRestrictionOperation.unblock);
    await cubit.fetchCatalog();
    completeForm(cubit);
    final key = cubit.state.idempotencyKey;
    final snapshots = <CardRestrictionState>[];
    final subscription = cubit.stream.listen(snapshots.add);
    addTearDown(subscription.cancel);
    await cubit.requestSubmission();
    final message = cubit.state.message;
    await cubit.requestSubmission();
    await Future<void>.delayed(Duration.zero);
    expect(
      snapshots.where(
        (state) => state.submissionStatus == RequestStatus.failure,
      ),
      hasLength(2),
    );
    expect(repository.requests[0], repository.requests[1]);
    expect(cubit.state.idempotencyKey, key);
    expect(cubit.state.isEditable, isTrue);
    repository.failSubmission = false;
    await cubit.requestSubmission();
    expect(cubit.state.submissionStatus, RequestStatus.success);
    expect(cubit.state.message, message);
    expect(cubit.state.reason, isNotNull);
  });

  test(
    'editing confirmed payload revokes consent and refreshes request identity',
    () async {
      final cubit = create(CardRestrictionOperation.block);
      await cubit.fetchCatalog();
      completeForm(cubit);
      final key = cubit.state.idempotencyKey;
      cubit.updateDescription('new description');
      expect(cubit.state.termsAccepted, isFalse);
      expect(cubit.state.canSubmit, isFalse);
      expect(cubit.state.idempotencyKey, isNot(key));
      cubit.updateTermsAcceptance(true);
      cubit.selectCard(cubit.state.catalog!.cards.last);
      expect(cubit.state.canSubmit, isFalse);
      cubit.updateTermsAcceptance(true);
      expect(cubit.state.canSubmit, isTrue);
    },
  );

  test(
    'refreshing the fee quote revokes previous consent while retaining inputs',
    () async {
      final cubit = create(CardRestrictionOperation.block);
      await cubit.fetchCatalog();
      completeForm(cubit);
      final previousKey = cubit.state.idempotencyKey;
      final card = cubit.state.card;
      // A refreshed quote changes fee authorization, so it receives a new key.
      final repository =
          getIt<CardRestrictionsRepository>() as MockCardRestrictionsRepository;
      repository.walletBalanceRial += 1;
      await cubit.fetchCatalog();
      expect(cubit.state.card, card);
      expect(cubit.state.description, ' شخصی ');
      expect(cubit.state.reason, CardRestrictionReason.lost);
      expect(cubit.state.termsAccepted, isFalse);
      expect(cubit.state.canSubmit, isFalse);
      expect(cubit.state.idempotencyKey, isNot(previousKey));
    },
  );

  test('reselecting identical payload and refreshing unchanged quote preserve retry identity', () async {
    final cubit = create(CardRestrictionOperation.block);
    await cubit.fetchCatalog();
    completeForm(cubit);
    final key = cubit.state.idempotencyKey;
    cubit.selectCard(cubit.state.card!);
    cubit.selectReason(cubit.state.reason!);
    cubit.updateDescription('شخصی');
    expect(cubit.state.idempotencyKey, key);
    await cubit.fetchCatalog();
    expect(cubit.state.idempotencyKey, key);
  });

  test('insufficient wallet cannot enable submit', () async {
    installRestrictionsRepository(
      MockCardRestrictionsRepository(walletBalanceRial: 1),
    );
    final cubit = create(CardRestrictionOperation.block);
    await cubit.fetchCatalog();
    completeForm(cubit);
    expect(cubit.state.isWalletSufficient, isFalse);
    expect(cubit.state.canSubmit, isFalse);
  });

  test('catalog failure retries and exit decisions preserve form', () async {
    final repository = ControlledCardRestrictionsRepository()
      ..failCatalog = true;
    installRestrictionsRepository(repository);
    final cubit = create(CardRestrictionOperation.block);
    await cubit.fetchCatalog();
    expect(cubit.state.catalogStatus, RequestStatus.failure);
    final message = cubit.state.message;
    repository.failCatalog = false;
    await cubit.fetchCatalog();
    expect(cubit.state.message, message);
    cubit.requestBack();
    expect(cubit.state.effect, CardRestrictionEffect.back);
    cubit.consumeInteraction();
    completeForm(cubit);
    cubit.requestBack();
    expect(cubit.state.effect, CardRestrictionEffect.confirmExit);
    cubit.consumeInteraction();
    cubit.applyExitConfirmation(null);
    expect(cubit.state.effect, isNull);
    expect(cubit.state.termsAccepted, isTrue);
    cubit.requestTerms();
    expect(cubit.state.effect, CardRestrictionEffect.termsUnavailable);
    cubit.consumeInteraction();
    cubit.applyExitConfirmation(true);
    expect(cubit.state.effect, CardRestrictionEffect.back);
  });

  test(
    'pending submission publishes loading and preserves receipt result',
    () async {
      final repository = ControlledCardRestrictionsRepository()
        ..pendingSubmission = Completer<Result<CardServiceReceipt>>();
      installRestrictionsRepository(repository);
      final cubit = create(CardRestrictionOperation.unblock);
      await cubit.fetchCatalog();
      completeForm(cubit);
      final future = cubit.requestSubmission();
      expect(cubit.state.submissionStatus, RequestStatus.loading);
      expect(cubit.state.isEditable, isFalse);
      repository.pendingSubmission!.complete(
        const Err(DataFailure('network.connection')),
      );
      await future;
      expect(cubit.state.isEditable, isTrue);
      expect(cubit.state.card, isNotNull);
    },
  );
}
