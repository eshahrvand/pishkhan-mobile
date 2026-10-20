import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/request_report.dart';
import '../../domain/repositories/request_reports_repository.dart';

/// In-memory demonstration data; never cancels a real banking request.
class MockRequestReportsRepository implements RequestReportsRepository {
  MockRequestReportsRepository({this.now});

  final DateTime Function()? now;
  List<RequestReport>? _reports;
  final Map<String, RequestReport> _cancellations = {};

  @override
  Future<Result<RequestReportCatalog>> fetchReports() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      final time = (now?.call() ?? DateTime.now()).toUtc();
      _reports ??= _seedReports(time);
      return Success(RequestReportCatalog(reports: _reports!, bankTime: time));
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }

  @override
  Future<Result<RequestReport>> cancelRequest({
    required String trackingId,
    required String idempotencyKey,
  }) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      final previous = _cancellations[idempotencyKey];
      if (previous != null) {
        return previous.trackingId == trackingId
            ? Success(previous)
            : const Err(DataFailure('request.identity.changed'));
      }
      final report = _reports
          ?.where((report) => report.trackingId == trackingId)
          .firstOrNull;
      if (report == null ||
          report.status != ReportRequestStatus.awaitingApproval) {
        return const Err(DataFailure('request.cancellation.unavailable'));
      }
      final cancelled = report.withStatus(ReportRequestStatus.cancelled);
      _reports = [
        for (final item in _reports!)
          if (item.trackingId == trackingId) cancelled else item,
      ];
      _cancellations[idempotencyKey] = cancelled;
      return Success(cancelled);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }

  List<RequestReport> _seedReports(DateTime time) {
    return [
      for (var index = 0; index < 9; index++)
        RequestReport(
          trackingId: '137/${487567 + index}',
          type: index < 4
              ? ReportRequestType.installmentDeposit
              : ReportRequestType.values[index - 4],
          createdAt: time.subtract(
            Duration(days: [0, 2, 8, 20, 35, 60, 85, 95, 120][index]),
          ),
          status: ReportRequestStatus
              .values[index % ReportRequestStatus.values.length],
          details: index < 4
              ? 'درخواست تغییر سپرده جهت کسر اقساط'
              : 'درخواست ثبت‌شده آزمایشی',
          showListDetails: index != 0,
        ),
    ];
  }
}
