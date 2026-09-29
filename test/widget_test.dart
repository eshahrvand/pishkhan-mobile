import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/main.dart';

void main() {
  testWidgets('auth flow changes between login and change-phone states', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('ورود به پیشخوان مجازی'), findsOneWidget);
    expect(find.text('درخواست ارسال رمز'), findsOneWidget);

    await tester.tap(find.text('تغییر شماره همراه'));
    await tester.pumpAndSettle();

    expect(find.text('تغییر شماره همراه'), findsOneWidget);
    expect(find.text('درخواست کد دو عاملی'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('بستن'));
    await tester.pumpAndSettle();

    expect(find.text('ورود به پیشخوان مجازی'), findsOneWidget);
  });
}
