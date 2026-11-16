import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/flow/service_registry.dart';
import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:pishkhan_mobile/features/cards/domain/entities/card_restriction.dart';
import 'package:pishkhan_mobile/features/cards/domain/entities/card_service_data.dart';
import 'package:pishkhan_mobile/features/cards/presentation/card_restriction/cubit/card_restriction_cubit.dart';
import 'package:pishkhan_mobile/features/cards/presentation/card_restriction/screens/card_restriction_screen.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_decision_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/shared/widgets/deposit_request_footer.dart';

import '../../support/router_test_app.dart';
import '../../support/snackbar_test_support.dart';
import 'card_restriction_test_support.dart';

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
  final preview =
      GlobalKey(); // Test-only boundary for exported visual evidence.

  Future<void> mount(
    WidgetTester tester,
    Widget screen, {
    Size size = const Size(375, 812),
    bool capture = false,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 40);
    tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 40);
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
          data: MediaQuery.of(context).copyWith(
            padding: const EdgeInsets.only(top: 24, bottom: 40),
            viewPadding: const EdgeInsets.only(top: 24, bottom: 40),
            textScaler: TextScaler.linear(textScale),
            disableAnimations: true,
          ),
          child: RepaintBoundary(key: capture ? preview : null, child: child!),
        ),
        home: screen,
      ),
    );
    await tester.pumpAndSettle();
  }

  CardRestrictionCubit cubit(WidgetTester tester) =>
      tester.element(find.byType(AppTopBar)).read<CardRestrictionCubit>();
  void fill(CardRestrictionCubit cubit) {
    cubit.selectCard(cubit.state.catalog!.cards.first);
    cubit.selectReason(cubit.state.catalog!.reasons.first);
    cubit.updateDescription('شخصی');
    cubit.updateTermsAcceptance(true);
  }

  Finder submit() => find.descendant(
    of: find.byType(DepositRequestFooter),
    matching: find.byType(AppButton),
  );
  Future<void> capture(WidgetTester tester, String name) async {
    // Let the package's SVG compilation isolates complete before exporting.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 250)),
    );
    await tester.pumpAndSettle();
    final boundary =
        preview.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final warm = await boundary.toImage(pixelRatio: 1);
      warm.dispose();
      final image = await boundary.toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final directory = Directory('build/previews/card_restriction');
      await directory.create(recursive: true);
      await File('${directory.path}/$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  testWidgets(
    'Figma empty/filled block and confirmation; dismissal never sends request',
    (tester) async {
      final repository = ControlledCardRestrictionsRepository();
      installRestrictionsRepository(repository);
      await mount(
        tester,
        const CardRestrictionScreen(operation: CardRestrictionOperation.block),
        size: const Size(375, 812),
        capture: true,
      );
      expect(tester.widget<AppButton>(submit()).isActive, isFalse);
      await capture(tester, 'block_empty');
      tester.view.physicalSize = const Size(375, 852);
      await tester.pumpAndSettle();
      // Use the actual package selection UI for the card and reason fields.
      await tester.tap(find.byType(AppSelect<RestrictionCard>));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('5041 7212').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AppSelect<CardRestrictionReason>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.cardRestrictionLost).last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'شخصی');
      tester.testTextInput.hide();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AppCheckbox));
      await tester.pumpAndSettle();
      expect(cubit(tester).state.canSubmit, isTrue);
      await capture(tester, 'block_filled');
      tester.view.physicalSize = const Size(375, 812);
      await tester.pumpAndSettle();
      await tester.tap(submit());
      await tester.pumpAndSettle();
      expect(find.byType(AppDecisionSheet), findsOneWidget);
      await capture(tester, 'block_confirmation');
      await tester.tap(find.text(S.current.dashboardCancel));
      await tester.pumpAndSettle();
      expect(repository.requests, isEmpty);
      await tester.tap(submit());
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 130));
      await tester.pumpAndSettle();
      expect(repository.requests, isEmpty);
      await tester.tap(submit());
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.cardBlockConfirm));
      await tester.pumpAndSettle();
      expect(repository.requests, hasLength(1));
      expect(find.text(S.current.cardServiceMockComplete), findsOneWidget);
      expect(find.byType(AppSelect<RestrictionCard>), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'unblock details and direct submit match the two reference states',
    (tester) async {
      await mount(
        tester,
        const CardRestrictionScreen(
          operation: CardRestrictionOperation.unblock,
        ),
        size: const Size(375, 812),
        capture: true,
      );
      await capture(tester, 'unblock_empty');
      tester.view.physicalSize = const Size(375, 986);
      await tester.pumpAndSettle();
      fill(cubit(tester));
      cubit(tester).selectReason(CardRestrictionReason.depositManagement);
      cubit(tester).updateTermsAcceptance(true);
      await tester.pumpAndSettle();
      expect(find.text(S.current.depositBlockedDate), findsOneWidget);
      await capture(tester, 'unblock_filled');
      await tester.tap(submit());
      await tester.pumpAndSettle();
      expect(find.byType(AppDecisionSheet), findsNothing);
      expect(find.text(S.current.cardServiceMockComplete), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'pending submission disables editing, repeated taps and both Back controls',
    (tester) async {
      final repository = ControlledCardRestrictionsRepository()
        ..pendingSubmission = Completer<Result<CardServiceReceipt>>();
      installRestrictionsRepository(repository);
      await mount(
        tester,
        const CardRestrictionScreen(
          operation: CardRestrictionOperation.unblock,
        ),
      );
      fill(cubit(tester));
      await tester.pumpAndSettle();
      await tester.tap(submit());
      await tester.pump();
      await tester.pump();
      expect(
        tester
            .widget<AppSelect<RestrictionCard>>(
              find.byType(AppSelect<RestrictionCard>),
            )
            .enabled,
        isFalse,
      );
      expect(tester.widget<AppButton>(submit()).isLoading, isTrue);
      await tester.tap(submit());
      await tester.tap(find.byTooltip(S.current.backLabel));
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(repository.requests, hasLength(1));
      expect(find.byType(CardRestrictionScreen), findsOneWidget);
      repository.pendingSubmission!.complete(
        const Err(DataFailure('network.connection')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AvpSnackBar), findsOneWidget);
      await dismissAvpSnackBar(tester);
      repository.pendingSubmission = null;
      repository.failSubmission = true;
      await tester.tap(submit());
      await tester.pumpAndSettle();
      expect(find.byType(AvpSnackBar), findsOneWidget);
      await dismissAvpSnackBar(tester);
      await tester.tap(find.text(S.current.issuanceTerms));
      await tester.pumpAndSettle();
      expect(find.text(S.current.issuanceTermsUnavailable), findsOneWidget);
      await dismissAvpSnackBar(tester);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('catalog retry and compact keyboard layout remain usable', (
    tester,
  ) async {
    final repository = ControlledCardRestrictionsRepository()
      ..failCatalog = true;
    installRestrictionsRepository(repository);
    await mount(
      tester,
      const CardRestrictionScreen(operation: CardRestrictionOperation.unblock),
      size: const Size(320, 640),
      textScale: 1.3,
    );
    await dismissAvpSnackBar(tester);
    repository.failCatalog = false;
    await tester.tap(find.text(S.current.dashboardRetry));
    await tester.pumpAndSettle();
    fill(cubit(tester));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(TextField));
    await tester.tap(find.byType(TextField));
    tester.view.viewInsets = const FakeViewPadding(bottom: 220);
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final operation in CardRestrictionOperation.values) {
    testWidgets(
      '${operation.name} catalog service opens real route with selected-card context',
      (tester) async {
        await mount(
          tester,
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => ServiceRegistry.openCardService(
                  context,
                  operation == CardRestrictionOperation.block
                      ? 'card-block'
                      : 'card-unblock',
                  initialCardNumber: operation == CardRestrictionOperation.block
                      ? '5041721223456787'
                      : '6207390713532072',
                ),
                child: const Text('open'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        expect(find.byType(CardRestrictionScreen), findsOneWidget);
        expect(cubit(tester).state.card, isNotNull);
        final router = GoRouter.of(
          tester.element(find.byType(CardRestrictionScreen)),
        );
        expect(
          router.routerDelegate.currentConfiguration.last.matchedLocation,
          operation == CardRestrictionOperation.block
              ? AppRoutes.blockCard
              : AppRoutes.unblockCard,
        );
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byType(CardRestrictionScreen), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
