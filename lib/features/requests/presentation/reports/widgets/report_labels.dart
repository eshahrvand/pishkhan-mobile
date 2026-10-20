import 'package:avp_ui/avp_ui.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/request_report.dart';

String reportTypeLabel(ReportRequestType type) => switch (type) {
  ReportRequestType.openCurrentDeposit => S.current.reportTypeCurrentDeposit,
  ReportRequestType.blockDeposit => S.current.reportTypeBlockDeposit,
  ReportRequestType.unblockDeposit => S.current.reportTypeUnblockDeposit,
  ReportRequestType.mobilePassword => S.current.reportTypeMobilePassword,
  ReportRequestType.internetPassword => S.current.reportTypeInternetPassword,
  ReportRequestType.installmentDeposit =>
    S.current.reportTypeInstallmentDeposit,
  ReportRequestType.chequeBook => S.current.reportTypeChequeBook,
  ReportRequestType.chequeClearance => S.current.reportTypeChequeClearance,
  ReportRequestType.onSiteTransfer => S.current.reportTypeOnSiteTransfer,
};

String reportStatusLabel(ReportRequestStatus status) => switch (status) {
  ReportRequestStatus.awaitingApproval =>
    S.current.reportStatusAwaitingApproval,
  ReportRequestStatus.completed => S.current.reportStatusCompleted,
  ReportRequestStatus.rejected => S.current.reportStatusRejected,
  ReportRequestStatus.systemError => S.current.reportStatusSystemError,
  ReportRequestStatus.cancelled => S.current.reportStatusCancelled,
};

AppBadgeColor reportStatusColor(ReportRequestStatus status) => switch (status) {
  ReportRequestStatus.awaitingApproval => AppBadgeColor.warning,
  ReportRequestStatus.completed => AppBadgeColor.success,
  ReportRequestStatus.rejected ||
  ReportRequestStatus.systemError => AppBadgeColor.error,
  ReportRequestStatus.cancelled => AppBadgeColor.gray,
};

String reportPeriodLabel(ReportDatePeriod period) => switch (period) {
  ReportDatePeriod.all => S.current.reportDateAll,
  ReportDatePeriod.today => S.current.reportDateToday,
  ReportDatePeriod.lastWeek => S.current.reportDateLastWeek,
  ReportDatePeriod.lastMonth => S.current.reportDateLastMonth,
  ReportDatePeriod.lastThreeMonths => S.current.reportDateLastThreeMonths,
};

String reportDateLabel(DateTime date) {
  final bankDate = date.toUtc().add(const Duration(hours: 3, minutes: 30));
  return '\u2066${JalaliDateFormatter.format(bankDate)}  -  '
      '${CurrencyFormatter.toPersianDigits('${bankDate.hour.toString().padLeft(2, '0')}:${bankDate.minute.toString().padLeft(2, '0')}')}\u2069';
}
