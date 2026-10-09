import 'package:pishkhan_mobile/features/dashboard/data/mock/mock_dashboard_repositories.dart';
import 'package:pishkhan_mobile/features/dashboard/data/mock/dashboard_mock_data.dart';

import 'dart:io';
import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_card.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/tabs/cards/cards_tab.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/dashboard_screen.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_resalat_card.dart';

const _preview = Key('cards_preview');
void main() {
  setUpAll(() async {
    final loader = FontLoader(AppTypography.defaultFontFamily);
    for (final weight in ['Regular', 'Medium', 'DemiBold', 'Bold']) {
      loader.addFont(
        rootBundle.load(
          'packages/avp_ui/assets/fonts/IRANYekanXFaNum-$weight.ttf',
        ),
      );
    }
    await loader.load();
  });
  Widget subject(Widget child, {double scale = 1}) => RepaintBoundary(
    key: _preview,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: const Locale('fa'),
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
    Widget widget, {
    Size size = const Size(375, 1017),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 40);
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 40);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String key) async {
    final finder = find.byKey(Key(key));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  for (final single in [true, false]) {
    testWidgets(
      '${single ? 'single' : 'multi'} card frame renders the supplied design',
      (tester) async {
        final shadows = debugDisableShadows;
        debugDisableShadows = false;
        try {
          await mount(
            tester,
            subject(
              CardsTab(
                repository: MockDashboardCardsRepository(
                  cards: single
                      ? const [DashboardMockData.singleCard]
                      : DashboardMockData.cards,
                ),
              ),
            ),
          );
          expect(tester.takeException(), isNull);
          expect(
            tester.getTopLeft(find.byKey(const Key('cards_operations'))).dy,
            341,
          );
          expect(
            tester.getSize(find.byKey(const Key('cards_operations'))).height,
            176,
          );
          expect(
            tester
                .getSize(find.byKey(const Key('cards_pin_operations')))
                .height,
            160,
          );
          expect(
            tester.getSize(find.byKey(const Key('cards_quick_access'))).height,
            176,
          );
          final active = find.descendant(
            of: find.byKey(
              ValueKey('bank_card_${single ? 'current' : 'qarz-1'}'),
            ),
            matching: find.byKey(const Key('app_resalat_card')),
          );
          expect(
            tester.getSize(active),
            single ? const Size(335, 202) : const Size(316, 191),
          );
          expect(tester.getTopLeft(active).dy, 104);
          expect(
            find.byKey(const Key('cards_carousel')),
            single ? findsNothing : findsOneWidget,
          );
          final operations = find.byKey(const Key('cards_operations'));
          final block = find.descendant(
            of: operations,
            matching: find.byKey(const Key('app_service_grid_icon_card-block')),
          );
          final reissue = find.descendant(
            of: operations,
            matching: find.byKey(
              const Key('app_service_grid_icon_card-reissue'),
            ),
          );
          expect(
            tester.getCenter(reissue).dx,
            greaterThan(tester.getCenter(block).dx),
          );
          if (Platform.environment['UPDATE_CARDS_PREVIEWS'] == '1') {
            await tester.runAsync(() async {
              final full = await tester
                  .renderObject<RenderRepaintBoundary>(find.byKey(_preview))
                  .toImage(pixelRatio: 1);
              final recorder = ui.PictureRecorder();
              Canvas(recorder).drawImageRect(
                full,
                const Rect.fromLTWH(0, 24, 375, 953),
                const Rect.fromLTWH(0, 0, 375, 953),
                Paint(),
              );
              final picture = recorder.endRecording();
              final image = await picture.toImage(375, 953);
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final directory = Directory('doc/cards-review');
              await directory.create(recursive: true);
              await File(
                '${directory.path}/phase1-${single ? 'single' : 'multi'}.png',
              ).writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
              picture.dispose();
              full.dispose();
            });
          }
        } finally {
          debugDisableShadows = shadows;
          await tester.pumpWidget(const SizedBox.shrink());
        }
      },
    );
  }
  testWidgets(
    'card details toggle without changing card number and copying uses original values',
    (tester) async {
      const card = BankCard(
        id: 'test',
        numberParts: ['6037', '9912', '3456', '7890'],
        iban: 'IR123456789012345678901234',
        cvv2: '536',
        expiry: '06/08',
      );
      String? copiedNumber, copiedIban;
      BankCard? more;
      CardActionRequest? request;
      await mount(
        tester,
        subject(
          CardsTab(
            repository: MockDashboardCardsRepository(cards: const [card]),
            onCopyNumber: (v) => copiedNumber = v,
            onCopyIban: (v) => copiedIban = v,
            onMorePressed: (v) => more = v,
            onActionRequested: (v) => request = v,
          ),
        ),
      );
      expect(find.text('536'), findsOneWidget);
      await tap(tester, 'app_resalat_card_visibility');
      expect(find.text('536'), findsNothing);
      expect(find.text('****'), findsOneWidget);
      await tap(tester, 'app_resalat_card_copy_number');
      await tap(tester, 'app_resalat_card_copy_iban');
      expect(copiedNumber, card.number);
      expect(copiedIban, card.iban);
      await tap(tester, 'app_resalat_card_more');
      expect(more?.id, 'test');
      await tap(tester, 'app_service_grid_icon_card-reissue');
      expect(request?.action, CardAction.reissue);
      expect(request?.card.id, 'test');
    },
  );
  testWidgets(
    'carousel changes the action card and keeps each visibility state',
    (tester) async {
      const cards = [
        BankCard(id: 'first', cvv2: '111'),
        BankCard(id: 'second', cvv2: '222', canSetSecondPin: false),
      ];
      BankCard? selected;
      CardActionRequest? request;
      await mount(
        tester,
        subject(
          CardsTab(
            repository: MockDashboardCardsRepository(cards: cards),
            onSelectedCardChanged: (v) => selected = v,
            onActionRequested: (v) => request = v,
          ),
        ),
      );
      final first = find.byKey(const ValueKey('bank_card_first'));
      await tester.tap(
        find.descendant(
          of: first,
          matching: find.byKey(const Key('app_resalat_card_visibility')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('111'), findsOneWidget);
      await tester.drag(
        find.byKey(const Key('cards_carousel')),
        const Offset(330, 0),
      );
      await tester.pumpAndSettle();
      expect(selected?.id, 'second');
      expect(
        find.byKey(const Key('app_service_grid_icon_card-pin-second-forgot')),
        findsOneWidget,
      );
      await tap(tester, 'app_service_grid_icon_card-block');
      expect(request?.card.id, 'second');
      await tap(tester, 'cards_indicator_0');
      expect(find.text('111'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'dashboard switches tabs, preserves customization, and system back returns to dashboard',
    (tester) async {
      await mount(
        tester,
        subject(
          const DashboardScreen(
            enableAnimations: false,
            initialFavorites: ['card-issue'],
          ),
        ),
      );
      await tap(tester, 'primary_tab_cards');
      expect(find.text('کارت‌های من'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('app_service_grid_icon_favorite-card-issue')),
        findsOneWidget,
      );
      await tap(tester, 'primary_tab_cards');
      await tap(tester, 'primary_tab_dashboard');
      expect(
        find.byKey(const Key('app_service_grid_icon_favorite-card-issue')),
        findsOneWidget,
      );
    },
  );
  testWidgets('small screen and enlarged text keep actions reachable', (
    tester,
  ) async {
    await mount(
      tester,
      subject(
        const CardsTab(repository: MockDashboardCardsRepository()),
        scale: 1.5,
      ),
      size: const Size(320, 640),
    );
    await tap(tester, 'app_service_grid_icon_card-gift-balance');
    expect(tester.takeException(), isNull);
  });
  testWidgets('an empty card list renders without a selected-card lookup', (
    tester,
  ) async {
    await mount(
      tester,
      subject(
        const CardsTab(repository: MockDashboardCardsRepository(cards: [])),
      ),
    );
    expect(find.text('هنوز کارتی ندارید'), findsOneWidget);
    expect(find.byType(AppResalatCard), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
