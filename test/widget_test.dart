import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/main.dart';

void main() {
  testWidgets('auth flow changes between login and change-phone states', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('ورود به پیشخوان مجازی'), findsOneWidget);
    expect(find.text('درخواست ارسال رمز'), findsOneWidget);

    final changePhoneAction = find.byKey(const Key('change_phone_button'));
    final nationalIdField = find.byKey(
      const ValueKey<String>('login-national-id'),
    );
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
    expect(find.text('درخواست کد دو عاملی'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('بستن'));
    await tester.pumpAndSettle();

    expect(find.text('ورود به پیشخوان مجازی'), findsOneWidget);
  });
}
