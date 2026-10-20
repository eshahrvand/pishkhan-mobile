import '../entities/request_report.dart';

List<RequestReport> filterRequestReports({
  required List<RequestReport> reports,
  required RequestReportFilter filter,
  required String query,
  required DateTime bankTime,
}) {
  // Bank business days use Iran's fixed UTC+03:30 offset, independent of device zone.
  const offset = Duration(hours: 3, minutes: 30);
  final bankDate = bankTime.toUtc().add(offset);
  final today = DateTime.utc(bankDate.year, bankDate.month, bankDate.day);
  final start = switch (filter.period) {
    ReportDatePeriod.all => null,
    ReportDatePeriod.today => today,
    ReportDatePeriod.lastWeek => today.subtract(const Duration(days: 6)),
    ReportDatePeriod.lastMonth => today.subtract(const Duration(days: 29)),
    ReportDatePeriod.lastThreeMonths => today.subtract(
      const Duration(days: 89),
    ),
  };
  final end = today.add(const Duration(days: 1));
  return List.unmodifiable(
    reports.where((report) {
        final date = report.createdAt.toUtc().add(offset);
        return (filter.types?.contains(report.type) ?? true) &&
            (filter.statuses?.contains(report.status) ?? true) &&
            report.trackingId.contains(query.trim()) &&
            (start == null || (!date.isBefore(start) && date.isBefore(end)));
      }).toList()
      ..sort((first, second) => second.createdAt.compareTo(first.createdAt)),
  );
}

List<ReportRequestType> searchReportTypes(String query) {
  final normalized = _normalize(query);
  return List.unmodifiable(
    ReportRequestType.values.where((type) {
      return _normalize(_searchTerms[type]!).contains(normalized);
    }),
  );
}

String _normalize(String value) => value
    .toLowerCase()
    .replaceAll('ي', 'ی')
    .replaceAll('ك', 'ک')
    .replaceAll('\u200c', ' ')
    .trim();

// Search aliases are independent of translated display labels and option identity.
const _searchTerms = {
  ReportRequestType.openCurrentDeposit:
      'افتتاح سپرده جاری open current deposit فتح حساب جاري',
  ReportRequestType.blockDeposit: 'مسدودی سپرده block deposit حظر الوديعة',
  ReportRequestType.unblockDeposit:
      'رفع مسدودی سپرده unblock deposit إلغاء حظر الوديعة',
  ReportRequestType.mobilePassword: 'تغییر گذرواژه موبایل بانک mobile banking password تغيير كلمة مرور الهاتف',
  ReportRequestType.internetPassword: 'تغییر گذرواژه اینترنت بانک internet banking password تغيير كلمة مرور الإنترنت',
  ReportRequestType.installmentDeposit: 'تغییر سپرده جهت کسر اقساط installment repayment deposit تغيير وديعة الأقساط',
  ReportRequestType.chequeBook: 'صدور دسته چک cheque book إصدار دفتر شيكات',
  ReportRequestType.chequeClearance:
      'رفع سوء اثر چک cheque clearance إزالة أثر الشيك',
  ReportRequestType.onSiteTransfer:
      'انتقال وجه در محل on site transfer تحويل الأموال في الموقع',
};
