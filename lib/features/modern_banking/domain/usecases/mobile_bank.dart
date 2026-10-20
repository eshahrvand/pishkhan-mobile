import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/mobile_bank.dart';
import '../repositories/modern_banking_repository.dart';

class FetchMobileBankCatalog {
  const FetchMobileBankCatalog(this.repository);
  final ModernBankingRepository repository;
  Future<Result<MobileBankCatalog>> call() {
    return repository.fetchCatalog().then((result) {
      return switch (result) {
        Success(:final data)
            when data.username.isEmpty ||
                data.depositId.isEmpty ||
                data.registryFeeRial < 0 ||
                data.identityFeeRial < 0 ||
                data.passwordFeeRial < 0 ||
                data.walletBalanceRial < 0 ||
                (data.activation.status == MobileBankRequestStatus.pending &&
                    (data.activation.trackingCode?.trim().isEmpty ?? true)) ||
                (data.recovery.status == MobileBankRequestStatus.pending &&
                    (data.recovery.trackingCode?.trim().isEmpty ?? true)) ||
                data.limits.internalRial < 0 ||
                data.limits.payaRial < 0 ||
                data.limits.satnaRial < 0 ||
                data.maximumLimits.internalRial < data.limits.internalRial ||
                data.maximumLimits.payaRial < data.limits.payaRial ||
                data.maximumLimits.satnaRial < data.limits.satnaRial ||
                data.reasons.any((reason) => reason.id.isEmpty) ||
                data.reasons.map((reason) => reason.id).toSet().length !=
                    data.reasons.length =>
          const Err<MobileBankCatalog>(DataFailure('modern.catalog.invalid')),
        _ => result,
      };
    });
  }
}

abstract final class TransferLimitValidator {
  static bool isValid(String value, int maximum) {
    final amount = int.tryParse(value);
    return RegExp(r'^[0-9]+$').hasMatch(value) &&
        amount != null &&
        amount > 0 &&
        amount <= maximum;
  }
}
