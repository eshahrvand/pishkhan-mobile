import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/main.dart';

void main() {
  testWidgets('shared component preview opens and closes the drawer', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('منوی کناری'), findsOneWidget);
    expect(find.text('منو: باز'), findsOneWidget);

    await tester.tap(find.byKey(const Key('app_drawer_close')));
    await tester.pump(const Duration(milliseconds: 240));
    expect(find.text('منو: بسته'), findsOneWidget);

    await tester.tap(find.byKey(const Key('preview_open_drawer')));
    await tester.pump(const Duration(milliseconds: 240));
    expect(find.text('منو: باز'), findsOneWidget);
  });
}
