import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/certificate_data.dart';

abstract interface class CertificateCatalogRepository {
  Future<Result<CertificateCatalog>> load();
}

abstract interface class DepositCertificatesRepository
    implements CertificateCatalogRepository {
  Future<Result<CertificateReceipt>> submitAverageBalance(
    AverageBalanceRequest request,
  );
}
