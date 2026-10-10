import 'package:equatable/equatable.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

class VirtualCardDeposit extends Equatable {
  const VirtualCardDeposit({required this.id, required this.number});
  final String id, number;
  @override
  List<Object?> get props => [id, number];
}

class VirtualCardCatalog extends Equatable {
  VirtualCardCatalog({
    required Iterable<VirtualCardDeposit> deposits,
    required this.indicativePerCardFeeRial,
    this.maxCount = 999,
  }) : deposits = List.unmodifiable(deposits);
  final List<VirtualCardDeposit> deposits;
  final int indicativePerCardFeeRial, maxCount;
  @override
  List<Object?> get props => [deposits, indicativePerCardFeeRial, maxCount];
}

/// An adapter-owned quote. The UI never infers a payable total from unit fees.
class VirtualCardQuote extends Equatable {
  const VirtualCardQuote({
    required this.id,
    required this.depositId,
    required this.count,
    required this.perCardFeeRial,
    required this.totalRial,
    required this.walletBalanceRial,
  });
  final String id, depositId;
  final int count, perCardFeeRial, totalRial, walletBalanceRial;
  bool get walletSufficient => walletBalanceRial >= totalRial;
  @override
  List<Object?> get props => [
    id,
    depositId,
    count,
    perCardFeeRial,
    totalRial,
    walletBalanceRial,
  ];
}

class VirtualCardRequest {
  const VirtualCardRequest({required this.quote, required this.idempotencyKey});
  final VirtualCardQuote quote;
  final String idempotencyKey;
}

class VirtualCardReceipt extends Equatable {
  const VirtualCardReceipt({required this.reference, required this.isMock});
  final String reference;
  final bool isMock;
  @override
  List<Object?> get props => [reference, isMock];
}

abstract interface class VirtualCardRepository {
  Future<Result<VirtualCardCatalog>> load();
  Future<Result<VirtualCardQuote>> quote(String depositId, int count);
  Future<Result<VirtualCardReceipt>> submit(VirtualCardRequest request);
}
