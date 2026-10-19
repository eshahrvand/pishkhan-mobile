import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/shared/postal/cubit/cheque_postal_cubit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/flow/service_registry.dart';
import 'package:pishkhan_mobile/features/cheque/domain/entities/cheque_clearance.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/clearance/cubit/cheque_clearance_cubit.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/clearance/screens/cheque_clearance_screen.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/clearance/widgets/cheque_clearance_form.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/clearance/widgets/cheque_clearance_receipt_dialog.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/shared/postal/widgets/cheque_postal_results.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/shared/postal/widgets/cheque_postal_sheet.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../support/router_test_app.dart';

void main() {
  String? sharedText;
  setUpAll(() async {
    final loader = FontLoader(AppTypography.defaultFontFamily);
    for (final weight in ['Regular']) {
      loader.addFont(
        rootBundle.load(
          'packages/avp_ui/assets/fonts/IRANYekanXFaNum-$weight.ttf',
        ),
      );
    }
    await loader.load();
  });
  setUp(() {
    configureDependencies();
    sharedText = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('pishkhan/platform_share'),
          (call) async {
            expect(call.method, 'shareText');
            sharedText = call.arguments as String;
            return null;
          },
        );
  });
  tearDown(() async {
    await getIt.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('pishkhan/platform_share'),
          null,
        );
  });

  Finder button(String label) => find.byWidgetPredicate(
    (widget) => widget is AppButton && widget.label == label,
  );
  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> mount(
    WidgetTester tester, {
    Size size = const Size(375, 812),
    double scale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      TestRouterApp(
        locale: const Locale('fa'),
        supportedLocales: S.delegate.supportedLocales,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        theme: AppTheme.light(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: AppButton(
                label: 'Open cheque',
                onPressed: () =>
                    ServiceRegistry.openCardService(context, 'cheque-clear'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tap(tester, button('Open cheque'));
    expect(find.byType(ChequeClearanceScreen), findsOneWidget);
  }

  Future<void> choose<T>(WidgetTester tester, String label) async {
    await tap(tester, find.byType(AppSelect<T>));
    await tap(tester, find.text(label).last);
  }

  Future<void> enter(WidgetTester tester, String hint, String value) async {
    final field = find.descendant(
      of: find.byWidgetPredicate(
        (widget) => widget is AppTextField && widget.hintText == hint,
      ),
      matching: find.byType(TextField),
    );
    await tester.ensureVisible(field);
    await tester.enterText(field, value);
    await tester.pumpAndSettle();
  }

  Future<void> fill(
    WidgetTester tester,
    String reason, {
    String number = '۱۲۳/۱۲۳۴۵۶',
  }) async {
    await choose<ChequeDeposit>(tester, '10.1234567.2');
    await enter(tester, S.current.chequeNumberHint, number);
    await choose<ChequeClearanceReason>(tester, reason);
  }

  ChequeClearanceCubit cubit(WidgetTester tester) => tester
      .element(find.byType(ChequeClearanceForm))
      .read<ChequeClearanceCubit>();

  testWidgets(
    'initial form and both non-postal reasons use the central route',
    (tester) async {
      await mount(tester);
      expect(
        tester.widget<AppButton>(button(S.current.chequeSubmit)).onPressed,
        isNull,
      );
      expect(find.text(S.current.chequeNoPostRequired), findsNothing);
      await fill(tester, S.current.chequeReasonDepositAndBlock);
      expect(cubit(tester).state.chequeNumber, '123/123456');
      expect(find.text(S.current.chequeNoPostRequired), findsOneWidget);
      expect(find.text(S.current.chequePostalAction), findsNothing);
      await choose<ChequeClearanceReason>(
        tester,
        S.current.chequeReasonOlderThanThreeYears,
      );
      await tap(tester, find.byType(AppCheckbox));
      expect(
        tester.widget<AppButton>(button(S.current.chequeSubmit)).onPressed,
        isNotNull,
      );
      await tap(tester, button(S.current.chequeSubmit));
      expect(find.byType(ChequeClearanceReceiptDialog), findsOneWidget);
      expect(find.textContaining('DEMO-CHEQUE-'), findsOneWidget);
      await tap(tester, button(S.current.backLabel));
      expect(find.byType(ChequeClearanceScreen), findsNothing);
      expect(button('Open cheque'), findsOneWidget);
    },
  );

  testWidgets(
    'unknown cheque displays the inline error after submit and recovers on edit',
    (tester) async {
      await mount(tester);
      await fill(
        tester,
        S.current.chequeReasonOlderThanThreeYears,
        number: '۹۹۹/۹۹۹۹۹۹',
      );
      expect(find.text(S.current.chequeNumberNotFound), findsNothing);
      await tap(tester, find.byType(AppCheckbox));
      await tap(tester, button(S.current.chequeSubmit));
      expect(find.text(S.current.chequeNumberNotFound), findsOneWidget);
      expect(
        tester.widget<AppButton>(button(S.current.chequeSubmit)).onPressed,
        isNull,
      );
      await enter(tester, S.current.chequeNumberHint, '۱۲۳/۱۲۳۴۵۶');
      expect(find.text(S.current.chequeNumberNotFound), findsNothing);
      expect(
        tester.widget<AppButton>(button(S.current.chequeSubmit)).onPressed,
        isNotNull,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'postal documents and the judicial letter field follow reason changes',
    (tester) async {
      await mount(tester);
      await fill(tester, S.current.chequeReasonOriginal);
      expect(
        find.text('•  ${S.current.chequeDocumentOriginal}'),
        findsOneWidget,
      );
      expect(find.text(S.current.chequeMailingAddressTitle), findsOneWidget);
      await choose<ChequeClearanceReason>(
        tester,
        S.current.chequeReasonPartialPayment,
      );
      expect(
        find.textContaining('•  ${S.current.chequeReasonPartialPayment}'),
        findsOneWidget,
      );
      await choose<ChequeClearanceReason>(
        tester,
        S.current.chequeReasonJudicial,
      );
      expect(find.text(S.current.chequeJudicialNumber), findsOneWidget);
      await tap(tester, find.byType(AppCheckbox));
      expect(
        tester.widget<AppButton>(button(S.current.chequeSubmit)).onPressed,
        isNull,
      );
      await enter(tester, S.current.chequeJudicialNumberHint, '۱۰۰۳۴۵۶۷۸');
      expect(
        tester.widget<AppButton>(button(S.current.chequeSubmit)).onPressed,
        isNotNull,
      );
      await choose<ChequeClearanceReason>(
        tester,
        S.current.chequeReasonOriginal,
      );
      expect(find.text(S.current.chequeJudicialNumber), findsNothing);
      expect(cubit(tester).state.judicialLetterNumber, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'consent links and terms report unavailable content without replacing form state',
    (tester) async {
      await mount(tester);
      await fill(tester, S.current.chequeReasonConsent);
      for (final label in [
        S.current.chequeConsentConditions,
        S.current.chequeDownloadSample,
      ]) {
        await tap(tester, button(label));
        expect(find.text(S.current.chequeContentUnavailable), findsOneWidget);
        ScaffoldMessenger.of(tester.element(find.byType(ChequeClearanceForm)))
            .removeCurrentSnackBar();
        await tester.pumpAndSettle();
      }
      await tap(tester, find.text(S.current.chequeTerms));
      expect(find.text(S.current.chequeContentUnavailable), findsOneWidget);
      expect(
        cubit(tester).state.reason,
        ChequeClearanceReason.notarizedConsent,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'postal sheets search, share service addresses, handle back and reset city',
    (tester) async {
      await mount(tester);
      await fill(tester, S.current.chequeReasonOriginal);
      await tap(tester, find.text(S.current.chequePostalAction));
      expect(find.byType(ChequePostalSheet), findsOneWidget);
      expect(
        tester
            .widget<AppButton>(button(S.current.chequePostalSearch))
            .onPressed,
        isNull,
      );
      await choose<PostalProvince>(tester, 'تهران');
      await choose<PostalCity>(tester, 'منطقه پستی شمال شرق');
      await tap(tester, button(S.current.chequePostalSearch));
      expect(find.byType(ChequePostalResults), findsOneWidget);
      expect(find.textContaining('کارگاه نیاوران'), findsOneWidget);
      await tap(tester, button(S.current.chequePostalShare));
      expect(sharedText, contains('کارگاه نیاوران'));
      expect(sharedText, contains('کارگاه ایرانشهر'));
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(ChequePostalResults), findsNothing);
      await choose<PostalProvince>(tester, 'اصفهان');
      expect(
        tester
            .element(find.byType(ChequePostalSheet))
            .read<ChequePostalCubit>()
            .state
            .city,
        isNull,
      );
      expect(
        tester
            .widget<AppButton>(button(S.current.chequePostalSearch))
            .onPressed,
        isNull,
      );
      await choose<PostalCity>(tester, 'اصفهان');
      await tap(tester, button(S.current.chequePostalSearch));
      expect(find.text(S.current.chequePostalEmpty), findsOneWidget);
      expect(button(S.current.chequePostalShare), findsNothing);
      await tap(tester, button(S.current.chequePostalSearchAgain));
      await tap(tester, find.byKey(const Key('app_bottom_sheet_left_action')));
      expect(find.byType(ChequePostalSheet), findsNothing);
      expect(cubit(tester).state.reason, ChequeClearanceReason.originalCheque);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'small viewport and enlarged text keep long consent content and footer reachable',
    (tester) async {
      await mount(tester, size: const Size(320, 640), scale: 1.4);
      await fill(tester, S.current.chequeReasonConsent);
      await tap(tester, find.text(S.current.chequePostalAction));
      await choose<PostalProvince>(tester, 'تهران');
      await choose<PostalCity>(tester, 'منطقه پستی شمال شرق');
      await tap(tester, button(S.current.chequePostalSearch));
      expect(find.byType(ChequePostalResults), findsOneWidget);
      await tap(tester, find.byKey(const Key('app_bottom_sheet_left_action')));
      await tap(tester, find.byType(AppCheckbox));
      expect(
        tester.widget<AppButton>(button(S.current.chequeSubmit)).onPressed,
        isNotNull,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
