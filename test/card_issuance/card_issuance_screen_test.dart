import 'dart:io';
import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/features/cards/cards.dart';
import 'package:pishkhan_mobile/core/router/card_features_navigation.dart';
import 'package:pishkhan_mobile/features/card_issuance/card_issuance.dart';
import 'package:pishkhan_mobile/features/card_issuance/presentation/cubit/card_issuance_cubit.dart';
import 'package:pishkhan_mobile/shared/widgets/app_invoice.dart';
import 'package:pishkhan_mobile/shared/widgets/app_address_card.dart';

import 'card_issuance_cubit_test.dart' show ControlledIssuanceRepository;

import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

const preview = Key('issuance_preview');
void main() {
  setUpAll(() async {
    await rootBundle.load('packages/avp_ui/assets/icons/stepper-track.svg');
    await rootBundle.load('packages/avp_ui/assets/icons/stepper-progress.svg');
    final loader = FontLoader(AppTypography.defaultFontFamily);
    for (final face in ['Regular', 'Light', 'Medium', 'DemiBold', 'Bold']) {
      loader.addFont(
        rootBundle.load(
          'packages/avp_ui/assets/fonts/IRANYekanXFaNum-$face.ttf',
        ),
      );
    }
    await loader.load();
  });
  Widget subject(
    Widget child, {
    double scale = 1,
    Locale locale = const Locale('fa'),
  }) => RepaintBoundary(
    key: preview,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: Directionality(textDirection: TextDirection.rtl, child: child!),
      ),
      home: child,
    ),
  );
  Future<void> mount(
    WidgetTester tester,
    Widget screen, {
    Size size = const Size(375, 812),
    double scale = 1,
    Locale locale = const Locale('fa'),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 40);
    tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 40);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(subject(screen, scale: scale, locale: locale));
    await tester.pumpAndSettle();
  }

  CardIssuanceCubit controller(WidgetTester tester) => tester
      .widget<BlocConsumer<CardIssuanceCubit, CardIssuanceState>>(
        find.byType(BlocConsumer<CardIssuanceCubit, CardIssuanceState>),
      )
      .bloc!;
  void selection(CardIssuanceCubit c) {
    c.selectDeposit('deposit-1');
    c.selectType(IssuanceType.newNumber);
  }

  Future<void> tap(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester, String name) async {
    if (!const bool.fromEnvironment('UPDATE_ISSUANCE_PREVIEWS')) return;
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(preview),
      );
      final image = await boundary.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final directory = Directory('doc/card-issuance-review');
      await directory.create(recursive: true);
      await File('${directory.path}/$name.png')
          .writeAsBytes(data!.buffer.asUint8List());
      image.dispose();
    });
  }

  Future<void> verifyRing(WidgetTester tester, {required bool full}) async {
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(preview),
      );
      final image = await boundary.toImage();
      final raw = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final bytes = raw!.buffer.asUint8List();
      var blue = 0, gray = 0;
      for (var y = 104; y < 146; y++) {
        for (var x = 16; x < 58; x++) {
          final offset = (y * image.width + x) * 4;
          if (bytes[offset] == 78 &&
              bytes[offset + 1] == 91 &&
              bytes[offset + 2] == 166) {
            blue++;
          }
          if (bytes[offset] == 233 &&
              bytes[offset + 1] == 234 &&
              bytes[offset + 2] == 235) {
            gray++;
          }
        }
      }
      image.dispose();
      expect(
        blue,
        greaterThan(5),
        reason: 'The foreground ring must actually paint',
      );
      if (!full) {
        expect(gray, greaterThan(5), reason: 'The unfilled track must paint');
      }
    });
  }

  for (final last in [false, true]) {
    testWidgets('library Stepper ${last ? 'last' : 'first'} sample', (
      tester,
    ) async {
      await mount(
        tester,
        Scaffold(
          backgroundColor: AppColors.light.surfaceSubtle,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppStepper(
                currentStep: last ? 5 : 1,
                totalSteps: 5,
                progress: last ? 1 : .1,
                title: 'انتخاب سپرده و نوع صدور کارت',
                supportingText: last ? 'پایان' : 'بعدی: اطلاعات دریافت کارت',
              ),
            ),
          ),
        ),
        size: const Size(375, 160),
      );
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await save(
        tester,
        last ? 'stepper-library-last' : 'stepper-library-first',
      );
    });
  }
  for (final frame in [
    'selection-empty',
    'selection-filled',
    'no-physical',
    'address-empty',
    'address-filled',
    'confirmation-open',
    'confirmation-closed',
  ]) {
    testWidgets('renders $frame and its Figma geometry', (tester) async {
      final shadows = debugDisableShadows;
      debugDisableShadows = false;
      try {
        await mount(tester, const CardIssuanceScreen());
        final c = controller(tester);
        if (frame == 'selection-filled') selection(c);
        if (frame == 'no-physical') c.setNoPhysicalCard(true);
        if (frame.startsWith('address') || frame.startsWith('confirmation')) {
          selection(c);
          c.next();
        }
        if (frame == 'address-filled' || frame.startsWith('confirmation')) {
          c.selectAddress('home');
        }
        if (frame.startsWith('confirmation')) {
          c.next();
          c.acceptTerms(true);
        }
        if (frame == 'confirmation-closed') c.expandInvoice(false);
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        });
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          tester.getTopLeft(find.byKey(const Key('issuance_stepper'))).dy,
          104,
        );
        expect(
          tester.getSize(find.byKey(const Key('issuance_stepper'))).height,
          42,
        );
        expect(
          tester.getTopLeft(find.byKey(const Key('issuance_continue'))).dy,
          712,
        );
        expect(
          tester.getSize(find.byKey(const Key('issuance_continue'))).height,
          44,
        );
        if (frame.startsWith('confirmation')) {
          final invoice = tester.widget<AppInvoice>(find.byType(AppInvoice));
          expect(invoice.isExpanded, frame == 'confirmation-open');
          expect(invoice.backgroundColor, AppColors.light.surface);
          expect(invoice.totalAmount, '۱,۶۰۰,۰۰۰');
          expect(
            tester.getTopLeft(find.byKey(const Key('issuance_summary'))).dy,
            172,
          );
        } else if (frame.startsWith('address')) {
          expect(c.state.step, IssuanceStep.delivery);
          if (frame == 'address-filled') {
            expect(
              tester
                  .widget<AppAddressCard>(find.byType(AppAddressCard))
                  .variant,
              AppAddressCardVariant.delivery,
            );
          }
        } else {
          expect(find.byKey(const Key('issuance_deposit')), findsOneWidget);
          expect(find.byKey(const Key('issuance_type')), findsOneWidget);
          expect(
            tester
                    .widget<AppButton>(
                      find.byKey(const Key('issuance_continue')),
                    )
                    .onPressed ==
                null,
            frame != 'selection-filled',
          );
        }
        await verifyRing(tester, full: frame.startsWith('confirmation'));
        await save(tester, frame);
      } finally {
        debugDisableShadows = shadows;
      }
    });
  }
  testWidgets(
    'selectors, no-physical switch, terms and submission are connected',
    (tester) async {
      IssuanceReceipt? receipt;
      await mount(
        tester,
        CardIssuanceScreen(onCompleted: (value) => receipt = value),
      );
      await tap(tester, 'issuance_no_physical');
      expect(
        tester
            .widget<AppButton>(find.byKey(const Key('issuance_continue')))
            .onPressed,
        isNull,
      );
      await tap(tester, 'issuance_deposit');
      await tester.tap(find.text('۱۰.۱۲۳۴۵۶۷.۱').last);
      await tester.pumpAndSettle();
      await tap(tester, 'issuance_type');
      await tester.tap(find.text('صدور کارت با شماره جدید').last);
      await tester.pumpAndSettle();
      await tap(tester, 'issuance_continue');
      expect(find.byType(AppInvoice), findsOneWidget);
      expect(find.byKey(const Key('issuance_address')), findsNothing);
      expect(
        tester
            .widget<AppButton>(find.byKey(const Key('issuance_continue')))
            .onPressed,
        isNull,
      );
      await tap(tester, 'issuance_terms_checkbox');
      await tap(tester, 'issuance_continue');
      expect(receipt!.isMock, true);
      expect(find.textContaining('پرداخت یا صدور واقعی'), findsOneWidget);
    },
  );
  testWidgets('add address validates and stores normalized postal code', (
    tester,
  ) async {
    await mount(tester, const CardIssuanceScreen());
    final c = controller(tester);
    selection(c);
    c.next();
    await tester.pumpAndSettle();
    await tap(tester, 'issuance_add_address');
    await tap(tester, 'issuance_save_address');
    expect(find.textContaining('کد پستی ۱۰ رقمی'), findsOneWidget);
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('issuance_new_address_title')),
        matching: find.byType(EditableText),
      ),
      'محل کار',
    );
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('issuance_new_address_detail')),
        matching: find.byType(EditableText),
      ),
      'تهران، نشانی آزمایشی',
    );
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('issuance_new_address_postal')),
        matching: find.byType(EditableText),
      ),
      '۱۲۳۴۵۶۷۸۹۰',
    );
    await tap(tester, 'issuance_save_address');
    expect(c.state.address!.postalCode, '1234567890');
    expect(find.byType(AppAddressCard), findsOneWidget);
  });
  testWidgets('empty and load error states offer retry', (tester) async {
    final repository = ControlledIssuanceRepository()
      ..catalogResult = const Err(DataFailure('offline'));
    await mount(tester, CardIssuanceScreen(repository: repository));
    expect(find.byKey(const Key('issuance_retry')), findsOneWidget);
    repository.catalogResult = Success(
      IssuanceCatalog(
        deposits: [],
        addresses: [],
        fees: [],
        walletBalanceRial: 0,
      ),
    );
    await tap(tester, 'issuance_retry');
    expect(find.textContaining('سپرده‌ای'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final locale in [
    const Locale('fa'),
    const Locale('en'),
    const Locale('ar'),
  ]) {
    testWidgets(
      'narrow viewport and large text remain usable in ${locale.languageCode}',
      (tester) async {
        await mount(
          tester,
          const CardIssuanceScreen(),
          size: const Size(320, 700),
          scale: 1.3,
          locale: locale,
        );
        final c = controller(tester);
        selection(c);
        c.next();
        c.selectAddress('home');
        c.next();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byKey(const Key('issuance_continue')), findsOneWidget);
      },
    );
  }
  testWidgets(
    'allowlisted card-issue route opens issuance and unknown service is ignored',
    (tester) async {
      await mount(
        tester,
        Builder(
          builder: (context) => AppButton(
            label: 'open',
            onPressed: () {
              expect(openCardFeaturesService(context, 'unknown'), false);
              openCardFeaturesService(
                context,
                'card-issue',
                initialDepositNumber: '10.1234567.1',
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(CardIssuanceScreen), findsOneWidget);
      expect(controller(tester).state.deposit!.id, 'deposit-1');
    },
  );
  testWidgets(
    'system back preserves delivery selection; delete supports cancel and confirm',
    (tester) async {
      await mount(tester, const CardIssuanceScreen());
      final c = controller(tester);
      selection(c);
      c.next();
      c.selectAddress('home');
      c.next();
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(c.state.step, IssuanceStep.delivery);
      expect(c.state.address!.id, 'home');
      final delete = find.descendant(
        of: find.byKey(const Key('issuance_address_card')),
        matching: find.byType(InkWell),
      );
      await tester.tap(delete);
      await tester.pumpAndSettle();
      await tap(tester, 'app_delete_address_cancel');
      expect(c.state.address!.id, 'home');
      await tester.tap(delete);
      await tester.pumpAndSettle();
      await tap(tester, 'app_delete_address_confirm');
      expect(c.state.address, isNull);
      expect(c.state.canContinue, false);
      expect(find.byKey(const Key('issuance_add_address')), findsOneWidget);
    },
  );
  testWidgets(
    'Cards reissue opens issuance and assistant returns through both routes',
    (tester) async {
      var assistant = 0;
      await mount(
        tester,
        Builder(
          builder: (context) => AppButton(
            label: 'cards',
            onPressed: () => openCardFeaturesService(
              context,
              'card-list',
              onAssistantPressed: () => assistant++,
            ),
          ),
        ),
      );
      await tester.tap(find.text('cards'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('listed_card_resalat-0')),
          matching: find.byType(InkWell),
        ),
      );
      await tester.pumpAndSettle();
      await tap(tester, 'card_feature_action_reissue');
      expect(find.byType(CardIssuanceScreen), findsOneWidget);
      await tap(tester, 'issuance_assistant');
      expect(assistant, 1);
      expect(find.byType(CardIssuanceScreen), findsNothing);
      expect(find.byType(CardFeaturesScreen), findsNothing);
      expect(find.text('cards'), findsOneWidget);
    },
  );
}
