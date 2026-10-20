import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/requests/data/repositories/mock_request_reports_repository.dart';
import 'package:pishkhan_mobile/features/requests/domain/entities/request_report.dart';
import 'package:pishkhan_mobile/features/requests/domain/repositories/request_reports_repository.dart';
import 'package:pishkhan_mobile/features/requests/domain/usecases/filter_request_reports.dart';
import 'package:pishkhan_mobile/features/requests/presentation/reports/cubit/request_reports_cubit.dart';

final bankTime = DateTime.utc(2026, 10, 20, 8);

void main() {
  late ControlledReportsRepository repository;
  late RequestReportsCubit cubit;

  setUp(() {
    repository = ControlledReportsRepository();
    getIt.registerSingleton<RequestReportsRepository>(repository);
    cubit = RequestReportsCubit();
  });
  tearDown(() async {
    await cubit.close();
    await getIt.reset();
  });

  test(
    'construction preserves supplied initial state without fetching',
    () async {
      const initial = RequestReportsState.initial(trackingQuery: '137');
      final seeded = RequestReportsCubit(initialState: initial);
      expect(seeded.state, initial);
      expect(repository.fetchCount, 0);
      await seeded.close();
    },
  );

  test(
    'type, status, date and identifier filters compose; refresh preserves them',
    () async {
      await cubit.fetchReports();
      cubit.openTypeFilter();
      cubit.toggleAllDraftTypes();
      cubit.toggleDraftType(ReportRequestType.installmentDeposit);
      cubit.applyFilter();
      cubit.cancelDraftFilter();
      cubit.openStatusFilter();
      cubit.toggleAllDraftStatuses();
      cubit.toggleDraftStatus(ReportRequestStatus.awaitingApproval);
      cubit.applyFilter();
      cubit.cancelDraftFilter();
      cubit.openDateFilter();
      cubit.selectDraftPeriod(ReportDatePeriod.lastWeek);
      cubit.applyFilter();
      cubit.cancelDraftFilter();
      cubit.updateTrackingQuery('487567');
      expect(cubit.state.visibleReports.map((report) => report.trackingId), [
        '137/487567',
      ]);
      final filter = cubit.state.filter;
      await cubit.fetchReports();
      expect(cubit.state.filter, filter);
      expect(cubit.state.visibleReports, hasLength(1));
      cubit.updateTrackingQuery('missing');
      expect(cubit.state.visibleReports, isEmpty);
    },
  );

  test('discarding a draft keeps committed results; empty selection means no results', () async {
    await cubit.fetchReports();
    final reports = cubit.state.visibleReports;
    cubit.openStatusFilter();
    cubit.toggleAllDraftStatuses();
    expect(cubit.state.visibleReports, reports);
    cubit.cancelDraftFilter();
    expect(cubit.state.filter.statuses, isNull);
    cubit.openStatusFilter();
    cubit.toggleAllDraftStatuses();
    cubit.applyFilter();
    expect(cubit.state.visibleReports, isEmpty);
    cubit.cancelDraftFilter();
    cubit.resetFilters();
    expect(cubit.state.visibleReports, reports);
  });

  test('type search does not lose hidden selections; all individual choices restore all', () async {
    await cubit.fetchReports();
    cubit.openTypeFilter();
    cubit.toggleAllDraftTypes();
    cubit.toggleDraftType(ReportRequestType.chequeBook);
    cubit.updateTypeQuery('اقساط');
    expect(cubit.state.visibleTypes, [ReportRequestType.installmentDeposit]);
    cubit.toggleDraftType(ReportRequestType.installmentDeposit);
    cubit.updateTypeQuery('');
    expect(cubit.state.draftFilter!.types, {
      ReportRequestType.chequeBook,
      ReportRequestType.installmentDeposit,
    });
    for (final type
        in ReportRequestType.values
            .where((type) => !cubit.state.draftFilter!.types!.contains(type))
            .toList()) {
      cubit.toggleDraftType(type);
    }
    expect(cubit.state.draftFilter!.types, isNull);
  });

  test('only awaiting approval exposes cancellation; dismissed details never cancel', () async {
    await cubit.fetchReports();
    for (final report in cubit.state.reports) {
      cubit.requestDetails(report);
      expect(
        cubit.state.canCancelRequest,
        report.status == ReportRequestStatus.awaitingApproval,
      );
      cubit.applyDetailsResult(null);
    }
    expect(repository.cancelKeys, isEmpty);
  });

  test('failure preserves request identity for retry; success updates active filters', () async {
    await cubit.fetchReports();
    cubit.openStatusFilter();
    cubit.toggleAllDraftStatuses();
    cubit.toggleDraftStatus(ReportRequestStatus.awaitingApproval);
    cubit.applyFilter();
    cubit.cancelDraftFilter();
    cubit.requestDetails(cubit.state.visibleReports.first);
    cubit.applyDetailsResult(RequestDetailsAction.cancelRequest);
    repository.failCancellation = true;
    await cubit.submitCancellation();
    expect(cubit.state.cancellationStatus, RequestStatus.failure);
    expect(cubit.state.canCancelRequest, isTrue);
    repository.failCancellation = false;
    await cubit.submitCancellation();
    expect(repository.cancelKeys[0], repository.cancelKeys[1]);
    expect(cubit.state.cancellationStatus, RequestStatus.success);
    expect(cubit.state.canCancelRequest, isFalse);
    expect(cubit.state.selectedReport!.status, ReportRequestStatus.cancelled);
    expect(
      cubit.state.visibleReports.any(
        (report) => report.trackingId == '137/487567',
      ),
      isFalse,
    );
    await cubit.fetchReports();
    expect(cubit.state.reports.first.status, ReportRequestStatus.cancelled);
  });

  test('fetch errors can be retried without losing search input', () async {
    repository.failFetch = true;
    await cubit.fetchReports();
    expect(cubit.state.reportsStatus, RequestStatus.failure);
    repository.failFetch = false;
    await cubit.fetchReports();
    expect(cubit.state.reportsStatus, RequestStatus.success);
  });

  test('Iran midnight boundaries include today and exclude the next day', () {
    RequestReport report(String id, DateTime time) => RequestReport(
      trackingId: id,
      type: ReportRequestType.chequeBook,
      createdAt: time,
      status: ReportRequestStatus.completed,
      details: '',
    );
    final reports = [
      report('before', DateTime.utc(2026, 10, 19, 20, 29, 59)),
      report('start', DateTime.utc(2026, 10, 19, 20, 30)),
      report('end', DateTime.utc(2026, 10, 20, 20, 29, 59)),
      report('after', DateTime.utc(2026, 10, 20, 20, 30)),
    ];
    expect(
      filterRequestReports(
        reports: reports,
        filter: const RequestReportFilter(period: ReportDatePeriod.today),
        query: '',
        bankTime: bankTime,
      ).map((report) => report.trackingId),
      ['end', 'start'],
    );
  });

  test('mock server refuses cancellation of completed requests and replays a stable key', () async {
    final adapter = MockRequestReportsRepository(now: () => bankTime);
    final catalog =
        (await adapter.fetchReports() as Success<RequestReportCatalog>).data;
    final invalid = await adapter.cancelRequest(
      trackingId: catalog.reports[1].trackingId,
      idempotencyKey: 'completed',
    );
    expect(invalid, isA<Err<RequestReport>>());
    final first = await adapter.cancelRequest(
      trackingId: catalog.reports.first.trackingId,
      idempotencyKey: 'pending',
    );
    final retry = await adapter.cancelRequest(
      trackingId: catalog.reports.first.trackingId,
      idempotencyKey: 'pending',
    );
    expect(
      (first as Success<RequestReport>).data,
      (retry as Success<RequestReport>).data,
    );
  });
}

class ControlledReportsRepository implements RequestReportsRepository {
  final adapter = MockRequestReportsRepository(now: () => bankTime);
  bool failFetch = false;
  bool failCancellation = false;
  int fetchCount = 0;
  final cancelKeys = <String>[];

  @override
  Future<Result<RequestReportCatalog>> fetchReports() {
    fetchCount++;
    return failFetch
        ? Future.value(const Err(DataFailure('offline')))
        : adapter.fetchReports();
  }

  @override
  Future<Result<RequestReport>> cancelRequest({
    required String trackingId,
    required String idempotencyKey,
  }) {
    cancelKeys.add(idempotencyKey);
    return failCancellation
        ? Future.value(const Err(DataFailure('offline')))
        : adapter.cancelRequest(
            trackingId: trackingId,
            idempotencyKey: idempotencyKey,
          );
  }
}
