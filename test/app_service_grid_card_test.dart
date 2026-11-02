import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_grid_card.dart';

void main() {
  Widget buildSubject({
    required AppServiceGridCardType type,
    VoidCallback? onTap,
    bool enabled = true,
  }) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SizedBox(
          width: 343,
          child: AppServiceGridCard(
            title: type == AppServiceGridCardType.service
                ? 'خدمات'
                : 'دسترسی سریع',
            type: type,
            items: [
              AppServiceGridItem(
                id: 'statement',
                label: 'صورتحساب، معدل موجودی',
                icon: const Icon(Icons.person_outline),
                onTap: onTap,
                enabled: enabled,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  for (final width in [320.0, 375.0]) {
    testWidgets(
      'microservices align incomplete rows with columns at width $width',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: SizedBox(
                width: width,
                child: AppServiceGridCard(
                  title: 'Services',
                  items: [
                    for (var index = 0; index < (width == 320 ? 5 : 6); index++)
                      AppServiceGridItem(
                        id: 'service-$index',
                        label: 'Service $index',
                        icon: const Icon(Icons.person_outline),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
        final items = find.byType(AppServiceGridItemView);
        final grid = tester.getRect(
          find.ancestor(of: items.first, matching: find.byType(Row)).first,
        );
        final firstRow = [
          for (var index = 0; index < items.evaluate().length; index++)
            if ((tester.getRect(items.at(index)).top -
                        tester.getRect(items.first).top)
                    .abs() <
                .01)
              tester.getRect(items.at(index)),
        ]..sort((a, b) => a.left.compareTo(b.left));
        expect(firstRow, hasLength(width == 320 ? 3 : 4));
        expect(firstRow.first.left, closeTo(grid.left, .01));
        expect(firstRow.last.right, closeTo(grid.right, .01));
        final gap = firstRow[1].left - firstRow[0].right;
        for (var index = 2; index < firstRow.length; index++) {
          expect(
            firstRow[index].left - firstRow[index - 1].right,
            closeTo(gap, .01),
          );
        }
        final columns = firstRow.length;
        for (var index = columns; index < items.evaluate().length; index++) {
          expect(
            tester.getRect(items.at(index)).left,
            closeTo(tester.getRect(items.at(index % columns)).left, .01),
          );
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('reports selected service item', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      buildSubject(
        type: AppServiceGridCardType.service,
        onTap: () => tapped = true,
      ),
    );

    await tester.tap(find.text('صورتحساب، معدل موجودی'));
    expect(tapped, isTrue);
  });

  testWidgets('renders the quick-access variant in RTL', (tester) async {
    await tester.pumpWidget(buildSubject(type: AppServiceGridCardType.quick));

    expect(find.text('دسترسی سریع'), findsOneWidget);
  });

  testWidgets('service appearance stays unchanged while hovered and pressed', (
    tester,
  ) async {
    // Test-only key identifies the captured surface, not an app interaction.
    const captureKey = Key('service_capture');
    var taps = 0;
    await tester.pumpWidget(
      RepaintBoundary(
        key: captureKey,
        child: buildSubject(
          type: AppServiceGridCardType.service,
          onTap: () => taps++,
        ),
      ),
    );
    await tester.pumpAndSettle();
    Future<List<int>> pixels() async => (await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(captureKey),
      );
      final image = await boundary.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      image.dispose();
      return bytes!.buffer.asUint8List().toList();
    }))!;

    final before = await pixels();
    final center = tester.getCenter(find.byType(AppServiceGridItemView));
    final touch = await tester.startGesture(center);
    await tester.pump(const Duration(milliseconds: 200));
    expect(await pixels(), before);
    await touch.up();
    await tester.pumpAndSettle();
    expect(taps, 1);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(center);
    await tester.pumpAndSettle();
    expect(await pixels(), before);
    await mouse.down(center);
    await tester.pump(const Duration(milliseconds: 200));
    expect(await pixels(), before);
    await mouse.up();
    await tester.pumpAndSettle();
    expect(taps, 2);
  });

  testWidgets('service handles touch and blocks disabled taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      buildSubject(type: AppServiceGridCardType.service, onTap: () => taps++),
    );
    await tester.tap(find.byType(AppServiceGridItemView));
    expect(taps, 1);
    await tester.pumpWidget(
      buildSubject(
        type: AppServiceGridCardType.service,
        onTap: () => taps++,
        enabled: false,
      ),
    );
    await tester.tap(find.byType(AppServiceGridItemView));
    expect(taps, 1);
  });

  testWidgets('aligns icon cards independently from label line count', (
    tester,
  ) async {
    const items = [
      AppServiceGridItem(
        id: 'one-line',
        label: 'معرفی وام',
        icon: Icon(Icons.calculate_outlined),
      ),
      AppServiceGridItem(
        id: 'two-lines',
        label: 'تغییر سپرده جهت کسر اقساط',
        icon: Icon(Icons.account_balance_outlined),
      ),
      AppServiceGridItem(
        id: 'short',
        label: 'برآورد وام',
        icon: Icon(Icons.wallet_outlined),
      ),
      AppServiceGridItem(
        id: 'long',
        label: 'تجمیع اعتبار سپرده',
        icon: Icon(Icons.more_horiz),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(
              width: 328,
              child: AppServiceGridCard(title: 'خدمات وام', items: items),
            ),
          ),
        ),
      ),
    );

    final iconTopPositions = items
        .map(
          (item) => tester
              .getTopLeft(find.byKey(Key('app_service_grid_icon_${item.id}')))
              .dy,
        )
        .toSet();
    expect(iconTopPositions, hasLength(1));
  });
}
