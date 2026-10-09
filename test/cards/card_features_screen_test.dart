import 'dart:async';

import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import 'support/test_cards_repository.dart';

import 'dart:io';
import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/cards/cards.dart';
import 'package:pishkhan_mobile/features/cards/data/mock/mock_cards_repository.dart';
import 'package:pishkhan_mobile/features/dashboard/dashboard.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_cards_list.dart';

const boundary = Key('cards_flow_preview');
Widget subject(Widget home, {double scale = 1}) => RepaintBoundary(
  key: boundary,
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    locale: const Locale('fa'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    builder: (context, child) => Directionality(
      textDirection: TextDirection.rtl,
      child: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
    ),
    home: home,
  ),
);
Future<void> mount(
  WidgetTester tester,
  Widget home, {
  double height = 812,
}) async {
  tester.view.physicalSize = Size(375, height);
  tester.view.devicePixelRatio = 1;
  tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 40);
  tester.view.padding = const FakeViewPadding(top: 24, bottom: 40);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(home);
  await tester.pumpAndSettle();
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> preview(WidgetTester tester, String name) async {
  if (Platform.environment['UPDATE_CARD_FEATURES_PREVIEWS'] != '1' &&
      !const bool.fromEnvironment('UPDATE_CARD_FEATURES_PREVIEWS')) {
    return;
  }
  await tester.runAsync(() async {
    final render = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(boundary),
    );
    final image = await render.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('doc/card-features-review/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

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
  for (final category in CardCategory.values) {
    testWidgets(
      '${category.name} frame reuses colored list and has correct geometry',
      (tester) async {
        final old = debugDisableShadows;
        debugDisableShadows = false;
        try {
          await mount(
            tester,
            subject(CardFeaturesScreen(initialCategory: category)),
            height:
                category == CardCategory.gift ||
                    category == CardCategory.virtual
                ? 854
                : 812,
          );
          final cards = find.byType(AppCardsList);
          expect(tester.getRect(cards.first).top, 236);
          expect(tester.getSize(cards.first), const Size(343, 116));
          expect(tester.widget<AppCardsList>(cards.first).coloredHeader, true);
          expect(
            tester.widget<AppCardsList>(cards.first).type,
            AppCardsListType.values[category.index],
          );
          expect(
            find.byKey(const Key('card_features_footer')),
            category == CardCategory.gift || category == CardCategory.virtual
                ? findsOneWidget
                : findsNothing,
          );
          expect(tester.takeException(), isNull);
          await preview(tester, category.name);
        } finally {
          debugDisableShadows = old;
          await tester.pumpWidget(const SizedBox.shrink());
        }
      },
    );
  }
  testWidgets(
    'options lead to selected details; service callbacks carry the same card',
    (tester) async {
      CardFeatureRequest? request;
      await mount(
        tester,
        subject(
          CardFeaturesScreen(onActionRequested: (value) => request = value),
        ),
      );
      final more = find
          .descendant(
            of: find.byType(AppCardsList).first,
            matching: find.byType(InkWell),
          )
          .first;
      await tap(tester, more);
      expect(
        tester
            .getRect(find.byKey(const Key('card_features_actions_sheet')))
            .top,
        464,
      );
      await preview(tester, 'actions');
      await tap(tester, find.byKey(const Key('card_feature_action_details')));
      expect(
        tester
            .getRect(find.byKey(const Key('card_features_details_sheet')))
            .top,
        284,
      );
      expect(find.text('IR500700000010051234567890'), findsOneWidget);
      await preview(tester, 'details');
      await tap(tester, find.byKey(const Key('card_features_details_back')));
      for (final action in [
        CardFeatureAction.reissue,
        CardFeatureAction.changeDeposit,
        CardFeatureAction.block,
      ]) {
        await tap(tester, more);
        await tap(
          tester,
          find.byKey(Key('card_feature_action_${action.name}')),
        );
        expect(request!.card!.id, 'resalat-0');
        expect(request!.action, action);
      }
    },
  );
  testWidgets(
    'filter edits commit only on Apply; remove filter and system back work',
    (tester) async {
      await mount(tester, subject(const CardFeaturesScreen()));
      await tap(tester, find.byKey(const Key('card_features_filter_button')));
      expect(
        tester.getRect(find.byKey(const Key('card_features_filter_sheet'))).top,
        424,
      );
      await preview(tester, 'filter-all');
      await tap(tester, find.byKey(const Key('card_features_status_select')));
      await tap(tester, find.text('فعال').last);
      await tap(tester, find.byKey(const Key('card_features_deposit_select')));
      await tap(tester, find.text('10-122-1234567-1').last);
      await preview(tester, 'filter-selected');
      await tap(tester, find.byKey(const Key('card_features_apply_filter')));
      expect(find.byType(AppCardsList), findsNWidgets(3));
      await tap(tester, find.byKey(const Key('card_features_filter_button')));
      await tap(tester, find.byKey(const Key('app_bottom_sheet_left_action')));
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(AppCardsList), findsNWidgets(3));
      await tap(tester, find.byKey(const Key('card_features_filter_button')));
      await tap(tester, find.byKey(const Key('app_bottom_sheet_left_action')));
      await tap(tester, find.byKey(const Key('card_features_apply_filter')));
      expect(find.byType(AppCardsList), findsNWidgets(4));
    },
  );
  testWidgets(
    'search and category switching combine; category footer retains context',
    (tester) async {
      CardFeatureRequest? request;
      await mount(
        tester,
        subject(
          CardFeaturesScreen(onActionRequested: (value) => request = value),
        ),
      );
      await tester.enterText(find.byType(TextField), '۱۰.۱۲۳۴۵۶۷.۲');
      await tester.pumpAndSettle();
      expect(find.byType(AppCardsList), findsOneWidget);
      await tap(tester, find.byKey(const Key('card_category_gift')));
      expect(
        tester.widget<AppCardsList>(find.byType(AppCardsList)).type,
        AppCardsListType.gift,
      );
      await tap(tester, find.byKey(const Key('card_features_footer')));
      expect(request!.action, CardFeatureAction.expiredGiftBalance);
      expect(request!.category, CardCategory.gift);
      expect(request!.card, isNull);
      await tester.enterText(find.byType(TextField), '');
      await tap(tester, find.byKey(const Key('card_category_family')));
      expect(find.byType(AppCardsList), findsNWidgets(2));
      expect(find.byKey(const Key('card_features_footer')), findsNothing);
    },
  );
  testWidgets(
    'Dashboard catalog opens standalone Cards flow and back retains shell',
    (tester) async {
      await mount(
        tester,
        subject(const DashboardScreen(enableAnimations: false)),
      );
      await tap(tester, find.byKey(const Key('dashboard_menu_button')).first);
      await tap(tester, find.text('لیست کارت‌ها').last);
      expect(find.byType(CardFeaturesScreen), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('dashboard_bank_services')), findsOneWidget);
    },
  );
  testWidgets('empty repository has usable controls and no card operations', (
    tester,
  ) async {
    await mount(
      tester,
      subject(
        CardFeaturesScreen(repository: MockCardsRepository(cards: const [])),
      ),
    );
    expect(find.byType(AppCardsList), findsNothing);
    expect(find.text('هنوز کارتی ندارید'), findsOneWidget);
    expect(
      find.byKey(const Key('card_features_filter_button')),
      findsOneWidget,
    );
  });
  testWidgets('narrow large-text gift footer and filter remain reachable', (
    tester,
  ) async {
    await mount(
      tester,
      subject(
        const CardFeaturesScreen(initialCategory: CardCategory.gift),
        scale: 1.4,
      ),
    );
    tester.view.physicalSize = const Size(320, 700);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tap(tester, find.byKey(const Key('card_features_filter_button')));
    await tap(tester, find.byKey(const Key('card_features_status_select')));
    await tap(tester, find.text('فعال').last);
    await tap(tester, find.byKey(const Key('card_features_apply_filter')));
    expect(find.byKey(const Key('card_features_footer')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'loading/error/retry and repository replacement have usable states',
    (tester) async {
      final repo = FakeCardsRepository();
      final pending = Completer<Result<List<ListedCard>>>();
      repo.queue.add(pending);
      await tester.pumpWidget(subject(CardFeaturesScreen(repository: repo)));
      await tester.pump();
      expect(
        tester.widget<AppButton>(find.byType(AppButton).last).isLoading,
        true,
      );
      pending.complete(const Err(DataFailure('offline')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('card_features_retry')), findsOneWidget);
      await tap(tester, find.byKey(const Key('card_features_retry')));
      expect(find.byType(AppCardsList), findsNWidgets(4));
      await tester.pumpWidget(
        subject(
          CardFeaturesScreen(repository: MockCardsRepository(cards: const [])),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AppCardsList), findsNothing);
      expect(find.text('هنوز کارتی ندارید'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
