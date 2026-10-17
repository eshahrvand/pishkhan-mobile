import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/features/cards/presentation/virtual_card_request/cubit/virtual_card_cubit.dart';
import 'package:pishkhan_mobile/features/cards/presentation/virtual_card_request/screens/virtual_card_request_screen.dart';
import 'package:pishkhan_mobile/features/cards/presentation/virtual_card_request/widgets/virtual_card_content.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

void main() {
  setUp(configureDependencies);
  tearDown(() => getIt.reset());

  for (final systemBack in [true, false]) {
    testWidgets(
      '${systemBack ? "system" : "header"} Back confirms edits and exits the blocked route once',
      (tester) async {
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const Scaffold(body: Text('Home')),
            ),
            GoRoute(
              path: '/virtual',
              builder: (_, _) => const VirtualCardRequestScreen(),
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
        router.push<void>('/virtual');
        await tester.pumpAndSettle();
        final cubit = tester
            .element(find.byType(VirtualCardContent))
            .read<VirtualCardCubit>();
        await cubit.countChanged('1');
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
        expect(cubit.state.countText, '1');
        await back();
        await tester.tap(find.text(S.current.passwordExit));
        await tester.pumpAndSettle();
        expect(find.text('Home'), findsOneWidget);
        expect(find.byType(VirtualCardRequestScreen), findsNothing);
        expect(cubit.isClosed, isTrue);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
