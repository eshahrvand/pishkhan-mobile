import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/listed_deposit.dart';
import '../entities/surplus_deposit_closure.dart';

abstract interface class SurplusDepositsRepository {
  Future<Result<List<ListedDeposit>>> fetchPrimaryDeposits();
  Future<Result<SurplusDepositReview>> fetchSurplusDeposits(
    ListedDeposit primaryDeposit,
  );
  Future<Result<SurplusDepositClosureReceipt>> closeSurplusDeposits(
    CloseSurplusDepositsRequest request,
  );
}
