import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/certificate_data.dart';
import '../entities/financial_certificate_data.dart';
import '../repositories/financial_certificate_repository.dart';

class SubmitFinancialCertificateUseCase {
  const SubmitFinancialCertificateUseCase(this.repository);
  final FinancialCertificateRepository repository;

  Future<Result<CertificateReceipt>> call(
    FinancialCertificateRequest request,
  ) async {
    try {
      return await repository.submitFinancialCertificate(request);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}
