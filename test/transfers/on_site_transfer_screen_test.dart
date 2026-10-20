import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/router/app_router.dart';
import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:pishkhan_mobile/core/router/router_session.dart';
import 'package:pishkhan_mobile/features/transfers/data/repositories/mock_on_site_transfer_repository.dart';
import 'package:pishkhan_mobile/features/transfers/domain/repositories/on_site_transfer_repository.dart';
import 'package:pishkhan_mobile/features/transfers/presentation/on_site_transfer/screens/on_site_transfer_screen.dart';
import 'package:pishkhan_mobile/features/transfers/presentation/on_site_transfer/widgets/transfer_destination_sheet.dart';
import 'package:pishkhan_mobile/features/transfers/presentation/on_site_transfer/widgets/transfer_upload_sheet.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_transfer_destination_card.dart';

import '../deposits/certificate_test_support.dart';

void main() {
  setUpAll(loadCertificateFonts);
  setUp(() {
    getIt.registerSingleton<OnSiteTransferRepository>(
      MockOnSiteTransferRepository(now: () => DateTime.utc(2026, 10, 20, 8)),
    );
  });
  tearDown(() => getIt.reset());

  Future<void> captureTransfer(WidgetTester tester, String name) async {
    FocusManager.instance.primaryFocus?.unfocus();
    // SVG compilation runs in real isolates; let it finish before visual captures.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await tester.pumpAndSettle();
    await captureCertificate(tester, name);
  }

  Future<void> reachDestinations(WidgetTester tester) async {
    await tester.tap(find.text(S.current.issuanceDepositHint));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10.10009753.8').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      JalaliDateFormatter.format(
        DateTime.utc(2026, 10, 21),
        usePersianDigits: false,
      ),
    );
    await tester.pumpAndSettle();
    await captureTransfer(tester, 'onsite-source-filled');
    await tester.tap(find.text(S.current.issuanceNext));
    await tester.pumpAndSettle();
    await captureTransfer(tester, 'onsite-visit-empty');
    await tester.tap(find.text(S.current.transferAddressHint));
    await tester.pumpAndSettle();
    await tester.tap(find.text('خانه').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      JalaliDateFormatter.format(
        DateTime.utc(2026, 10, 20),
        usePersianDigits: false,
      ),
    );
    await tester.pumpAndSettle();
    await captureTransfer(tester, 'onsite-visit-filled');
    await tester.tap(find.text(S.current.issuanceNext));
    await tester.pumpAndSettle();
  }

  Future<void> fillDestination(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).first, '2000000000');
    await tester.tap(find.text(S.current.transferMethodHint));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.current.transferSatna).last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).at(1),
      '820540102680020817909002',
    );
    await tester.tap(find.text(S.current.transferPurposeHint));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.current.transferSalary).last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '123456789');
    await tester.pumpAndSettle();
    await captureTransfer(tester, 'onsite-destination-filled');
    await tester.tap(find.text(S.current.transferSave));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'four stages use existing widgets, preserve destinations and record a demo request',
    (tester) async {
      await mountCertificate(tester, const OnSiteTransferScreen());
      await captureTransfer(tester, 'onsite-source-empty');
      await reachDestinations(tester);
      await captureTransfer(tester, 'onsite-destinations-empty');
      await tester.tap(find.text(S.current.transferAddManual));
      await tester.pumpAndSettle();
      await captureTransfer(tester, 'onsite-destination-empty');
      expect(find.byType(TransferDestinationSheet), findsOneWidget);
      await fillDestination(tester);
      expect(find.byType(AppTransferDestinationCard), findsOneWidget);
      await captureTransfer(tester, 'onsite-destination-single');
      await tester.tap(find.text(S.current.transferAddNext));
      await tester.pumpAndSettle();
      await fillDestination(tester);
      expect(find.byType(AppTransferDestinationCard), findsNWidgets(2));
      await captureTransfer(tester, 'onsite-destination-multiple');
      await tester.tap(find.text(S.current.transferConfirmNext));
      await tester.pumpAndSettle();
      await captureTransfer(tester, 'onsite-confirmation');
      await tester.tap(find.byType(AppCheckbox));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.transferConfirmNext));
      await tester.pumpAndSettle();
      expect(find.textContaining('DEMO-TRANSFER-'), findsOneWidget);
      expect(
        find.textContaining(S.current.transferMockComplete),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'actual picker contract shows upload progress; Review advances to confirmation',
    (tester) async {
      const channel = MethodChannel('pishkhan/document_picker');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            channel,
            (_) async => <String, Object?>{
              'name': 'salary.xls',
              'bytes': Uint8List(100),
            },
          );
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      await mountCertificate(tester, const OnSiteTransferScreen());
      await reachDestinations(tester);
      await tester.tap(find.text(S.current.transferUploadExcel));
      await tester.pumpAndSettle();
      await captureTransfer(tester, 'onsite-upload-empty');
      await tester.tap(find.text(S.current.transferUploadAction));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('40%'), findsOneWidget);
      await captureTransfer(tester, 'onsite-upload-progress');
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('100%'), findsOneWidget);
      await captureTransfer(tester, 'onsite-upload-complete');
      await tester.tap(find.text(S.current.transferReview));
      await tester.pumpAndSettle();
      expect(find.byType(TransferUploadSheet), findsNothing);
      expect(find.text(S.current.transferConfirmationStep), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('system Back traverses stages then asks before exit', (
    tester,
  ) async {
    await mountCertificate(tester, const OnSiteTransferScreen());
    await reachDestinations(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text(S.current.transferVisitPrompt), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text(S.current.transferSourcePrompt), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text(S.current.flowExitTitle), findsOneWidget);
    await tester.tap(find.text(S.current.passwordStay));
    await tester.pumpAndSettle();
    expect(find.text(S.current.transferSourcePrompt), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('narrow layouts and Arabic/English localization remain usable', (
    tester,
  ) async {
    for (final locale in ['en', 'ar']) {
      await mountCertificate(
        tester,
        const OnSiteTransferScreen(),
        size: const Size(320, 700),
        locale: locale,
        scale: 1.3,
      );
      expect(find.text(S.current.transferSourcePrompt), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
  test('on-site route is independent and retained through authentication return validation', () {
    final session = RouterSession();
    final router = createAppRouter(session: session);
    addTearDown(() {
      router.dispose();
      session.dispose();
    });
    expect(
      validatedReturnLocation(AppRoutes.onSiteTransfer),
      AppRoutes.onSiteTransfer,
    );
    expect(AppRoutes.onSiteTransfer.startsWith('/transfers/'), isTrue);
  });
}
