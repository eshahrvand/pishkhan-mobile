import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/average_balance/cubit/average_balance_cubit.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/average_balance/screens/average_balance_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/financial_certificate/cubit/financial_certificate_cubit.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/financial_certificate/screens/financial_certificate_screen.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

void main() {
  setUp(configureDependencies);
  tearDown(() => getIt.reset());

  for (final financial in [false, true]) {
    for (final systemBack in [true, false]) {
      testWidgets(
        '${financial ? "financial" : "average"} ${systemBack ? "system" : "header"} Back preserves cancelled edits and confirms exit',
        (tester) async {
          final router = GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => const Scaffold(body: Text('Home')),
              ),
              GoRoute(
                path: '/certificate',
                builder: (_, _) => financial
                    ? const FinancialCertificateScreen()
                    : const AverageBalanceScreen(),
              ),
            ],
          );
          addTearDown(router.dispose);
          await tester.pumpWidget(
            MaterialApp.router(
              routerConfig: router,
              theme: AppTheme.light(),
              locale: const Locale('fa'),
              supportedLocales: S.delegate.supportedLocales,
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            ),
          );
          router.push<void>('/certificate');
          await tester.pumpAndSettle();
          final context = tester.element(find.byType(AppStepper));
          if (financial) {
            final cubit = context.read<FinancialCertificateCubit>();
            cubit.selectDeposit(cubit.state.catalog!.deposits.first);
          } else {
            final cubit = context.read<AverageBalanceCubit>();
            cubit.selectDeposit(cubit.state.catalog!.deposits.first);
          }
          await tester.pumpAndSettle();

          Future<void> back() async {
            if (systemBack) {
              await tester.binding.handlePopRoute();
            } else {
              await tester.tap(find.byTooltip(S.current.backLabel));
            }
            await tester.pumpAndSettle();
          }

          await back();
          expect(find.text(S.current.flowExitTitle), findsOneWidget);
          await tester.tap(find.text(S.current.passwordStay));
          await tester.pumpAndSettle();
          if (financial) {
            expect(
              context.read<FinancialCertificateCubit>().state.deposit,
              isNotNull,
            );
          } else {
            expect(
              context.read<AverageBalanceCubit>().state.deposit,
              isNotNull,
            );
          }
          await back();
          await tester.tap(find.text(S.current.passwordExit));
          await tester.pumpAndSettle();
          expect(find.text('Home'), findsOneWidget);
          expect(find.byType(AppStepper), findsNothing);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }
}
