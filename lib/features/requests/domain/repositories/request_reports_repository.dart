import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/request_report.dart';

abstract interface class RequestReportsRepository {
  Future<Result<RequestReportCatalog>> fetchReports();

  /// The server authorizes ownership/status and preserves identity across retries.
  Future<Result<RequestReport>> cancelRequest({
    required String trackingId,
    required String idempotencyKey,
  });
}
