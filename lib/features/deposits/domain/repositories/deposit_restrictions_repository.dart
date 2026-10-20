import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/deposit_restriction.dart';

abstract interface class DepositRestrictionsRepository {
  Future<Result<DepositRestrictionCatalog>> fetchCatalog(
    DepositRestrictionOperation operation,
  );
  Future<Result<DepositRestrictionReceipt>> submitRestriction(
    DepositRestrictionRequest request,
  );
}
