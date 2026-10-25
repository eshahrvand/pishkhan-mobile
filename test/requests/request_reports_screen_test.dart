import 'package:pishkhan_mobile/core/config/constant.dart';

import 'dart:async';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/screens/dashboard_screen.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/widgets/dashboard_home_panel.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/home_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';
import 'package:pishkhan_mobile/features/requests/data/repositories/mock_request_reports_repository.dart';
import 'package:pishkhan_mobile/features/requests/domain/repositories/request_reports_repository.dart';
import 'package:pishkhan_mobile/features/requests/domain/entities/request_report.dart';
import 'package:pishkhan_mobile/features/requests/presentation/reports/widgets/report_date_filter_sheet.dart';
import 'package:pishkhan_mobile/features/requests/presentation/reports/widgets/report_filters.dart';
import 'package:pishkhan_mobile/features/requests/presentation/reports/screens/request_reports_screen.dart';
import 'package:pishkhan_mobile/features/requests/presentation/reports/widgets/report_type_filter_sheet.dart';
import 'package:pishkhan_mobile/features/requests/presentation/reports/widgets/report_status_filter_sheet.dart';
import 'package:pishkhan_mobile/features/requests/presentation/reports/widgets/report_details_sheet.dart';
import 'package:pishkhan_mobile/features/requests/presentation/reports/widgets/report_cancellation_sheet.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_request_report_card.dart';

import '../deposits/certificate_test_support.dart';

void main() {
  setUpAll(loadCertificateFonts);
  setUp(() {
    getIt.registerSingleton<RequestReportsRepository>(
      MockRequestReportsRepository(
        now: () => DateTime.utc(2026, 10, 20, 4, 42),
      ),
    );
  });
  tearDown(() => getIt.reset());

  Future<void> capture(WidgetTester tester, String name) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await tester.pumpAndSettle();
    await captureCertificate(tester, 'reports-$name');
  }

  Future<void> openFirstDetails(WidgetTester tester) async {
    await tester.tap(
      find
          .descendant(
            of: find.byType(AppRequestReportCard).first,
            matching: find.byType(InkWell),
          )
          .first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'pending details, cancel dismissal and confirmed cancellation update the list',
    (tester) async {
      await mountCertificate(tester, const RequestReportsScreen());
      await capture(tester, 'list');
      await openFirstDetails(tester);
      expect(find.text(S.current.reportCancelRequest), findsOneWidget);
      await capture(tester, 'pending-details');
      await tester.tap(find.text(S.current.reportCancelRequest));
      await tester.pumpAndSettle();
      expect(find.byType(ReportCancellationSheet), findsOneWidget);
      expect(find.byType(ReportDetailsSheet), findsNothing);
      await capture(tester, 'cancel-confirmation');
      await tester.tap(find.text(S.current.dashboardCancel));
      await tester.pumpAndSettle();
      await openFirstDetails(tester);
      expect(find.text(S.current.reportCancelRequest), findsOneWidget);
      await tester.tap(find.text(S.current.reportCancelRequest));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.reportConfirmCancel));
      await tester.pumpAndSettle();
      expect(find.byType(ReportCancellationSheet), findsNothing);
      expect(
        tester
            .widget<AppRequestReportCard>(
              find.byType(AppRequestReportCard).first,
            )
            .statusLabel,
        S.current.reportStatusCancelled,
      );
      await openFirstDetails(tester);
      expect(find.text(S.current.reportCancelRequest), findsNothing);
      expect(find.text(S.current.backLabel), findsNothing);
      await capture(tester, 'cancelled-details');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(
        find
            .descendant(
              of: find.byType(AppRequestReportCard).at(1),
              matching: find.byType(InkWell),
            )
            .first,
      );
      await tester.pumpAndSettle();
      expect(find.text(S.current.reportCancelRequest), findsNothing);
      await capture(tester, 'completed-details');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'type search and draft dismissal, status and date filters, normalized identifier',
    (tester) async {
      await mountCertificate(tester, const RequestReportsScreen());
      expect(
        tester
            .widgetList<AppChips>(find.byType(AppChips))
            .every(
              (chip) =>
                  !chip.selected &&
                  (chip.icon as AvpImage).image ==
                      '${AppConstants.baseImage}deposit_list_chevron.svg',
            ),
        isTrue,
      );
      await tester.tap(find.text(S.current.reportRequestType));
      await tester.pumpAndSettle();
      await capture(tester, 'type-filter');
      await tester.tap(find.text(S.current.reportSelectAll));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(ReportTypeFilterSheet),
          matching: find.byType(TextField),
        ),
        'اقساط',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.reportTypeInstallmentDeposit).last);
      await tester.tap(find.text(S.current.reportApplyFilter));
      await tester.pumpAndSettle();
      expect(find.byType(ReportTypeFilterSheet), findsNothing);
      expect(
        tester
            .widgetList<AppRequestReportCard>(find.byType(AppRequestReportCard))
            .every(
              (card) => card.title == S.current.reportTypeInstallmentDeposit,
            ),
        isTrue,
      );
      await tester.tap(find.text(S.current.reportStatus));
      await tester.pumpAndSettle();
      await capture(tester, 'status-filter');
      await tester.tap(find.text(S.current.reportSelectAll));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(AppRequestReportCard), findsWidgets);
      await tester.tap(find.text(S.current.reportStatus));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.reportSelectAll));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(ReportStatusFilterSheet),
          matching: find.text(S.current.reportStatusAwaitingReview),
        ),
      );
      await tester.tap(find.text(S.current.reportApplyFilter));
      await tester.pumpAndSettle();
      expect(find.byType(AppRequestReportCard), findsOneWidget);
      await tester.tap(find.text(S.current.reportDate));
      await tester.pumpAndSettle();
      await capture(tester, 'date-filter');
      await tester.tap(find.text(S.current.reportDateToday));
      await tester.tap(find.text(S.current.reportApplyFilter));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '۱۳۷/۴۸۷۵۶۷');
      await tester.pumpAndSettle();
      expect(find.byType(AppRequestReportCard), findsOneWidget);
      expect(
        tester
            .widgetList<AppChips>(find.byType(AppChips))
            .every(
              (chip) =>
                  chip.selected &&
                  (chip.icon as AvpImage).image ==
                      '${AppConstants.baseImage}deposit_list_clear.svg',
            ),
        isTrue,
      );
      expect(
        find.descendant(
          of: find.byType(ReportFilters),
          matching: find.byType(AppButton),
        ),
        findsNothing,
      );
      await capture(tester, 'active-filters');

      await tester.tap(find.text(S.current.reportRequestType));
      await tester.pumpAndSettle();
      expect(find.byType(ReportTypeFilterSheet), findsNothing);
      expect(
        tester
            .widget<AppChips>(
              find.byWidgetPredicate(
                (widget) =>
                    widget is AppChips &&
                    widget.label == S.current.reportRequestType,
              ),
            )
            .selected,
        isFalse,
      );
      expect(
        tester
            .widget<AppChips>(
              find.byWidgetPredicate(
                (widget) =>
                    widget is AppChips &&
                    widget.label == S.current.reportStatus,
              ),
            )
            .selected,
        isTrue,
      );
      expect(
        tester
            .widget<AppChips>(
              find.byWidgetPredicate(
                (widget) =>
                    widget is AppChips && widget.label == S.current.reportDate,
              ),
            )
            .selected,
        isTrue,
      );
      await capture(tester, 'type-filter-cleared');

      await tester.tap(find.text(S.current.reportDate));
      await tester.pumpAndSettle();
      expect(find.byType(ReportDateFilterSheet), findsNothing);
      expect(
        tester
            .widget<AppChips>(
              find.byWidgetPredicate(
                (widget) =>
                    widget is AppChips &&
                    widget.label == S.current.reportStatus,
              ),
            )
            .selected,
        isTrue,
      );
      await tester.tap(find.text(S.current.reportStatus));
      await tester.pumpAndSettle();
      expect(find.byType(ReportStatusFilterSheet), findsNothing);
      expect(
        tester
            .widgetList<AppChips>(find.byType(AppChips))
            .every((chip) => !chip.selected),
        isTrue,
      );
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        '137/487567',
      );
      await capture(tester, 'filters-cleared');
      await tester.enterText(find.byType(TextField), '9999');
      await tester.pumpAndSettle();
      expect(find.text(S.current.reportNoResults), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'English and Arabic at narrow width have reachable filter controls',
    (tester) async {
      for (final locale in ['en', 'ar']) {
        await mountCertificate(
          tester,
          const RequestReportsScreen(),
          size: const Size(320, 700),
          locale: locale,
          scale: 1.3,
        );
        await tester.tap(find.text(S.current.reportRequestType));
        await tester.pumpAndSettle();
        expect(
          find.text(S.current.reportApplyFilter).hitTestable(),
          findsOneWidget,
        );
        tester.view.viewInsets = const FakeViewPadding(bottom: 280);
        await tester.pumpAndSettle();
        expect(
          find.text(S.current.reportApplyFilter).hitTestable(),
          findsOneWidget,
        );
        tester.view.resetViewInsets();
        await tester.pumpAndSettle();
        await tester.tap(find.text(S.current.dashboardCancel));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    },
  );

  testWidgets(
    'existing dashboard requests service opens the independent report route',
    (tester) async {
      await getIt.reset();
      configureDependencies();
      await mountCertificate(
        tester,
        Builder(
          builder: (context) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: const DashboardScreen(),
            );
          },
        ),
      );
      final context = tester.element(find.byType(DashboardHomePanel));
      context.read<HomeCubit>().requestService(DashboardService.requests);
      await tester.pumpAndSettle();
      expect(
        GoRouter.of(context)
            .routerDelegate
            .currentConfiguration
            .last
            .matchedLocation,
        AppRoutes.requestReports,
      );
      expect(find.byType(RequestReportsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'dismissing a pending cancellation does not close a later filter sheet',
    (tester) async {
      await getIt.reset();
      final repository = DeferredCancellationRepository();
      getIt.registerSingleton<RequestReportsRepository>(repository);
      await mountCertificate(tester, const RequestReportsScreen());
      await openFirstDetails(tester);
      await tester.tap(find.text(S.current.reportCancelRequest));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.reportConfirmCancel));
      await tester.pump();
      final confirm = find.byWidgetPredicate(
        (widget) =>
            widget is AppButton &&
            widget.label == S.current.reportConfirmCancel,
      );
      expect(tester.widget<AppButton>(confirm).isLoading, isTrue);
      await tester.tap(confirm);
      expect(repository.cancellationCount, 1);
      await tester.tap(find.text(S.current.dashboardCancel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.reportStatus));
      await tester.pumpAndSettle();
      repository.cancellation.complete(
        Success(
          repository.pendingReport!.withStatus(ReportRequestStatus.cancelled),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ReportStatusFilterSheet), findsOneWidget);
      await tester.tap(find.text(S.current.dashboardCancel));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<AppRequestReportCard>(
              find.byType(AppRequestReportCard).first,
            )
            .statusLabel,
        S.current.reportStatusCancelled,
      );
      expect(tester.takeException(), isNull);
    },
  );
}

class DeferredCancellationRepository implements RequestReportsRepository {
  final adapter = MockRequestReportsRepository(
    now: () => DateTime.utc(2026, 10, 20, 4, 42),
  );
  final cancellation = Completer<Result<RequestReport>>();
  RequestReport? pendingReport;
  int cancellationCount = 0;

  @override
  Future<Result<RequestReportCatalog>> fetchReports() async {
    final result = await adapter.fetchReports();
    if (result case Success(:final data)) {
      pendingReport = data.reports.first;
    }
    return result;
  }

  @override
  Future<Result<RequestReport>> cancelRequest({
    required String trackingId,
    required String idempotencyKey,
  }) {
    cancellationCount++;
    return cancellation.future;
  }
}
