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
