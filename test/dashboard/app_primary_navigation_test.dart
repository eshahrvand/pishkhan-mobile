import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/app_primary_navigation.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

void main() {
  testWidgets('tab changes retain both icon renderers in fixed 20px slots', (
    tester,
  ) async {
    var selectedTab = AppPrimaryTab.dashboard;
    Widget subject() {
      return MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('fa'),
        supportedLocales: S.delegate.supportedLocales,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 343,
              child: AppPrimaryNavigation(
                selectedTab: selectedTab,
                onSelected: (tab) => selectedTab = tab,
              ),
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(subject());
    final icons = find.byType(AvpImage, skipOffstage: false);
    expect(icons, findsNWidgets(8));
    final initialElements = {
      for (final element in icons.evaluate())
        (element.widget as AvpImage).image!: element,
    };
    expect(initialElements, hasLength(8));

    for (final tab in [
      ...AppPrimaryTab.values,
      ...AppPrimaryTab.values.reversed,
      AppPrimaryTab.dashboard,
    ]) {
      await tester.tap(find.byType(InkWell).at(tab.index));
      expect(selectedTab, tab);
      await tester.pumpWidget(subject());

      // Both variants remain mounted even when their tab is not selected.
      expect(icons, findsNWidgets(8));
      for (final element in icons.evaluate()) {
        final icon = element.widget as AvpImage;
        expect(element, same(initialElements[icon.image]));
        expect(icon.width, 20);
        expect(icon.height, 20);
        expect(
          tester.getSize(find.byWidget(icon, skipOffstage: false)),
          const Size(20, 20),
        );
      }

      final visibleIcons = tester.widgetList<AvpImage>(find.byType(AvpImage));
      expect(visibleIcons, hasLength(4));
      expect(
        visibleIcons.where(
          (icon) =>
              icon.color ==
              AppTheme.light().extension<AppColorScheme>()!.textOnPrimary,
        ),
        hasLength(1),
      );
      final expectedPath = switch (tab) {
        AppPrimaryTab.dashboard => 'dashboard_nav_home.svg',
        AppPrimaryTab.cards => 'cards_nav_active.svg',
        AppPrimaryTab.deposits => 'dashboard_nav_deposit_active.svg',
        AppPrimaryTab.loans => 'dashboard_nav_loan_active.svg',
      };
      expect(
        visibleIcons.any((icon) => icon.image!.endsWith(expectedPath)),
        isTrue,
      );
      expect(tester.getSize(find.byType(InkWell).at(tab.index)).width, 87.75);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpAndSettle();
  });
}
