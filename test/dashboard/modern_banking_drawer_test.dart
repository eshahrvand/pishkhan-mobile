import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/screens/dashboard_screen.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/widgets/dashboard_drawer.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_drawer_group.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';
import 'package:pishkhan_mobile/features/modern_banking/domain/entities/mobile_bank.dart';
import 'package:pishkhan_mobile/features/modern_banking/presentation/deactivation/screens/mobile_bank_deactivation_screen.dart';
import 'package:pishkhan_mobile/features/modern_banking/presentation/mobile_bank/screens/mobile_bank_screen.dart';
import 'package:pishkhan_mobile/features/modern_banking/presentation/password_guide/screens/mobile_bank_guide_screen.dart';
import 'package:pishkhan_mobile/features/modern_banking/presentation/transfer_limits/screens/mobile_bank_limits_screen.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_drawer.dart';

import '../deposits/certificate_test_support.dart';

void main() {
  setUp(configureDependencies);
  tearDown(() => getIt.reset());
  setUpAll(loadCertificateFonts);

  Future<void> openDrawer(WidgetTester tester) async {
    tester.binding.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(
      tester.binding.platformDispatcher.clearAccessibilityFeaturesTestValue,
    );
    await mountCertificate(tester, const DashboardScreen());
    await tester.tap(find.byKey(const Key('dashboard_menu_button')));
    await tester.pumpAndSettle();
  }

  const destinations = [
    (DashboardService.mobileBank, AppRoutes.mobileBank, MobileBankScreen),
    (
      DashboardService.mobileBankPasswordRecovery,
      AppRoutes.mobileBankPasswordRecovery,
      MobileBankScreen,
    ),
    (
      DashboardService.mobileBankPasswordGuide,
      AppRoutes.mobileBankPasswordGuide,
      MobileBankGuideScreen,
    ),
    (
      DashboardService.mobileBankTransferLimits,
      AppRoutes.mobileBankTransferLimits,
      MobileBankLimitsScreen,
    ),
    (
      DashboardService.mobileBankDeactivation,
      AppRoutes.mobileBankDeactivation,
      MobileBankDeactivationScreen,
    ),
  ];

  for (final (service, route, screenType) in destinations) {
    testWidgets('modern drawer opens ${service.id}', (tester) async {
      await openDrawer(tester);
      final router = GoRouter.of(tester.element(find.byType(DashboardDrawer)));
      await tester.tap(
        find.descendant(
          of: find.byType(AppDrawer),
          matching: find.text(S.current.dashboardModernBanking),
        ),
      );
      await tester.pumpAndSettle();

      final group = tester
          .widget<AppDrawer>(find.byType(AppDrawer))
          .items
          .whereType<DashboardDrawerItem>()
          .singleWhere((item) => item.section == DashboardDrawerSection.modern);
      expect(group.children.map((item) => item.label), [
        S.current.modernActivate,
        S.current.modernRecoveryTitle,
        S.current.passwordChange,
        S.current.modernLimitsTitle,
        S.current.modernDeactivationTitle,
      ]);
      expect(
        group.children.map((item) => item.id),
        isNot(contains('modern-phone')),
      );
      expect(
        group.children.map((item) => item.id),
        isNot(contains('modern-internet')),
      );
      if (service == DashboardService.mobileBank) {
        await captureCertificate(tester, 'modern-banking-drawer');
      }

      final destination = find.descendant(
        of: find.byType(AppDrawer),
        matching: find.text(dashboardDrawerServiceLabel(service)),
      );
      await tester.ensureVisible(destination);
      await tester.tap(destination);
      await tester.pumpAndSettle();
      expect(find.byType(AppDrawer), findsNothing);
      expect(find.byType(screenType), findsOneWidget);
      expect(
        router.routerDelegate.currentConfiguration.last.matchedLocation,
        route,
      );
      if (service == DashboardService.mobileBankPasswordRecovery) {
        expect(
          tester
              .widget<MobileBankScreen>(find.byType(MobileBankScreen))
              .operation,
          MobileBankOperation.passwordRecovery,
        );
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets(
    'drawer search finds implemented modern services and clears correctly',
    (tester) async {
      await openDrawer(tester);
      final search = find.descendant(
        of: find.byType(AppSearchField),
        matching: find.byType(TextField),
      );
      await tester.enterText(search, 'فراموشي');
      await tester.pumpAndSettle();
      final drawer = tester.widget<AppDrawer>(find.byType(AppDrawer));
      expect(drawer.items.single.id, 'modern');
      expect(
        drawer.items.single.children.single.id,
        'modern-mobile-password-recovery',
      );
      expect(find.text(S.current.modernRecoveryTitle), findsOneWidget);

      await tester.enterText(search, S.current.dashboardPhoneBank);
      await tester.pumpAndSettle();
      expect(tester.widget<AppDrawer>(find.byType(AppDrawer)).items, isEmpty);
      await tester.enterText(search, '');
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<AppDrawer>(find.byType(AppDrawer))
            .items
            .singleWhere((item) => item.id == 'modern')
            .children
            .length,
        5,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
