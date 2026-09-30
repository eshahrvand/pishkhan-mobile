import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/dashboard_screen.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_wallet_card.dart';

void main() {
  setUpAll(() async {
    final loader = FontLoader(AppTypography.defaultFontFamily);
    for (final weight in ['Regular']) {
      loader.addFont(
        rootBundle.load(
          'packages/avp_ui/assets/fonts/IRANYekanXFaNum-$weight.ttf',
        ),
      );
    }
    await loader.load();
  });
  Widget subject({
    List<String> favorites = const [],
    ValueChanged<List<String>>? onChanged,
    ValueChanged<String>? onService,
    ValueChanged<String>? onPrompt,
    double textScale = 1,
  }) => MaterialApp(
    locale: const Locale('fa'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: AppTheme.light(),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: DashboardScreen(
      initialFavorites: favorites,
      onFavoritesChanged: onChanged,
      onServiceRequested: onService,
      onPromptSubmitted: onPrompt,
    ),
  );

  Future<void> render(
    WidgetTester tester,
    Widget child, {
    Size size = const Size(375, 1000),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(child);
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String key) async {
    final finder = find.byKey(Key(key));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'new dashboard renders in RTL with wallet, Reso, services and navigation',
    (tester) async {
      await render(tester, subject());
      expect(find.byType(AppWalletCard), findsOneWidget);
      expect(find.text('به رِسو بسپار!'), findsOneWidget);
      expect(find.text('خدمات بانک رسالت'), findsOneWidget);
      expect(find.byKey(const Key('dashboard_favorites_editor')), findsNothing);
      expect(
        tester.getSize(find.byKey(const Key('dashboard_reso_banner'))),
        const Size(343, 194),
      );
      expect(
        tester.getSize(find.byKey(const Key('dashboard_header'))).height,
        64,
      );
      final assistant = tester.getCenter(
        find.byKey(const Key('app_service_grid_icon_assistant')),
      );
      final sms = tester.getCenter(
        find.byKey(const Key('app_service_grid_icon_deposit-sms')),
      );
      expect(assistant.dx, greaterThan(sms.dx));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'adding, removing and cancelling shortcuts preserves committed favorites',
    (tester) async {
      List<String>? saved;
      await render(
        tester,
        subject(favorites: ['card-issue'], onChanged: (value) => saved = value),
      );
      await tap(tester, 'dashboard_customize');
      await tap(tester, 'dashboard_remove_card-issue');
      await tap(tester, 'dashboard_add_service');
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('dashboard_service_search')),
          matching: find.byType(TextField),
        ),
        'برآورد',
      );
      await tester.pumpAndSettle();
      await tap(tester, 'app_service_grid_icon_catalog-loan-estimate');
      expect(
        find.byKey(const Key('app_service_grid_icon_favorite-loan-estimate')),
        findsOneWidget,
      );
      await tap(tester, 'dashboard_cancel');
      expect(
        find.byKey(const Key('app_service_grid_icon_favorite-card-issue')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('app_service_grid_icon_favorite-loan-estimate')),
        findsNothing,
      );
      expect(saved, isNull);
    },
  );

  testWidgets(
    'confirm saves shortcuts and four selections hide add and show the limit',
    (tester) async {
      List<String>? saved;
      await render(
        tester,
        subject(
          favorites: ['card-issue', 'card-password', 'card-block'],
          onChanged: (value) => saved = value,
        ),
      );
      await tap(tester, 'dashboard_customize');
      await tap(tester, 'dashboard_add_service');
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('dashboard_service_search')),
          matching: find.byType(TextField),
        ),
        'برآورد',
      );
      await tester.pumpAndSettle();
      await tap(tester, 'app_service_grid_icon_catalog-loan-estimate');
      expect(find.byKey(const Key('dashboard_add_service')), findsNothing);
      expect(
        find.byKey(const Key('dashboard_favorites_limit')),
        findsOneWidget,
      );
      await tap(tester, 'dashboard_confirm');
      expect(saved, [
        'card-issue',
        'card-password',
        'card-block',
        'loan-estimate',
      ]);
      expect(find.byKey(const Key('dashboard_favorites_editor')), findsNothing);
      expect(
        find.byKey(const Key('app_service_grid_icon_favorite-loan-estimate')),
        findsOneWidget,
      );
    },
  );

  testWidgets('reset requires confirmation and cancel retains the edit draft', (
    tester,
  ) async {
    List<String>? saved;
    await render(
      tester,
      subject(favorites: ['card-issue'], onChanged: (value) => saved = value),
    );
    await tap(tester, 'dashboard_customize');
    await tap(tester, 'dashboard_reset');
    expect(find.text('بازنشانی تنظیمات'), findsOneWidget);
    await tap(tester, 'dashboard_reset_cancel');
    expect(
      find.byKey(const Key('dashboard_remove_card-issue')),
      findsOneWidget,
    );
    expect(saved, isNull);
    await tap(tester, 'dashboard_reset');
    await tap(tester, 'dashboard_reset_confirm');
    expect(saved, isEmpty);
    expect(find.byKey(const Key('dashboard_favorites_editor')), findsNothing);
    expect(
      find.byKey(const Key('app_service_grid_icon_favorite-card-issue')),
      findsNothing,
    );
  });

  testWidgets(
    'catalog search handles no results, clear and duplicate selection',
    (tester) async {
      await render(tester, subject(favorites: ['card-issue']));
      await tap(tester, 'dashboard_customize');
      await tap(tester, 'dashboard_add_service');
      final field = find.descendant(
        of: find.byKey(const Key('dashboard_service_search')),
        matching: find.byType(TextField),
      );
      await tester.enterText(field, 'xxxxxxxx');
      await tester.pumpAndSettle();
      expect(find.text('خدمتی پیدا نشد'), findsOneWidget);
      await tester.enterText(field, '');
      await tester.pumpAndSettle();
      await tap(tester, 'app_service_grid_icon_catalog-card-issue');
      expect(find.byKey(const Key('dashboard_services_sheet')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('fixed services and the assistant prompt deliver callbacks', (
    tester,
  ) async {
    String? service;
    String? prompt;
    await render(
      tester,
      subject(
        onService: (value) => service = value,
        onPrompt: (value) => prompt = value,
      ),
    );
    await tap(tester, 'app_service_grid_icon_card-password');
    expect(service, 'card-password');
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('dashboard_assistant_prompt')),
        matching: find.byType(TextField),
      ),
      '  سوال من  ',
    );
    await tap(tester, 'dashboard_submit_prompt');
    expect(prompt, 'سوال من');
  });

  testWidgets(
    'small screen and enlarged text keep editing and sheets scrollable',
    (tester) async {
      await render(
        tester,
        subject(
          textScale: 1.5,
          favorites: [
            'card-issue',
            'card-password',
            'card-block',
            'loan-estimate',
          ],
        ),
        size: const Size(320, 640),
      );
      await tap(tester, 'dashboard_customize');
      await tap(tester, 'dashboard_confirm');
      await tap(tester, 'dashboard_menu_button');
      expect(find.byKey(const Key('dashboard_services_sheet')), findsOneWidget);
      await tap(tester, 'app_bottom_sheet_left_action');
      expect(tester.takeException(), isNull);
    },
  );
}
