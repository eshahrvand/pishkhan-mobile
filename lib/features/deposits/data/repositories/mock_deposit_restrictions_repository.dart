import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/deposit_restriction.dart';
import '../../domain/entities/listed_deposit.dart';
import '../../domain/repositories/deposit_restrictions_repository.dart';

/// Session-only simulation; never changes a real bank account or wallet.
class MockDepositRestrictionsRepository
    implements DepositRestrictionsRepository {
  MockDepositRestrictionsRepository([this._walletBalanceRial = 2000000]);
  final _deposits = <String, DepositRestrictionOption>{
    'restriction-1': DepositRestrictionOption(
      deposit: ListedDeposit(id: 'restriction-1', number: '10.1234567.1'),
    ),
    'restriction-2': DepositRestrictionOption(
      deposit: ListedDeposit(
        id: 'restriction-2',
        number: '10.1234567.2',
        status: DepositStatus.blocked,
      ),
      blockDetails: DepositBlockDetails(
        reason: DepositRestrictionReason.depositManagement,
        blockedAt: DateTime(2025, 12, 1),
        description: 'شخصی',
      ),
    ),
    'restriction-3': DepositRestrictionOption(
      deposit: ListedDeposit(id: 'restriction-3', number: '10.1234567.3'),
    ),
  };
  final _quotes =
      <
        String,
        ({
          DepositRestrictionOperation operation,
          DepositRestrictionCatalog catalog,
        })
      >{};
  final _requests = <String, DepositRestrictionRequest>{};
  final _receipts = <String, DepositRestrictionReceipt>{};
  int _walletBalanceRial;
  int _quoteSequence = 0;

  @override
  Future<Result<DepositRestrictionCatalog>> fetchCatalog(
    DepositRestrictionOperation operation,
  ) async {
    final catalog = DepositRestrictionCatalog(
      deposits: _deposits.values.where(
        (option) => switch (operation) {
          DepositRestrictionOperation.block =>
            option.deposit.status == DepositStatus.open,
          DepositRestrictionOperation.unblock =>
            option.deposit.status == DepositStatus.blocked,
        },
      ),
      reasons: const [DepositRestrictionReason.depositManagement],
      quoteToken: 'mock-restriction-${++_quoteSequence}',
      feeRial: 1300000,
      walletBalanceRial: _walletBalanceRial,
    );
    _quotes[catalog.quoteToken] = (operation: operation, catalog: catalog);
    return Success(catalog);
  }

  @override
  Future<Result<DepositRestrictionReceipt>> submitRestriction(
    DepositRestrictionRequest request,
  ) async {
    if (_requests.containsKey(request.idempotencyKey)) {
      return request == _requests[request.idempotencyKey]
          ? Success(_receipts[request.idempotencyKey]!)
          : const Err(DataFailure('deposit-restriction.idempotency-conflict'));
    }
    final quote = _quotes[request.quoteToken];
    final current = _deposits[request.depositId];
    if (quote == null ||
        current == null ||
        quote.operation != request.operation ||
        !quote.catalog.deposits.contains(current) ||
        !quote.catalog.reasons.contains(request.reason)) {
      return const Err(DataFailure('deposit-restriction.quote-invalid'));
    }
    if (_walletBalanceRial < quote.catalog.feeRial) {
      return const Err(DataFailure('deposit-restriction.wallet-insufficient'));
    }
    final blocked = request.operation == DepositRestrictionOperation.block;
    _deposits[request.depositId] = DepositRestrictionOption(
      deposit: ListedDeposit(
        id: current.deposit.id,
        number: current.deposit.number,
        kind: current.deposit.kind,
        status: blocked ? DepositStatus.blocked : DepositStatus.open,
        owners: current.deposit.owners,
      ),
      blockDetails: blocked
          ? DepositBlockDetails(
              reason: request.reason,
              blockedAt: DateTime.now(),
              description: request.description,
            )
          : null,
    );
    _walletBalanceRial -= quote.catalog.feeRial;
    final receipt = DepositRestrictionReceipt(
      reference: 'DEMO-RESTRICTION-${_receipts.length + 1}',
      isMock: true,
    );
    _requests[request.idempotencyKey] = request;
    _receipts[request.idempotencyKey] = receipt;
    return Success(receipt);
  }
}
