import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/proxy_deposit.dart';

abstract interface class ProxyDepositsRepository {
  Future<Result<ProxyDepositCatalog>> fetchCatalog();
  Future<Result<ProxyDepositReceipt>> submitProxyDeposit(
    ProxyDepositRequest request,
  );
}
