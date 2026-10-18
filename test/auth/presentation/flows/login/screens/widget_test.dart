import '../../../../../support/auth_ui_finders.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/main.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';

void main() {
  setUp(configureDependencies);
  tearDown(() => getIt.reset());
  testWidgets('auth flow changes between login and change-phone states', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('ورود با کد ملی'), findsOneWidget);
    expect(find.text('درخواست ارسال رمز'), findsOneWidget);

    final changePhoneAction = authControl(tester, 'change_phone_button');
    final nationalIdField = authControl(tester, 'login-national-id');
    expect(
      tester.getTopLeft(changePhoneAction).dx,
      tester.getTopLeft(nationalIdField).dx,
    );
    final actionText = tester.widget<Text>(
      find.descendant(of: changePhoneAction, matching: find.byType(Text)),
    );
    expect(actionText.style?.fontSize, 14);
    expect(actionText.style?.fontWeight, FontWeight.w600);
    expect(actionText.style?.height, 20 / 14);

    await tester.tap(find.text('تغییر شماره همراه'));
    await tester.pumpAndSettle();

    expect(find.text('تغییر شماره همراه'), findsOneWidget);
    expect(find.text('درخواست ارسال رمز'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('ورود با کد ملی'), findsOneWidget);
  });
  testWidgets('guest service tile opens the change-phone form', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(authControl(tester, 'auth_menu_button'));
    await tester.pumpAndSettle();

    expect(find.text('خدمات بدون نیاز به لاگین'), findsOneWidget);
    await tester.tap(find.text('تغییر تلفن همراه'));
    await tester.pumpAndSettle();

    expect(find.text('لیست خدمات'), findsNothing);
    expect(find.text('درخواست ارسال رمز'), findsOneWidget);
    expect(authControl(tester, 'changePhone-national-id'), findsOneWidget);
  });
}
