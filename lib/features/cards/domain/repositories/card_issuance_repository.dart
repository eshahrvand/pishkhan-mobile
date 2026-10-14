import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/issuance_data.dart';

abstract interface class CardIssuanceRepository {
  Future<Result<IssuanceCatalog>> load();

  /// Production adapter must quote, authorize and submit atomically/idempotently.
  /// The UI never treats its illustrative fee calculation as a payment authority.
  Future<Result<IssuanceReceipt>> submit(IssuanceRequest request);
}
