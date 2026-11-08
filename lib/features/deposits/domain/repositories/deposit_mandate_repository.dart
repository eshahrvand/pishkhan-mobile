import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/deposit_mandate.dart';

abstract interface class DepositMandateRepository {
  Future<Result<DepositMandateCatalog>> fetchCatalog();
  Future<Result<DepositMandateReceipt>> submitDepositMandate(
    DepositMandateRequest request,
  );
}
