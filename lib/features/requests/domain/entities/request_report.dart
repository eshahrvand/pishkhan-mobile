import 'package:equatable/equatable.dart';

enum ReportRequestType {
  openCurrentDeposit,
  blockDeposit,
  unblockDeposit,
  mobilePassword,
  internetPassword,
  installmentDeposit,
  chequeBook,
  chequeClearance,
  onSiteTransfer,
}

enum ReportRequestStatus {
  awaitingApproval,
  completed,
  rejected,
  systemError,
  cancelled,
}

enum ReportDatePeriod { all, today, lastWeek, lastMonth, lastThreeMonths }

class RequestReport extends Equatable {
  const RequestReport({
    required this.trackingId,
    required this.type,
    required this.createdAt,
    required this.status,
    required this.details,
    this.showListDetails = true,
  });

  final String trackingId;
  final ReportRequestType type;
  final DateTime createdAt;
  final ReportRequestStatus status;
  final String details;
  final bool showListDetails;

  RequestReport withStatus(ReportRequestStatus status) {
    return RequestReport(
      trackingId: trackingId,
      type: type,
      createdAt: createdAt,
      status: status,
      details: details,
      showListDetails: showListDetails,
    );
  }

  @override
  List<Object?> get props => [
    trackingId,
    type,
    createdAt,
    status,
    details,
    showListDetails,
  ];
}

class RequestReportFilter extends Equatable {
  const RequestReportFilter({
    this.types,
    this.statuses,
    this.period = ReportDatePeriod.all,
  });

  // null selects every option, including options added to the server catalog later.
  // An empty set intentionally selects no requests.
  final Set<ReportRequestType>? types;
  final Set<ReportRequestStatus>? statuses;
  final ReportDatePeriod period;

  @override
  List<Object?> get props => [types, statuses, period];
}

class RequestReportCatalog extends Equatable {
  RequestReportCatalog({
    required List<RequestReport> reports,
    required this.bankTime,
  }) : reports = List.unmodifiable(reports);

  final List<RequestReport> reports;
  final DateTime bankTime;

  @override
  List<Object?> get props => [reports, bankTime];
}
