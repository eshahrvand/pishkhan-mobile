import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/card_service_data.dart';
import '../../domain/repositories/card_services_repository.dart';

/// In-memory examples only; no bank operation or wallet debit is performed.
class MockCardServicesRepository implements CardServicesRepository {
  MockCardServicesRepository({CardServiceCatalog? catalog})
    : catalog = catalog ?? examples;
  final CardServiceCatalog catalog;
  static final examples = CardServiceCatalog(
    deposits: const [
      CardServiceDeposit(id: 'deposit-1', number: '10.123456.1'),
      CardServiceDeposit(
        id: 'deposit-2',
        number: '10.123456.2',
        kind: CardDepositKind.current,
      ),
    ],
    cards: const [
      ServiceBankCard(
        id: 'card-1',
        number: '5041721223456787',
        depositId: 'deposit-1',
      ),
      ServiceBankCard(
        id: 'card-2',
        number: '5041721456783407',
        depositId: 'deposit-1',
      ),
      ServiceBankCard(
        id: 'card-3',
        number: '5041720000001234',
        depositId: 'deposit-2',
      ),
      // Also resolves the dashboard's illustrative card when opening its action.
      ServiceBankCard(
        id: 'dashboard-card',
        number: '1234123412341234',
        depositId: 'deposit-1',
      ),
    ],
    gifts: [
      for (var i = 0; i < 5; i++)
        ExpiredGiftCard(
          id: 'gift-$i',
          number: '504172145678${3407 + i}',
          depositId: i.isEven ? 'deposit-1' : 'deposit-2',
          balanceRial: 1000000,
        ),
    ],
    changeDepositFeeRial: 1300000,
    walletBalanceRial: 2000000,
  );
  final _receipts = <String, CardServiceReceipt>{};
  @override
  Future<Result<CardServiceCatalog>> load() async => Success(catalog);
  @override
  Future<Result<CardServiceReceipt>> changeDeposit(
    ChangeCardDepositRequest request,
  ) async {
    final key = 'deposit:${request.idempotencyKey}';
    if (_receipts[key] case final receipt?) return Success(receipt);
    final card = catalog.cards.where((c) => c.id == request.cardId).firstOrNull;
    if (request.idempotencyKey.isEmpty ||
        card == null ||
        card.depositId != request.sourceDepositId ||
        request.destinationDepositId == request.sourceDepositId ||
        !catalog.deposits.any((d) => d.id == request.destinationDepositId) ||
        catalog.walletBalanceRial < catalog.changeDepositFeeRial) {
      return const Err(DataFailure('card.deposit.request.invalid'));
    }
    return Success(
      _receipts[key] = const CardServiceReceipt(
        reference: 'CD-98649466583',
        isMock: true,
      ),
    );
  }

  @override
  Future<Result<CardServiceReceipt>> transferGiftBalance(
    GiftBalanceRequest request,
  ) async {
    final key = 'gift:${request.idempotencyKey}';
    if (_receipts[key] case final receipt?) return Success(receipt);
    if (request.idempotencyKey.isEmpty ||
        request.cardIds.isEmpty ||
        request.cardIds.toSet().length != request.cardIds.length ||
        request.cardIds.any(
          (id) => !catalog.gifts.any((c) => c.id == id && c.balanceRial > 0),
        ) ||
        !catalog.deposits.any((d) => d.id == request.destinationDepositId)) {
      return const Err(DataFailure('card.gift.request.invalid'));
    }
    return Success(
      _receipts[key] = const CardServiceReceipt(
        reference: 'GB-98649466583',
        isMock: true,
      ),
    );
  }
}
