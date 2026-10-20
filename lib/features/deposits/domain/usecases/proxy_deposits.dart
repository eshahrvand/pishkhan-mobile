import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/proxy_deposit.dart';
import '../repositories/proxy_deposits_repository.dart';

class FetchProxyDepositCatalog {
  const FetchProxyDepositCatalog(this.repository);
  final ProxyDepositsRepository repository;
  Future<Result<ProxyDepositCatalog>> call() async {
    try {
      return await repository.fetchCatalog();
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class SubmitProxyDeposit {
  const SubmitProxyDeposit(this.repository);
  final ProxyDepositsRepository repository;
  Future<Result<ProxyDepositReceipt>> call(ProxyDepositRequest request) async {
    try {
      return await repository.submitProxyDeposit(request);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}
