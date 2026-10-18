import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/certificate_data.dart';
import '../repositories/deposit_certificates_repository.dart';

Future<Result<T>> certificateBoundary<T>(
  Future<Result<T>> Function() call,
) async {
  try {
    return await call();
  } catch (_) {
    return const Err(UnexpectedFailure());
  }
}

class LoadCertificateCatalog {
  const LoadCertificateCatalog(this.repository);
  final CertificateCatalogRepository repository;
  Future<Result<CertificateCatalog>> call() async {
    final result = await certificateBoundary(repository.load);
    if (result is Err<CertificateCatalog>) return result;
    final data = (result as Success<CertificateCatalog>).data;
    if (data.deposits.any(
          (d) => d.id.trim().isEmpty || d.number.trim().isEmpty,
        ) ||
        data.deposits.map((d) => d.id).toSet().length != data.deposits.length ||
        data.addresses.any(
          (a) =>
              a.id.trim().isEmpty ||
              a.title.trim().isEmpty ||
              a.detail.trim().isEmpty,
        ) ||
        data.addresses.map((a) => a.id).toSet().length !=
            data.addresses.length ||
        data.embassies.any(
          (e) => e.id.trim().isEmpty || e.label.trim().isEmpty,
        ) ||
        data.embassies.map((e) => e.id).toSet().length !=
            data.embassies.length ||
        data.currencies.toSet().length != data.currencies.length ||
        data.printFeeRial < 0 ||
        data.deliveryFeeRial < 0 ||
        data.walletBalanceRial < 0) {
      return const Err(DataFailure('certificate.catalog.invalid'));
    }
    return Success(data);
  }
}
