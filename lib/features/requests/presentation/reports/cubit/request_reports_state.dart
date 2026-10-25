part of 'request_reports_cubit.dart';

enum RequestReportsEffect {
  typeFilter,
  statusFilter,
  dateFilter,
  details,
  cancelConfirmation,
  back,
  assistant,
}

enum RequestDetailsAction { cancelRequest }

@Freezed(toStringOverride: false)
abstract class RequestReportsState with _$RequestReportsState {
  const factory RequestReportsState.initial({
    @Default(RequestStatus.initial) RequestStatus reportsStatus,
    @Default(RequestStatus.initial) RequestStatus cancellationStatus,
    @Default(<RequestReport>[]) List<RequestReport> reports,
    @Default(<RequestReport>[]) List<RequestReport> visibleReports,
    @Default('') String trackingQuery,
    @Default(RequestReportFilter()) RequestReportFilter filter,
    RequestReportFilter? draftFilter,
    @Default('') String typeQuery,
    @Default(ReportRequestType.values) List<ReportRequestType> visibleTypes,
    DateTime? bankTime,
    RequestReport? selectedReport,
    @Default(false) bool canCancelRequest,
    Failure? failure,
    String? message,

    RequestReportsEffect? effect,
  }) = _RequestReportsState;
}
