import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/cards/data/repositories/mock_card_restrictions_repository.dart';
import 'package:pishkhan_mobile/features/cards/domain/entities/card_restriction.dart';
import 'package:pishkhan_mobile/features/cards/domain/entities/card_service_data.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/card_restrictions_repository.dart';
import 'package:pishkhan_mobile/features/cards/domain/usecases/card_restrictions_usecase.dart';

void main() {
  test('block/unblock update eligibility, preserve history and debit demo ledger once per key', () async {
    final repository = MockCardRestrictionsRepository(
      walletBalanceRial: 5000000,
    );
    final catalog = (await repository.fetchCatalog(
      CardRestrictionOperation.block,
    ) as Success<CardRestrictionCatalog>).data;
    final request = CardRestrictionRequest(
      operation: CardRestrictionOperation.block,
      cardId: catalog.cards.first.id,
      reason: CardRestrictionReason.lost,
      description: 'test',
      quoteToken: catalog.quoteToken,
      idempotencyKey: 'block-1',
    );
    final result = await repository.submitRestriction(
      request,
    ) as Success<CardServiceReceipt>;
    expect(
      (await repository.submitRestriction(
        request,
      ) as Success<CardServiceReceipt>).data,
      result.data,
    );
    expect(repository.walletBalanceRial, 3700000);
    final unblocks = (await repository.fetchCatalog(
      CardRestrictionOperation.unblock,
    ) as Success<CardRestrictionCatalog>).data;
    final card = unblocks.cards.firstWhere((card) => card.id == request.cardId);
    expect(card.blockDetails!.reason, CardRestrictionReason.lost);
    expect(card.blockDetails!.description, 'test');
    expect(card.blockDetails!.blockedAt.isUtc, isTrue);
    final unblock = CardRestrictionRequest(
      operation: CardRestrictionOperation.unblock,
      cardId: card.id,
      reason: CardRestrictionReason.found,
      description: '',
      quoteToken: unblocks.quoteToken,
      idempotencyKey: 'unblock-1',
    );
    expect(
      await repository.submitRestriction(unblock),
      isA<Success<CardServiceReceipt>>(),
    );
    expect(repository.walletBalanceRial, 2400000);
    final blocks = (await repository.fetchCatalog(
      CardRestrictionOperation.block,
    ) as Success<CardRestrictionCatalog>).data;
    expect(
      blocks.cards.any(
        (card) => card.id == request.cardId && card.blockDetails == null,
      ),
      isTrue,
    );
    final conflict = CardRestrictionRequest(
      operation: request.operation,
      cardId: request.cardId,
      reason: CardRestrictionReason.other,
      description: '',
      quoteToken: request.quoteToken,
      idempotencyKey: request.idempotencyKey,
    );
    expect(
      (await repository.submitRestriction(conflict) as Err).failure.code,
      'card-restriction.identity-conflict',
    );
  });

  test(
    'stale quote and insufficient wallet cannot mutate card state',
    () async {
      final repository = MockCardRestrictionsRepository();
      final catalog = (await repository.fetchCatalog(
        CardRestrictionOperation.block,
      ) as Success<CardRestrictionCatalog>).data;
      CardRestrictionRequest request(String token) => CardRestrictionRequest(
        operation: CardRestrictionOperation.block,
        cardId: catalog.cards.first.id,
        reason: CardRestrictionReason.lost,
        description: '',
        quoteToken: token,
        idempotencyKey: 'new-key',
      );
      expect(
        (await repository.submitRestriction(
          request('stale'),
        ) as Err).failure.code,
        'card-restriction.quote-expired',
      );
      repository.walletBalanceRial = 1;
      final latest = (await repository.fetchCatalog(
        CardRestrictionOperation.block,
      ) as Success<CardRestrictionCatalog>).data;
      expect(
        (await repository.submitRestriction(
          request(latest.quoteToken),
        ) as Err).failure.code,
        'card-restriction.wallet-insufficient',
      );
      expect(repository.walletBalanceRial, 1);
      expect(latest.cards.first.blockDetails, isNull);
    },
  );

  test('UseCases contain unexpected repository exceptions', () async {
    final repository = ThrowingRestrictionsRepository();
    expect(
      (await FetchCardRestrictionCatalogUseCase(repository)(
        CardRestrictionOperation.block,
      ) as Err).failure,
      isA<UnexpectedFailure>(),
    );
    expect(
      (await SubmitCardRestrictionUseCase(repository)(
        const CardRestrictionRequest(
          operation: CardRestrictionOperation.block,
          cardId: 'x',
          reason: CardRestrictionReason.lost,
          description: '',
          quoteToken: 'q',
          idempotencyKey: 'k',
        ),
      ) as Err).failure,
      isA<UnexpectedFailure>(),
    );
  });
}

class ThrowingRestrictionsRepository implements CardRestrictionsRepository {
  @override
  Future<Result<CardRestrictionCatalog>> fetchCatalog(
    CardRestrictionOperation operation,
  ) async => throw StateError('synthetic');
  @override
  Future<Result<CardServiceReceipt>> submitRestriction(
    CardRestrictionRequest request,
  ) async => throw StateError('synthetic');
}
