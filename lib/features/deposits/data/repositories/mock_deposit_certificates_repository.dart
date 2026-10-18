import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/certificate_data.dart';
import '../../domain/entities/listed_deposit.dart';
import '../../domain/repositories/deposit_certificates_repository.dart';
import 'mock_deposits_repository.dart';

/// Illustrative fees and receipts only. No certificate issued or wallet debited.
class MockDepositCertificatesRepository
    implements DepositCertificatesRepository {
  MockDepositCertificatesRepository({CertificateCatalog? catalog})
    : catalog = catalog ?? examples;
  final CertificateCatalog catalog;
  final _receipts = <String, CertificateReceipt>{};
  static final examples = CertificateCatalog(
    deposits: [
      ListedDeposit(id: 'certificate-deposit-1', number: '10.1234567.1'),
      ListedDeposit(
        id: 'certificate-deposit-2',
        number: '10.1200700.20',
        kind: DepositKind.current,
      ),
      ...MockDepositsRepository.examples,
    ],
    addresses: const [
      CertificateAddress(
        id: 'home',
        title: 'خانه',
        detail: 'تهران - خیابان شریعتی - روبروی خیابان یخچال - بن بست شریف - پلاک ۴ - واحد ۱',
        postalCode: '1912134564',
      ),
    ],
  );
  @override
  Future<Result<CertificateCatalog>> load() async => Success(catalog);
  @override
  Future<Result<CertificateReceipt>> submitAverageBalance(
    AverageBalanceRequest request,
  ) async {
    if (_receipts[request.idempotencyKey] case final receipt?) {
      return Success(receipt);
    }
    if (request.idempotencyKey.isEmpty ||
        !catalog.deposits.any((d) => d.id == request.depositId) ||
        catalog.walletBalanceRial <
            catalog.printFeeRial + catalog.deliveryFeeRial ||
        request.address.detail.trim().isEmpty) {
      return const Err(DataFailure('certificate.request.invalid'));
    }
    final receipt = CertificateReceipt(reference: 'AB-DEMO-001', isMock: true);
    _receipts[request.idempotencyKey] = receipt;
    return Success(receipt);
  }
}
