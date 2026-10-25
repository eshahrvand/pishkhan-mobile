import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/cheque_clearance.dart';

abstract interface class ChequeClearanceRepository {
  Future<Result<ChequeClearanceCatalog>> fetchCatalog();
  Future<Result<ChequeClearanceReceipt>> submitClearance(
    ChequeClearanceRequest request,
  );
}
