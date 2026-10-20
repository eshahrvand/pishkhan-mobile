import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/mobile_bank.dart';
import '../../domain/repositories/modern_banking_repository.dart';

/// In-memory prototype only. Never records video, debits a wallet or sends SMS.
class MockModernBankingRepository implements ModernBankingRepository {
  MockModernBankingRepository({
    MobileBankRequestStatus? activationStatus,
    this.username = '123456789',
    this.walletBalanceRial = 2000000,
  }) : _activation = MobileBankRecord(
         status: activationStatus ?? _scenarioStatus(),
       );

  static MobileBankRequestStatus _scenarioStatus() =>
      switch (const String.fromEnvironment('MODERN_BANK_SCENARIO')) {
        'approved' => MobileBankRequestStatus.approved,
        'pending' => MobileBankRequestStatus.pending,
        'rejected' => MobileBankRequestStatus.rejected,
        _ => MobileBankRequestStatus.none,
      };

  final String username;
  final int walletBalanceRial;
  MobileBankRecord _activation;
  MobileBankRecord _recovery = const MobileBankRecord();
  TransferLimits _limits = const TransferLimits(
    internalRial: 20000000,
    payaRial: 20000000,
    satnaRial: 20000000,
  );
  final _identityReceipts =
      <String, (MobileBankIdentityRequest, MobileBankRecord)>{};
  final _limitReceipts = <String, (TransferLimitsRequest, TransferLimits)>{};
  final _deactivationReceipts =
      <String, (MobileBankDeactivationRequest, MobileBankRecord)>{};
  static const maximum = TransferLimits(
    internalRial: 2000000000,
    payaRial: 2000000000,
    satnaRial: 2000000000,
  );
  static const reasons = [
    DeactivationReason(id: 'suspected-compromise', code: 'suspectedCompromise'),
  ];

  Future<Result<T>> _boundary<T>(T Function() operation) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return Success(operation());
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }

  @override
  Future<Result<MobileBankCatalog>> fetchCatalog() => _boundary(
    () => MobileBankCatalog(
      username: username,
      depositId: 'mobile-bank-deposit-1',
      activation:
          _activation.status == MobileBankRequestStatus.pending &&
              _activation.trackingCode == null
          ? const MobileBankRecord(
              status: MobileBankRequestStatus.pending,
              trackingCode: '98649466583',
            )
          : _activation,
      recovery: _recovery,
      limits: _limits,
      maximumLimits: maximum,
      registryFeeRial: 300000,
      identityFeeRial: 300000,
      passwordFeeRial: 1000000,
      walletBalanceRial: walletBalanceRial,
      reasons: reasons,
    ),
  );

  @override
  Future<Result<MobileBankRecord>> submitIdentity(
    MobileBankIdentityRequest request,
  ) {
    return _boundary(() {
      final prior = _identityReceipts[request.idempotencyKey];
      if (prior != null) {
        if (prior.$1 != request) throw StateError('idempotency.conflict');
        return prior.$2;
      }
      if (!request.isPrototypePreview) {
        throw StateError('kyc.adapter.unavailable');
      }
      final record = MobileBankRecord(
        status: MobileBankRequestStatus.pending,
        trackingCode: '9864946${6583 + _identityReceipts.length}',
      );
      _identityReceipts[request.idempotencyKey] = (request, record);
      if (request.operation == MobileBankOperation.activation) {
        _activation = record;
      } else {
        _recovery = record;
      }
      return record;
    });
  }

  @override
  Future<Result<TransferLimits>> submitTransferLimits(
    TransferLimitsRequest request,
  ) => _boundary(() {
    final prior = _limitReceipts[request.idempotencyKey];
    if (prior != null) {
      if (prior.$1 != request) throw StateError('idempotency.conflict');
      return prior.$2;
    }
    if (request.depositId != 'mobile-bank-deposit-1' ||
        request.limits.internalRial <= 0 ||
        request.limits.internalRial > maximum.internalRial ||
        request.limits.payaRial <= 0 ||
        request.limits.payaRial > maximum.payaRial ||
        request.limits.satnaRial <= 0 ||
        request.limits.satnaRial > maximum.satnaRial) {
      throw StateError('limits.invalid');
    }
    _limits = request.limits;
    _limitReceipts[request.idempotencyKey] = (request, _limits);
    return _limits;
  });

  @override
  Future<Result<MobileBankRecord>> submitDeactivation(
    MobileBankDeactivationRequest request,
  ) => _boundary(() {
    final prior = _deactivationReceipts[request.idempotencyKey];
    if (prior != null) {
      if (prior.$1 != request) throw StateError('idempotency.conflict');
      return prior.$2;
    }
    if (request.username != username || !reasons.contains(request.reason)) {
      throw StateError('deactivation.invalid');
    }
    const record = MobileBankRecord(
      status: MobileBankRequestStatus.none,
      trackingCode: '98649466584',
    );
    _activation = record;
    _deactivationReceipts[request.idempotencyKey] = (request, record);
    return record;
  });
}
