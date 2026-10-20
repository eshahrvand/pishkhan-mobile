import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/cheque_cancellation.dart';

abstract interface class ChequeCancellationRepository {
  Future<Result<ChequeCancellationCatalog>> fetchCatalog();
  Future<Result<List<CancellableCheque>>> fetchCheques(
    String depositId,
    CancellationChequeType type,
  );
  Future<Result<ChequeCancellationReceipt>> submitCancellation(
    ChequeCancellationRequest request,
  );
}
