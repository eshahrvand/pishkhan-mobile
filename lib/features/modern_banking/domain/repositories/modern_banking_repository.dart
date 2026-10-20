import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/mobile_bank.dart';

abstract interface class ModernBankingRepository {
  Future<Result<MobileBankCatalog>> fetchCatalog();
  Future<Result<MobileBankRecord>> submitIdentity(
    MobileBankIdentityRequest request,
  );
  Future<Result<TransferLimits>> submitTransferLimits(
    TransferLimitsRequest request,
  );
  Future<Result<MobileBankRecord>> submitDeactivation(
    MobileBankDeactivationRequest request,
  );
}
