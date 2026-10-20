import 'package:pishkhan_mobile/core/platform/selected_document.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/on_site_transfer.dart';

abstract interface class OnSiteTransferRepository {
  Future<Result<TransferCatalog>> fetchCatalog();
  Future<Result<TransferDestination>> resolveDestination({
    required String iban,
    required int amountRial,
    required TransferPurpose purpose,
    required String description,
  });
  Future<Result<TransferAttachment>> uploadDestinations(
    SelectedDocument file,
    void Function(double) onProgress,
  );
  Future<Result<TransferReceipt>> submit(OnSiteTransferRequest request);
}
