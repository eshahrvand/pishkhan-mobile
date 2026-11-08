import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';
import 'package:pishkhan_mobile/shared/widgets/app_decision_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/flow_exit_sheet.dart';

Widget subject(Widget child, {String locale = 'fa', double scale = 1}) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: Locale(locale),
    supportedLocales: S.delegate.supportedLocales,
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: child,
  );
}

void main() {
  testWidgets(
    'root sheet returns explicit Stay/Exit without popping the nested flow',
    (tester) async {
      late NavigatorState nestedNavigator;
      bool? result;
      var completions = 0;
      await tester.pumpWidget(
        subject(
          Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (context) => Scaffold(
                body: Builder(
                  builder: (context) {
                    nestedNavigator = Navigator.of(context);
                    return AppButton(
                      label: 'open',
                      onPressed: () async {
                        result = await showFlowExitSheet(context);
                        completions++;
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(AppBottomSheetHeader), findsOneWidget);
      expect(find.byType(AppDecisionSheet), findsOneWidget);
      final context = tester.element(find.byType(FlowExitSheet));
      expect(
        Navigator.of(context),
        same(Navigator.of(context, rootNavigator: true)),
      );
      expect(Navigator.of(context), isNot(same(nestedNavigator)));
      await tester.tap(find.text(S.current.passwordStay));
      await tester.pumpAndSettle();
      expect(result, isFalse);
      expect(completions, 1);
      expect(find.byType(FlowExitSheet), findsNothing);
      expect(find.text('open'), findsOneWidget);
      expect(nestedNavigator.canPop(), isFalse);
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.passwordExit));
      await tester.pumpAndSettle();
      expect(result, isTrue);
      expect(completions, 2);
      expect(find.text('open'), findsOneWidget);
      expect(nestedNavigator.canPop(), isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  for (final systemBack in [true, false]) {
    testWidgets(
      '${systemBack ? 'Back' : 'outside dismissal'} returns null and preserves the caller',
      (tester) async {
        bool? result = true;
        var completed = false;
        await tester.pumpWidget(
          subject(
            Scaffold(
              body: Builder(
                builder: (context) => AppButton(
                  label: 'open',
                  onPressed: () async {
                    result = await showFlowExitSheet(
                      context,
                      title: 'عنوان دلخواه',
                    );
                    completed = true;
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        expect(find.text('عنوان دلخواه'), findsOneWidget);
        if (systemBack) {
          await tester.binding.handlePopRoute();
        } else {
          await tester.tapAt(const Offset(24, 80));
        }
        await tester.pumpAndSettle();
        expect(result, isNull);
        expect(completed, isTrue);
        expect(find.byType(FlowExitSheet), findsNothing);
        expect(find.text('open'), findsOneWidget);
      },
    );
  }

  testWidgets('other decision sheets retain their default null Cancel result', (
    tester,
  ) async {
    bool? result = true;
    await tester.pumpWidget(
      subject(
        Scaffold(
          body: Builder(
            builder: (context) => AppButton(
              label: 'open',
              onPressed: () async {
                result = await showAppServiceSheet<bool>(
                  context,
                  AppDecisionSheet(
                    message: 'تصمیم دیگر',
                    confirmLabel: 'تایید',
                    cancelLabel: 'انصراف',
                    onConfirm: () =>
                        Navigator.of(context, rootNavigator: true).pop(true),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('انصراف'));
    await tester.pumpAndSettle();
    expect(result, isNull);
    expect(find.byType(AppDecisionSheet), findsNothing);
  });

  for (final locale in ['fa', 'en', 'ar']) {
    testWidgets(
      '$locale compact/notched sheet keeps both decisions reachable with larger text',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
        tester.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          subject(
            Scaffold(
              body: SafeArea(
                child: Builder(
                  builder: (context) => AppButton(
                    label: 'open',
                    onPressed: () => showFlowExitSheet(context),
                  ),
                ),
              ),
            ),
            locale: locale,
            scale: 1.5,
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        final stay = find.widgetWithText(AppButton, S.current.passwordStay);
        final exit = find.widgetWithText(AppButton, S.current.passwordExit);
        await tester.ensureVisible(exit);
        await tester.pumpAndSettle();
        expect(tester.getRect(exit).bottom, lessThanOrEqualTo(606));
        expect(tester.getRect(stay).bottom, lessThanOrEqualTo(606));
        await tester.tap(stay);
        await tester.pumpAndSettle();
        expect(find.byType(FlowExitSheet), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
