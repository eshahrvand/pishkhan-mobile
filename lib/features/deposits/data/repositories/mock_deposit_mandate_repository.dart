import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/listed_deposit.dart';
import '../../domain/entities/deposit_mandate.dart';
import '../../domain/repositories/deposit_mandate_repository.dart';

/// Preview data only; no real deposit mandate or balance reservation occurs.
class MockDepositMandateRepository implements DepositMandateRepository {
  static final catalog = DepositMandateCatalog(
    companies: const [
      DepositMandateCompany(
        id: 'autonovin',
        name: 'خودرو وارداتی - سامانه اتونوین',
      ),
      DepositMandateCompany(id: 'demo', name: 'شرکت آزمایشی'),
    ],
    subjects: [
      DepositMandateSubject(
        id: 'imported-cars',
        companyId: 'autonovin',
        title: 'خودرو وارداتی',
        brokerName: 'سازمان حمایت از مصرف کننده',
        amountRial: 5000000000,
        depositIds: const ['proxy-1', 'proxy-2'],
      ),
      DepositMandateSubject(
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
  final _requests = <String, DepositMandateRequest>{};
  final _receipts = <String, DepositMandateReceipt>{};
  final _mandates = <String>{};
  @override
  Future<Result<DepositMandateCatalog>> fetchCatalog() async =>
      Success(catalog);

  @override
  Future<Result<DepositMandateReceipt>> submitDepositMandate(
    DepositMandateRequest request,
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
    final receipt = DepositMandateReceipt(
      reference: 'DEMO-PROXY-${_receipts.length + 1}',
      isMock: true,
    );
    _requests[request.idempotencyKey] = request;
    _receipts[request.idempotencyKey] = receipt;
    _mandates.add('${request.subjectId}:${request.depositId}');
    return Success(receipt);
  }
}
