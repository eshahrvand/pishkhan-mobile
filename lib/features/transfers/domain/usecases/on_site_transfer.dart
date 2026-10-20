import 'package:pishkhan_mobile/core/platform/selected_document.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/on_site_transfer.dart';
import '../repositories/on_site_transfer_repository.dart';

class UploadTransferDestinations {
  const UploadTransferDestinations(this.repository);
  final OnSiteTransferRepository repository;
  Future<Result<TransferAttachment>> call(
    SelectedDocument file,
    void Function(double) onProgress,
  ) {
    if (!file.name.toLowerCase().endsWith('.xls') ||
        file.bytes.isEmpty ||
        file.bytes.length > 100 * 1024) {
      return Future.value(const Err(DataFailure('transfer.file.invalid')));
    }
    return repository.uploadDestinations(file, onProgress);
  }
}
