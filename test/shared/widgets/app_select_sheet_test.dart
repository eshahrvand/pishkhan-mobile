import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../../deposits/certificate_test_support.dart';

void main() {
  setUpAll(loadCertificateFonts);

  Future<void> mount(
    WidgetTester tester,
    Widget child, {
    Size size = const Size(375, 812),
    double scale = 1,
    String locale = 'fa',
  }) {
    return mountCertificate(
      tester,
      Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [child],
            ),
          ),
        ),
      ),
      size: size,
      scale: scale,
      locale: locale,
    );
  }

  const options = [
    AppSelectOption(value: 1, label: 'گزینه اول'),
    AppSelectOption(
      value: 2,
      label: 'گزینه دوم',
      supportingText: 'توضیح گزینه',
      leading: Icon(Icons.account_balance),
    ),
    AppSelectOption(value: 3, label: 'غیرفعال', enabled: false),
  ];

  testWidgets('field keeps its geometry and opens a safe RTL bottom sheet', (
    tester,
  ) async {
    final changes = <int>[];
    await mount(
      tester,
      CertificateSelect<int>(
        label: 'انتخاب حساب',
        hint: 'انتخاب کنید',
        value: 1,
        options: options,
        onChanged: changes.add,
      ),
    );
    final fieldRect = tester.getRect(find.byType(AppSelect<int>));
    await tester.tap(find.byType(AppSelect<int>));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(AppSelectSheet<int>), findsOneWidget);
    final sheetRect = tester.getRect(find.byType(AppSelectSheet<int>));
    expect(sheetRect.bottom, closeTo(812 - 40, 1));
    expect(sheetRect.left, 0);
    expect(sheetRect.width, 375);
    expect(sheetRect.top, greaterThan(fieldRect.bottom));
    expect(
      Directionality.of(tester.element(find.byType(AppSelectSheet<int>))),
      TextDirection.rtl,
    );
    expect(
      tester
          .widget<AppSelectSheetItem<int>>(
            find.byType(AppSelectSheetItem<int>).first,
          )
          .selected,
      true,
    );
    expect(find.text('توضیح گزینه'), findsOneWidget);
    expect(find.byIcon(Icons.account_balance), findsOneWidget);
    await captureCertificate(tester, 'select-sheet-rtl');

    await tester.tap(find.text('غیرفعال'));
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    expect(find.byType(AppSelectSheet<int>), findsOneWidget);

    await tester.tap(find.text('گزینه دوم'));
    await tester.pumpAndSettle();
    expect(changes, [2]);
    expect(find.byType(BottomSheet), findsNothing);
    expect(tester.getRect(find.byType(AppSelect<int>)), fieldRect);
    expect(tester.takeException(), isNull);
  });

  testWidgets('outside dismissal and system Back preserve the selected value', (
    tester,
  ) async {
    final changes = <int>[];
    await mount(
      tester,
      CertificateSelect<int>(
        label: 'انتخاب حساب',
        hint: 'انتخاب کنید',
        value: 1,
        options: options,
        onChanged: changes.add,
      ),
    );
    await tester.tap(find.byType(AppSelect<int>));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(12, 100));
    await tester.pumpAndSettle();
    expect(find.byType(AppSelectSheet<int>), findsNothing);
    expect(changes, isEmpty);

    await tester.tap(find.byType(AppSelect<int>));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(AppSelectSheet<int>), findsNothing);
    expect(changes, isEmpty);
    expect(find.text('گزینه اول'), findsOneWidget);
  });

  testWidgets('disabled dropdown cannot open a sheet', (tester) async {
    final changes = <int>[];
    await mount(
      tester,
      CertificateSelect<int>(
        label: 'انتخاب حساب',
        hint: 'انتخاب کنید',
        enabled: false,
        options: options,
        onChanged: changes.add,
      ),
    );
    await tester.tap(find.byType(AppSelect<int>));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(changes, isEmpty);
  });

  testWidgets(
    'opening the sheet releases keyboard focus and keeps options usable',
    (tester) async {
      final changes = <int>[];
      await mount(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppTextField(value: '', hintText: 'جستجو'),
            const SizedBox(height: 20),
            CertificateSelect<int>(
              label: 'انتخاب حساب',
              hint: 'انتخاب کنید',
              options: options,
              onChanged: changes.add,
            ),
          ],
        ),
      );
      await tester.showKeyboard(find.byType(EditableText));
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AppSelect<int>));
      await tester.pumpAndSettle();
      expect(tester.testTextInput.isVisible, isFalse);
      tester.view.viewInsets = const FakeViewPadding();
      await tester.pumpAndSettle();
      await tester.tap(find.text('گزینه دوم'));
      await tester.pumpAndSettle();
      expect(changes, [2]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('long list scrolls on a narrow viewport with large Arabic text', (
    tester,
  ) async {
    final changes = <int>[];
    await mount(
      tester,
      CertificateSelect<int>(
        label: 'اختيار الحساب',
        hint: 'اختيار',
        options: [
          for (var index = 0; index < 60; index++)
            AppSelectOption(value: index, label: 'حساب رقم $index'),
        ],
        onChanged: changes.add,
      ),
      size: const Size(320, 568),
      scale: 1.4,
      locale: 'ar',
    );
    await tester.tap(find.byType(AppSelect<int>));
    await tester.pumpAndSettle();
    final menuScroll = find.descendant(
      of: find.byType(AppSelectSheet<int>),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('حساب رقم 59'),
      200,
      scrollable: menuScroll,
    );
    await captureCertificate(tester, 'select-sheet-narrow-arabic');
    await tester.tap(find.text('حساب رقم 59'));
    await tester.pumpAndSettle();
    expect(changes, [59]);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'dropdown inside another sheet closes only its own option sheet',
    (tester) async {
      final changes = <int>[];
      await mount(
        tester,
        Builder(
          builder: (context) {
            return AppButton(
              label: 'فتح المرشح',
              onPressed: () {
                showAppServiceSheet<void>(
                  context,
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: CertificateSelect<int>(
                      label: 'انتخاب حساب',
                      hint: 'انتخاب کنید',
                      options: options,
                      onChanged: changes.add,
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AppSelect<int>));
      await tester.pumpAndSettle();
      await captureCertificate(tester, 'select-sheet-nested');
      expect(find.byType(BottomSheet, skipOffstage: false), findsNWidgets(2));
      await tester.tap(find.text('گزینه دوم'));
      await tester.pumpAndSettle();
      expect(changes, [2]);
      expect(find.byType(AppSelectSheet<int>), findsNothing);
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(CertificateSelect<int>), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
