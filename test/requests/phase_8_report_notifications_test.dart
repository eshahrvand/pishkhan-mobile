import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/features/requests/domain/entities/request_report.dart';
import 'package:pishkhan_mobile/features/requests/domain/repositories/request_reports_repository.dart';
import 'package:pishkhan_mobile/features/requests/presentation/reports/cubit/request_reports_cubit.dart';
import 'package:pishkhan_mobile/features/requests/presentation/reports/screens/request_reports_screen.dart';
import 'package:pishkhan_mobile/features/requests/presentation/reports/widgets/report_cancellation_sheet.dart';
import 'package:pishkhan_mobile/features/requests/presentation/reports/widgets/report_type_filter_sheet.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../deposits/certificate_test_support.dart';
import 'request_reports_cubit_test.dart' show ControlledReportsRepository;

void main() {
  setUpAll(loadCertificateFonts);
  setUp(configureDependencies);
  tearDown(() => getIt.reset());

  testWidgets(
    'cancellation retry errors repeat; filters still open and success closes only its own modal',
    (tester) async {
      final repository = ControlledReportsRepository()..failCancellation = true;
      await getIt.unregister<RequestReportsRepository>();
      getIt.registerSingleton<RequestReportsRepository>(repository);
      await mountCertificate(tester, const RequestReportsScreen());
      final cubit = tester
          .element(find.byType(AppTopBar))
          .read<RequestReportsCubit>();
      final report = cubit.state.reports.firstWhere(
        (r) => r.status == ReportRequestStatus.awaitingApproval,
      );
      cubit.requestDetails(report);
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.reportCancelRequest));
      await tester.pumpAndSettle();
      expect(find.byType(ReportCancellationSheet), findsOneWidget);
      for (var attempt = 0; attempt < 2; attempt++) {
        await tester.tap(find.text(S.current.reportConfirmCancel));
        await tester.pumpAndSettle();
        expect(find.byType(AvpSnackBar), findsOneWidget);
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text(S.current.dashboardCancel));
      await tester.pumpAndSettle();
      cubit.requestTypeFilter();
      await tester.pumpAndSettle();
      expect(find.byType(ReportTypeFilterSheet), findsOneWidget);
      expect(find.byType(AvpSnackBar), findsNothing);
      Navigator.of(tester.element(find.byType(ReportTypeFilterSheet))).pop();
      await tester.pumpAndSettle();
      cubit.requestDetails(report);
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.reportCancelRequest));
      await tester.pumpAndSettle();
      repository.failCancellation = false;
      await tester.tap(find.text(S.current.reportConfirmCancel));
      await tester.pumpAndSettle();
      expect(cubit.state.cancellationStatus, RequestStatus.success);
      expect(cubit.state.selectedReport!.status, ReportRequestStatus.cancelled);
      expect(cubit.state.failure, isNotNull);
      expect(repository.cancelKeys.toSet(), hasLength(1));
      expect(find.byType(ReportCancellationSheet), findsNothing);
      expect(find.byType(AvpSnackBar), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
