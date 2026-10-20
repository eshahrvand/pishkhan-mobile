import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/listed_deposit.dart';
import '../../domain/entities/proxy_deposit.dart';
import '../../domain/repositories/proxy_deposits_repository.dart';

/// Preview data only; no real proxy mandate or balance reservation occurs.
class MockProxyDepositsRepository implements ProxyDepositsRepository {
  static final catalog = ProxyDepositCatalog(
    companies: const [
      ProxyCompany(id: 'autonovin', name: 'خودرو وارداتی - سامانه اتونوین'),
      ProxyCompany(id: 'demo', name: 'شرکت آزمایشی'),
    ],
    subjects: [
      ProxySubject(
        id: 'imported-cars',
        companyId: 'autonovin',
        title: 'خودرو وارداتی',
        brokerName: 'سازمان حمایت از مصرف کننده',
        amountRial: 5000000000,
        depositIds: const ['proxy-1', 'proxy-2'],
      ),
      ProxySubject(
        id: 'demo-plan',
        companyId: 'demo',
        title: 'طرح آزمایشی',
        brokerName: 'کارگزار آزمایشی',
        amountRial: 1000000000,
        depositIds: const ['proxy-3'],
      ),
    ],
    deposits: [
      for (var i = 1; i <= 3; i++)
        ListedDeposit(id: 'proxy-$i', number: '10.1234567.$i'),
    ],
    token: 'mock-proxy-catalog-v1',
  );
  final _requests = <String, ProxyDepositRequest>{};
  final _receipts = <String, ProxyDepositReceipt>{};
  final _mandates = <String>{};
  @override
  Future<Result<ProxyDepositCatalog>> fetchCatalog() async => Success(catalog);

  @override
  Future<Result<ProxyDepositReceipt>> submitProxyDeposit(
    ProxyDepositRequest request,
  ) async {
    if (_requests.containsKey(request.idempotencyKey)) {
      return request == _requests[request.idempotencyKey]
          ? Success(_receipts[request.idempotencyKey]!)
          : const Err(DataFailure('proxy.idempotency-conflict'));
    }
    final subject = catalog.subjects
        .where((subject) => subject.id == request.subjectId)
        .firstOrNull;
    if (request.catalogToken != catalog.token ||
        subject == null ||
        subject.companyId != request.companyId ||
        !subject.depositIds.contains(request.depositId) ||
        !catalog.deposits.any((deposit) => deposit.id == request.depositId)) {
      return const Err(DataFailure('proxy.selection-invalid'));
    }
    if (_mandates.contains('${request.subjectId}:${request.depositId}')) {
      return const Err(DataFailure('proxy.already-registered'));
    }
    final receipt = ProxyDepositReceipt(
      reference: 'DEMO-PROXY-${_receipts.length + 1}',
      isMock: true,
    );
    _requests[request.idempotencyKey] = request;
    _receipts[request.idempotencyKey] = receipt;
    _mandates.add('${request.subjectId}:${request.depositId}');
    return Success(receipt);
  }
}
