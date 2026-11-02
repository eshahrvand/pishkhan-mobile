import 'package:pishkhan_mobile/core/platform/selected_document.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/on_site_transfer.dart';
import '../repositories/on_site_transfer_repository.dart';

class UploadTransferDestinationsUseCase {
  const UploadTransferDestinationsUseCase(this.repository);
  final OnSiteTransferRepository repository;
  Future<Result<TransferAttachment>> call(
    SelectedDocument file,
    void Function(double) onProgress,
  ) async {
    try {
      if (!file.name.toLowerCase().endsWith('.xls') ||
          file.bytes.isEmpty ||
          file.bytes.length > 100 * 1024) {
        return const Err(DataFailure('transfer.file.invalid'));
      }
      return await repository.uploadDestinations(file, onProgress);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class FetchOnSiteTransferCatalogUseCase {
  const FetchOnSiteTransferCatalogUseCase(this.repository);
  final OnSiteTransferRepository repository;

  Future<Result<TransferCatalog>> call() async {
    try {
      return await repository.fetchCatalog();
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class ResolveTransferDestinationUseCase {
  const ResolveTransferDestinationUseCase(this.repository);
  final OnSiteTransferRepository repository;

  Future<Result<TransferDestination>> call({
    required String iban,
    required int amountRial,
    required TransferPurpose purpose,
    required String description,
  }) async {
    try {
      return await repository.resolveDestination(
        iban: iban,
        amountRial: amountRial,
        purpose: purpose,
        description: description,
      );
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class SubmitOnSiteTransferUseCase {
  const SubmitOnSiteTransferUseCase(this.repository);
  final OnSiteTransferRepository repository;

  Future<Result<TransferReceipt>> call(OnSiteTransferRequest request) async {
    try {
      return await repository.submit(request);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}
