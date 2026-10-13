import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/listed_deposit.dart';

abstract interface class DepositsRepository {
  Future<Result<List<ListedDeposit>>> getDeposits();
}
