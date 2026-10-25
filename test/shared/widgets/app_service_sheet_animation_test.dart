import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/cards/presentation/shared/card_service_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_sheet.dart';

void main() {
  for (final cardSheet in [false, true]) {
    testWidgets(
      'backdrop fades in place while only the panel slides ($cardSheet)',
      (tester) async {
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        String? result;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: Builder(
                builder: (context) => AppButton(
                  label: 'Open',
                  onPressed: () async {
                    if (cardSheet) {
                      result = await showCardServiceSheet<String>(
                        context,
                        (context) => SizedBox(
                          height: 180,
                          child: Center(
                            child: AppButton(
                              label: 'Confirm',
                              onPressed: () =>
                                  Navigator.of(context).pop('chosen'),
                            ),
                          ),
                        ),
                      );
                    } else {
                      result = await showAppServiceSheet<String>(
                        context,
                        Builder(
                          builder: (context) => SizedBox(
                            height: 180,
                            child: Center(
                              child: AppButton(
                                label: 'Confirm',
                                onPressed: () =>
                                    Navigator.of(context).pop('chosen'),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 40));
        final barrier = find.byType(AnimatedModalBarrier);
        final earlyBackdrop = tester.getRect(barrier);
        final earlyPanel = tester.getTopLeft(find.text('Confirm')).dy;
        final earlyColor = tester
            .widget<AnimatedModalBarrier>(barrier)
            .color
            .value!;
        expect(earlyBackdrop, const Rect.fromLTWH(0, 0, 375, 812));
        expect(earlyColor.a, greaterThan(0));
        expect(earlyColor.a, lessThan(.64));
        await tester.pumpAndSettle();
        expect(tester.getRect(barrier), earlyBackdrop);
        expect(
          tester.getTopLeft(find.text('Confirm')).dy,
          lessThan(earlyPanel),
        );
        expect(
          tester.widget<AnimatedModalBarrier>(barrier).color.value!.a,
          closeTo(.64, .01),
        );
        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();
        expect(result, 'chosen');
        expect(find.byType(BottomSheet), findsNothing);
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tapAt(const Offset(20, 80));
        await tester.pumpAndSettle();
        expect(result, isNull);
        expect(find.byType(BottomSheet), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
