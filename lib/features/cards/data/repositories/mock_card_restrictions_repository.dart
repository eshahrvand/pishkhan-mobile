import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/card_restriction.dart';
import '../../domain/entities/card_service_data.dart';
import '../../domain/repositories/card_restrictions_repository.dart';

/// Demo ledger only. No bank card or real wallet is changed.
class MockCardRestrictionsRepository implements CardRestrictionsRepository {
  MockCardRestrictionsRepository({
    Iterable<RestrictionCard>? cards,
    this.walletBalanceRial = 2000000,
    this.feeRial = 1300000,
  }) : _cards = {for (final card in cards ?? examples) card.id: card};
  final Map<String, RestrictionCard> _cards;
  int walletBalanceRial;
  final int feeRial;
  int _revision = 0;
  final _requests = <String, CardRestrictionRequest>{};
  final _receipts = <String, CardServiceReceipt>{};

  static final examples = [
    const RestrictionCard(
      id: 'card-1',
      number: '5041721223456787',
      deposit: CardServiceDeposit(id: 'deposit-1', number: '10.1234567.1'),
    ),
    const RestrictionCard(
      id: 'card-list',
      number: '5041721456783407',
      deposit: CardServiceDeposit(id: 'deposit-2', number: '10.1234567.2'),
    ),
    const RestrictionCard(
      id: 'dashboard-card',
      number: '1234123412341234',
      deposit: CardServiceDeposit(id: 'deposit-1', number: '10.1234567.1'),
    ),
    RestrictionCard(
      id: 'blocked-card',
      number: '6207390713532072',
      deposit: const CardServiceDeposit(
        id: 'deposit-1',
        number: '10.1234567.1',
      ),
      blockDetails: CardRestrictionDetails(
        reason: CardRestrictionReason.depositManagement,
        blockedAt: DateTime.utc(2025, 12, 1),
        description: 'شخصی',
      ),
    ),
  ];

  List<CardRestrictionReason> _reasons(CardRestrictionOperation operation) =>
      switch (operation) {
        CardRestrictionOperation.block => const [
          CardRestrictionReason.lost,
          CardRestrictionReason.stolen,
          CardRestrictionReason.depositManagement,
          CardRestrictionReason.other,
        ],
        CardRestrictionOperation.unblock => const [
          CardRestrictionReason.found,
          CardRestrictionReason.depositManagement,
          CardRestrictionReason.other,
        ],
      };

  String _quoteToken(CardRestrictionOperation operation) =>
      '${operation.name}:$_revision:$feeRial:$walletBalanceRial';

  @override
  Future<Result<CardRestrictionCatalog>> fetchCatalog(
    CardRestrictionOperation operation,
  ) async {
    return Success(
      CardRestrictionCatalog(
        cards: _cards.values.where(
          (card) =>
              (card.blockDetails != null) ==
              (operation == CardRestrictionOperation.unblock),
        ),
        reasons: _reasons(operation),
        feeRial: feeRial,
        walletBalanceRial: walletBalanceRial,
        quoteToken: _quoteToken(operation),
      ),
    );
  }

  @override
  Future<Result<CardServiceReceipt>> submitRestriction(
    CardRestrictionRequest request,
  ) async {
    // A lost-response retry returns the same result before checking the changed ledger.
    if (_requests[request.idempotencyKey] case final previous?) {
      return previous == request
          ? Success(_receipts[request.idempotencyKey]!)
          : const Err(DataFailure('card-restriction.identity-conflict'));
    }
    final card = _cards[request.cardId];
    if (card == null ||
        request.idempotencyKey.isEmpty ||
        !_reasons(request.operation).contains(request.reason) ||
        (card.blockDetails != null) !=
            (request.operation == CardRestrictionOperation.unblock)) {
      return const Err(DataFailure('card-restriction.ineligible'));
    }
    if (request.quoteToken != _quoteToken(request.operation)) {
      return const Err(DataFailure('card-restriction.quote-expired'));
    }
    if (walletBalanceRial < feeRial) {
      return const Err(DataFailure('card-restriction.wallet-insufficient'));
    }
    _cards[card.id] = RestrictionCard(
      id: card.id,
      number: card.number,
      deposit: card.deposit,
      blockDetails: request.operation == CardRestrictionOperation.block
          ? CardRestrictionDetails(
              reason: request.reason,
              blockedAt: DateTime.now().toUtc(),
              description: request.description,
            )
          : null,
    );
    walletBalanceRial -= feeRial;
    _revision++;
    final receipt = CardServiceReceipt(
      reference: 'CR-${request.operation.name}-$_revision',
      isMock: true,
    );
    _requests[request.idempotencyKey] = request;
    _receipts[request.idempotencyKey] = receipt;
    return Success(receipt);
  }
}
