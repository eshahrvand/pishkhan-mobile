import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/address/presentation/editor/screens/address_editor_sheet.dart';
import 'package:pishkhan_mobile/features/address/presentation/editor/widgets/address_editor_form.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

void main() {
  testWidgets(
    'address editor uses the root navigator and approved edge-to-edge layout',
    (tester) async {
      tester.view.physicalSize = const Size(375, 600);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      tester.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
      addTearDown(tester.view.reset);
      late NavigatorState nestedNavigator;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('fa'),
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (context) => Scaffold(
                body: SafeArea(
                  child: Builder(
                    builder: (context) {
                      nestedNavigator = Navigator.of(context);
                      return AppButton(
                        label: S.current.issuanceAddAddress,
                        onPressed: () {
                          showAddressEditorSheet(context, includeContact: true);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();
      final sheetContext = tester.element(find.byType(AddressEditorForm));
      expect(
        Navigator.of(sheetContext),
        same(Navigator.of(sheetContext, rootNavigator: true)),
      );
      expect(Navigator.of(sheetContext), isNot(same(nestedNavigator)));
      // Owner decision, 2026-11-08: this sheet intentionally has no top safe area.
      expect(tester.getTopLeft(find.byType(AppBottomSheetHeader)).dy, 0);

      final saveButton = find.widgetWithText(
        AppButton,
        S.current.issuanceSaveAddress,
      );
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      final saveRect = tester.getRect(saveButton);
      expect(saveRect.top, greaterThanOrEqualTo(0));
      expect(saveRect.bottom, lessThanOrEqualTo(600 - 34));

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(AddressEditorForm), findsNothing);
      expect(find.text(S.current.issuanceAddAddress), findsOneWidget);
      expect(nestedNavigator.canPop(), isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
