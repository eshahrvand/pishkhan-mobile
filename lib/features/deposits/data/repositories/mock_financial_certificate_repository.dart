import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/certificate_data.dart';
import '../../domain/entities/financial_certificate_data.dart';
import '../../domain/repositories/financial_certificate_repository.dart';
import 'mock_deposit_certificates_repository.dart';

class MockFinancialCertificateRepository
    extends MockDepositCertificatesRepository
    implements FinancialCertificateRepository {
  MockFinancialCertificateRepository({super.catalog});
  final _financialReceipts = <String, CertificateReceipt>{};
  @override
  Future<Result<CertificateReceipt>> submitFinancialCertificate(
    FinancialCertificateRequest request,
  ) async {
    if (_financialReceipts[request.idempotencyKey] case final receipt?) {
      return Success(receipt);
    }
    if (request.idempotencyKey.isEmpty ||
        request.conditions.isEmpty ||
        !catalog.deposits.any((d) => d.id == request.depositId) ||
        !catalog.currencies.contains(request.currency) ||
        (request.recipient == FinancialCertificateRecipient.embassy
            ? !catalog.embassies.any((e) => e.id == request.embassyId)
            : request.authorityName?.trim().isNotEmpty != true) ||
        catalog.walletBalanceRial <
            catalog.printFeeRial + catalog.deliveryFeeRial) {
      return const Err(DataFailure('financial.certificate.request.invalid'));
    }
    const receipt = CertificateReceipt(reference: 'FC-DEMO-001', isMock: true);
    _financialReceipts[request.idempotencyKey] = receipt;
    return const Success(receipt);
  }
}
