import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../domain/virtual_card_data.dart';

/// Illustrative quotes, not a bank tariff or a card-creation/payment authority.
class MockVirtualCardRepository implements VirtualCardRepository {
  MockVirtualCardRepository();
  static final catalog = VirtualCardCatalog(
    deposits: const [
      VirtualCardDeposit(id: 'virtual-deposit-1', number: '10.1234567.1'),
      VirtualCardDeposit(id: 'virtual-deposit-2', number: '10.1234568.1'),
      VirtualCardDeposit(id: 'virtual-deposit-3', number: '10.1234569.1'),
    ],
    indicativePerCardFeeRial: 41250,
  );
  final _quotes = <String, VirtualCardQuote>{};
  final _receipts = <String, VirtualCardReceipt>{};
  @override
  Future<Result<VirtualCardCatalog>> load() async => Success(catalog);
  @override
  Future<Result<VirtualCardQuote>> quote(String depositId, int count) async {
    if (!catalog.deposits.any((d) => d.id == depositId) ||
        count < 1 ||
        count > catalog.maxCount) {
      return const Err(DataFailure('virtual.selection.invalid'));
    }
    final quote = VirtualCardQuote(
      id: '$depositId:$count',
      depositId: depositId,
      count: count,
      perCardFeeRial: 300000,
      // The four-card frame explicitly quotes 1,300,000 despite its 300,000
      // unit fee. Preserve that sample without inventing an undisclosed charge.
      totalRial: count == 4 ? 1300000 : count * 300000,
      walletBalanceRial: 2000000,
    );
    _quotes[quote.id] = quote;
    return Success(quote);
  }

  @override
  Future<Result<VirtualCardReceipt>> submit(VirtualCardRequest request) async {
    final existing = _receipts[request.idempotencyKey];
    if (existing != null) return Success(existing);
    if (_quotes[request.quote.id] != request.quote ||
        !request.quote.walletSufficient ||
        request.idempotencyKey.isEmpty) {
      return const Err(DataFailure('virtual.request.invalid'));
    }
    const receipt = VirtualCardReceipt(
      reference: 'VC-98649466583',
      isMock: true,
    );
    _receipts[request.idempotencyKey] = receipt;
    return const Success(receipt);
  }
}
