import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/request_report.dart';
import '../repositories/request_reports_repository.dart';

class FetchRequestReportsUseCase {
  const FetchRequestReportsUseCase(this.repository);
  final RequestReportsRepository repository;

  Future<Result<RequestReportCatalog>> call() async {
    try {
      return await repository.fetchReports();
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class CancelReportedRequestUseCase {
  const CancelReportedRequestUseCase(this.repository);
  final RequestReportsRepository repository;

  Future<Result<RequestReport>> call({
    required String trackingId,
    required String idempotencyKey,
  }) async {
    try {
      return await repository.cancelRequest(
        trackingId: trackingId,
        idempotencyKey: idempotencyKey,
      );
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}
