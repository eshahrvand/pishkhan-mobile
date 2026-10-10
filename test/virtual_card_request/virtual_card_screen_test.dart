import 'dart:io';
import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/router/card_features_navigation.dart';
import 'package:pishkhan_mobile/features/cards/cards.dart';
import 'package:pishkhan_mobile/features/virtual_card_request/virtual_card_request.dart';
import 'package:pishkhan_mobile/features/virtual_card_request/presentation/cubit/virtual_card_cubit.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_invoice.dart';

import 'virtual_card_cubit_test.dart' show TestVirtualRepository;

void main() {
  setUpAll(() async {
    final loader = FontLoader(AppTypography.defaultFontFamily);
    for (final face in ['Regular', 'Medium', 'DemiBold', 'Bold']) {
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
    Locale locale = const Locale('fa'),
    double scale = 1,
  }) => RepaintBoundary(
    key: const Key('virtual_preview'),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: child,
    ),
  );
  Future<void> mount(
    WidgetTester t, {
    TestVirtualRepository? repository,
    Size size = const Size(375, 812),
    Locale locale = const Locale('fa'),
    double scale = 1,
  }) async {
    t.view.physicalSize = size;
    t.view.devicePixelRatio = 1;
    t.view.padding = const FakeViewPadding(top: 24, bottom: 40);
    t.view.viewPadding = const FakeViewPadding(top: 24, bottom: 40);
    addTearDown(t.view.reset);
    await t.pumpWidget(
      subject(
        VirtualCardRequestScreen(
          repository: repository ?? TestVirtualRepository(),
        ),
        locale: locale,
        scale: scale,
      ),
    );
    await t.pumpAndSettle();
  }

  VirtualCardCubit cubit(WidgetTester t) => t
      .element(find.byType(BlocConsumer<VirtualCardCubit, VirtualCardState>))
      .read<VirtualCardCubit>();
  Future<void> fill(WidgetTester t) async {
    await t.tap(find.byKey(const Key('virtual_deposit')));
    await t.pumpAndSettle();
    await t.tap(find.text('10.1234567.1'));
    await t.pumpAndSettle();
    await t.enterText(
      find.descendant(
        of: find.byKey(const Key('virtual_count')),
        matching: find.byType(TextField),
      ),
      '۴',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('virtual_terms')));
    await t.pumpAndSettle();
  }

  Future<void> capture(WidgetTester t, String name) async {
    if (!const bool.fromEnvironment('UPDATE_VIRTUAL_PREVIEWS')) return;
    t.binding.buildOwner!.reassemble(t.binding.rootElement!);
    await t.pumpAndSettle();
    await t.runAsync(() async {
      final boundary = t.renderObject<RenderRepaintBoundary>(
        find.byKey(const Key('virtual_preview')),
      );
      final warm = await boundary.toImage(pixelRatio: 2);
      warm.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final image = await boundary.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final directory = Directory('doc/virtual-card-request-review');
      await directory.create(recursive: true);
      await File('${directory.path}/$name.png')
          .writeAsBytes(data!.buffer.asUint8List());
      image.dispose();
    });
  }

  testWidgets('empty form matches initial geometry and cannot submit', (
    t,
  ) async {
    await mount(t, size: const Size(375, 814));
    expect(t.getTopLeft(find.byKey(const Key('virtual_notice'))).dy, 164);
    expect(t.getSize(find.byKey(const Key('virtual_notice'))).height, 74);
    expect(t.getTopLeft(find.byKey(const Key('virtual_deposit'))).dy, 258);
    expect(t.getTopLeft(find.byKey(const Key('virtual_count'))).dy, 374);
    expect(cubit(t).state.canSubmit, false);
    expect(find.byType(AppInvoice), findsNothing);
    await capture(t, 'empty');
  });
  testWidgets(
    'filled selectors and normalized count produce quoted invoice and expandable fee',
    (t) async {
      final r = TestVirtualRepository();
      await mount(t, repository: r);
      await fill(t);
      expect(cubit(t).state.count, 4);
      expect(cubit(t).state.canSubmit, true);
      expect(t.getTopLeft(find.byKey(const Key('virtual_invoice'))).dy, 458);
      expect(t.getSize(find.byType(AppInvoice)).height, 174);
      expect(
        t.getSize(find.byKey(const Key('virtual_card_fee_art'))),
        const Size(16.2878, 12.9544),
      );
      await capture(t, 'filled');
      await t.tap(find.byKey(const Key('virtual_invoice')));
      await t.pumpAndSettle();
      expect(cubit(t).state.expanded, false);
      expect(t.getSize(find.byType(AppInvoice)).height, 130);
      await t.tap(find.byKey(const Key('virtual_submit')));
      await t.pumpAndSettle();
      expect(r.requests.single.quote.count, 4);
      expect(r.requests.single.quote.depositId, 'virtual-deposit-1');
      expect(find.byType(AlertDialog), findsNothing);
    },
  );
  testWidgets('count edits reset consent and poor wallet prevents submit', (
    t,
  ) async {
    final r = TestVirtualRepository()..wallet = 0;
    await mount(t, repository: r);
    await fill(t);
    expect(cubit(t).state.canSubmit, false);
    await t.enterText(
      find.descendant(
        of: find.byKey(const Key('virtual_count')),
        matching: find.byType(TextField),
      ),
      '٠',
    );
    await t.pumpAndSettle();
    expect(cubit(t).state.terms, false);
    expect(cubit(t).state.quote, isNull);
    expect(t.takeException(), isNull);
  });
  for (final locale in ['fa', 'en', 'ar']) {
    testWidgets('320px large text keeps form and footer reachable in $locale', (
      t,
    ) async {
      await mount(
        t,
        size: const Size(320, 720),
        locale: Locale(locale),
        scale: 1.3,
      );
      await fill(t);
      await t.ensureVisible(find.byKey(const Key('virtual_invoice')));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.byKey(const Key('virtual_submit')), findsOneWidget);
    });
  }
  testWidgets(
    'Card Services opens request route and forwards selected deposit',
    (t) async {
      await t.pumpWidget(
        subject(
          Builder(
            builder: (context) => Scaffold(
              body: AppButton(
                label: 'Request',
                onPressed: () => openCardFeaturesService(
                  context,
                  'card-virtual',
                  initialDepositNumber: '۱۰.۱۲۳۴۵۶۷.۱',
                ),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('Request'));
      await t.pumpAndSettle();
      expect(find.byType(VirtualCardRequestScreen), findsOneWidget);
      expect(cubit(t).state.depositId, 'virtual-deposit-1');
    },
  );
  testWidgets(
    'successful request returns from virtual list to main without a dialog',
    (t) async {
      await t.pumpWidget(
        subject(
          Builder(
            builder: (context) => Scaffold(
              body: AppButton(
                label: 'Main page',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CardFeaturesScreen(
                      initialCategory: CardCategory.virtual,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('Main page'));
      await t.pumpAndSettle();
      await t.tap(find.text('درخواست کارت مجازی'));
      await t.pumpAndSettle();
      expect(find.byType(VirtualCardRequestScreen), findsOneWidget);
      await fill(t);
      await t.tap(find.byKey(const Key('virtual_submit')));
      await t.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(VirtualCardRequestScreen), findsNothing);
      expect(find.byType(CardFeaturesScreen), findsNothing);
      expect(find.text('Main page'), findsOneWidget);
    },
  );
}
