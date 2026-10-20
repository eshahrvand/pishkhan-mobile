import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/home_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/screens/dashboard_screen.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/widgets/dashboard_home_panel.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_tab.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_grid_card.dart';

import '../support/router_test_app.dart';

void main() {
  setUp(configureDependencies);
  tearDown(() => getIt.reset());
  setUpAll(() async {
    final loader = FontLoader(AppTypography.defaultFontFamily);
    loader.addFont(
      rootBundle.load(
        'packages/avp_ui/assets/fonts/IRANYekanXFaNum-Regular.ttf',
      ),
    );
    await loader.load();
  });

  final destinations = {
    AppPrimaryTab.cards: {
      'card-list': AppRoutes.cardList,
      'card-virtual-list': AppRoutes.cardList,
      'card-deposit': AppRoutes.changeCardDeposit,
      'card-reissue': AppRoutes.cardIssuance,
      'card-pin-second-set': AppRoutes.cardPasswords,
      'card-pin-second-change': AppRoutes.cardPasswords,
      'card-pin-second-forgot': AppRoutes.cardPasswords,
      'card-issue': AppRoutes.cardIssuance,
      'card-virtual': AppRoutes.virtualCardRequest,
      'card-expired-gift': AppRoutes.expiredGiftBalance,
    },
    AppPrimaryTab.deposits: {
      'deposit-list': AppRoutes.depositList,
      'deposit-statement': AppRoutes.averageBalance,
      'deposit-certificate': AppRoutes.financialCertificate,
      'deposit-representative': AppRoutes.introduceAgent,
      'deposit-representation-settings': AppRoutes.agentSettings,
      'deposit-block': AppRoutes.blockDeposit,
      'deposit-unblock': AppRoutes.unblockDeposit,
      'deposit-close-extras': AppRoutes.closeSurplusDeposits,
      'deposit-proxy': AppRoutes.proxyDeposit,
      'transfer-local': AppRoutes.onSiteTransfer,
      'card-issue': AppRoutes.cardIssuance,
      'card-virtual': AppRoutes.virtualCardRequest,
    },
  };

  for (final tab in destinations.entries) {
    testWidgets('${tab.key.name} tiles open every implemented service', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        TestRouterApp(
          theme: AppTheme.light(),
          locale: const Locale('fa'),
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: const DashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(DashboardHomePanel));
      final home = context.read<HomeCubit>();
      final router = GoRouter.of(context);
      home.selectTab(tab.key);
      if (tab.key == AppPrimaryTab.cards) {
        home.selectCard(home.state.visibleCards.last);
      }
      await tester.pumpAndSettle();

      for (final destination in tab.value.entries) {
        final tile = find.byWidgetPredicate(
          (widget) =>
              widget is AppServiceGridItemView &&
              widget.item.id ==
                  (tab.key == AppPrimaryTab.cards
                      ? destination.key
                      : 'deposits-${destination.key}'),
        );
        expect(tile, findsOneWidget, reason: destination.key);
        await tester.ensureVisible(tile);
        await tester.pumpAndSettle();
        await tester.tap(tile);
        await tester.pumpAndSettle();
        expect(
          router.routerDelegate.currentConfiguration.last.matchedLocation,
          destination.value,
          reason: destination.key,
        );
        expect(tester.takeException(), isNull, reason: destination.key);
        router.pop();
        await tester.pumpAndSettle();
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
