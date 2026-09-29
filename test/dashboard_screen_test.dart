import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/dashboard_screen.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_banner.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_grid_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_wallet_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_welcome_card.dart';

void main() {
  Widget subject(DashboardVariant variant) => MaterialApp(
    locale: const Locale('fa'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: AppTheme.light(),
    home: DashboardScreen(variant: variant),
  );

  testWidgets('reuses shared dashboard cards and renders exact sections', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(subject(DashboardVariant.withoutAds));

    expect(find.byType(AppWelcomeCard), findsOneWidget);
    expect(find.byType(AppWalletCard), findsOneWidget);
    expect(find.byType(AppServiceGridCard), findsNWidgets(4));
    expect(find.text('خدمات سپرده'), findsOneWidget);
    expect(find.text('خدمات کارت'), findsOneWidget);
    expect(find.text('خدمات وام'), findsOneWidget);
    expect(find.text('خدمات منتخب'), findsOneWidget);
    expect(find.byType(DashboardBanner), findsNothing);
    final serviceRows = [
      find.text('صورتحساب، معدل موجودی'),
      find.text('گواهی تمکن مالی'),
      find.text('معرفی نماینده'),
      find.text('تنظیمات ارسال پیامک'),
    ].map(tester.getTopLeft).map((offset) => offset.dy).toSet();
    expect(serviceRows, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('with-ads variant inserts both Figma banners', (tester) async {
    tester.view.physicalSize = const Size(375, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(subject(DashboardVariant.withAds));

    expect(find.byType(DashboardBanner), findsNWidgets(2));
    expect(
      tester.getSize(find.byKey(const Key('dashboard_header'))).height,
      64,
    );

    final slider = find.byKey(const Key('dashboard_banner_slider'));
    await tester.ensureVisible(slider);
    final viewportRect = tester.getRect(
      find.byKey(const Key('dashboard_banner_viewport')),
    );
    final cardRect = tester.getRect(
      find.byKey(const Key('dashboard_banner_card_0')),
    );
    expect(viewportRect.left, 0);
    expect(viewportRect.width, 375);
    expect(cardRect.left, 16);
    expect(cardRect.right, 359);

    await tester.drag(slider, const Offset(-300, 0));
    await tester.pumpAndSettle();

    final indicators = tester.widgetList<AnimatedContainer>(
      find.descendant(
        of: find.byKey(const Key('dashboard_carousel_indicators')),
        matching: find.byType(AnimatedContainer),
      ),
    );
    expect(indicators.map((item) => item.constraints?.maxWidth), [6, 14, 6, 6]);
  });
}
