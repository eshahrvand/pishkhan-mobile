import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/certificate_data.dart';
import '../entities/financial_certificate_data.dart';
import 'deposit_certificates_repository.dart';

abstract interface class FinancialCertificateRepository
    implements CertificateCatalogRepository {
  Future<Result<CertificateReceipt>> submitFinancialCertificate(
    FinancialCertificateRequest request,
  );
}
