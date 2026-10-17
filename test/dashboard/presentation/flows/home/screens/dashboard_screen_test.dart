import 'package:pishkhan_mobile/core/di/injection_container.dart';

import '../../../../support/home_tab_test_scope.dart';
import '../../../../support/dashboard_ui_finders.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import '../../../../support/dashboard_test_repositories.dart';
import '../../../../../support/router_test_app.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/shared/widgets/app_wallet_card.dart';

void main() {
  setUp(configureDependencies);
  tearDown(() => getIt.reset());
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
  }) => TestRouterApp(
    locale: const Locale('fa'),
    supportedLocales: S.delegate.supportedLocales,
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    theme: AppTheme.light(),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: dashboardScope(
      repositories: dashboardTestRepositories(favorites: favorites),
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

  Future<void> tap(WidgetTester tester, Finder finder) async {
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
      expect(dashboardButton(S.current.dashboardConfirm), findsNothing);
      expect(
        tester.getSize(
          find
              .descendant(
                of: find.byType(DashboardResoBannerPanel),
                matching: find.byWidgetPredicate(
                  (widget) => widget is SizedBox && widget.height != null,
                ),
              )
              .first,
        ),
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
      await tap(
        tester,
        find.byWidgetPredicate(
          (widget) =>
              widget is AppButton &&
              (widget.label == S.current.dashboardEdit ||
                  widget.label == S.current.dashboardAddFavorites),
        ),
      );
      await tap(
        tester,
        dashboardSemantic(
          '${S.current.dashboardRemoveService} ${DashboardService.issue.label()}',
        ),
      );
      await tap(tester, dashboardSemantic(S.current.dashboardAddService));
      await tester.enterText(
        find.descendant(
          of: find.byType(AppSearchField),
          matching: find.byType(TextField),
        ),
        'برآورد',
      );
      await tester.pumpAndSettle();
      await tap(
        tester,
        find.byWidgetPredicate(
          (widget) =>
              widget is DashboardServiceOption &&
              widget.service.id == 'loan-estimate',
        ),
      );
      expect(
        find.byKey(const Key('app_service_grid_icon_favorite-loan-estimate')),
        findsOneWidget,
      );
      await tap(tester, dashboardButton(S.current.dashboardCancel));
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
    'confirm saves shortcuts and eight selections hide add and show the limit',
    (tester) async {
      List<String>? saved;
      await render(
        tester,
        subject(
          favorites: [
            'card-issue',
            'card-password',
            'card-block',
            'deposit-sms',
            'deposit-statement',
            'deposit-certificate',
            'deposit-representative',
          ],
          onChanged: (value) => saved = value,
        ),
      );
      await tap(
        tester,
        find.byWidgetPredicate(
          (widget) =>
              widget is AppButton &&
              (widget.label == S.current.dashboardEdit ||
                  widget.label == S.current.dashboardAddFavorites),
        ),
      );
      await tap(tester, dashboardSemantic(S.current.dashboardAddService));
      await tester.enterText(
        find.descendant(
          of: find.byType(AppSearchField),
          matching: find.byType(TextField),
        ),
        'برآورد',
      );
      await tester.pumpAndSettle();
      await tap(
        tester,
        find.byWidgetPredicate(
          (widget) =>
              widget is DashboardServiceOption &&
              widget.service.id == 'loan-estimate',
        ),
      );
      expect(dashboardSemantic(S.current.dashboardAddService), findsNothing);
      expect(find.text(S.current.dashboardFavoritesLimit), findsOneWidget);
      await tap(tester, dashboardButton(S.current.dashboardConfirm));
      expect(saved, [
        'card-issue',
        'card-password',
        'card-block',
        'deposit-sms',
        'deposit-statement',
        'deposit-certificate',
        'deposit-representative',
        'loan-estimate',
      ]);
      expect(dashboardButton(S.current.dashboardConfirm), findsNothing);
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
    await tap(
      tester,
      find.byWidgetPredicate(
        (widget) =>
            widget is AppButton &&
            (widget.label == S.current.dashboardEdit ||
                widget.label == S.current.dashboardAddFavorites),
      ),
    );
    await tap(tester, dashboardButton(S.current.dashboardResetTitle));
    expect(find.text('بازنشانی تنظیمات'), findsNWidgets(2));
    await tap(tester, dashboardResetButton(S.current.dashboardCancel));
    expect(
      dashboardSemantic(
        '${S.current.dashboardRemoveService} ${DashboardService.issue.label()}',
      ),
      findsOneWidget,
    );
    expect(saved, isNull);
    await tap(tester, dashboardButton(S.current.dashboardResetTitle));
    await tap(tester, dashboardResetButton(S.current.dashboardResetConfirm));
    expect(saved, isEmpty);
    expect(dashboardButton(S.current.dashboardConfirm), findsNothing);
    expect(
      find.byKey(const Key('app_service_grid_icon_favorite-card-issue')),
      findsNothing,
    );
  });

  testWidgets(
    'catalog search handles no results, clear and duplicate selection',
    (tester) async {
      await render(tester, subject(favorites: ['card-issue']));
      await tap(
        tester,
        find.byWidgetPredicate(
          (widget) =>
              widget is AppButton &&
              (widget.label == S.current.dashboardEdit ||
                  widget.label == S.current.dashboardAddFavorites),
        ),
      );
      await tap(tester, dashboardSemantic(S.current.dashboardAddService));
      final field = find.descendant(
        of: find.byType(AppSearchField),
        matching: find.byType(TextField),
      );
      await tester.enterText(field, 'xxxxxxxx');
      await tester.pumpAndSettle();
      expect(find.text('خدمتی پیدا نشد'), findsOneWidget);
      await tester.enterText(field, '');
      await tester.pumpAndSettle();
      await tap(
        tester,
        find.byWidgetPredicate(
          (widget) =>
              widget is DashboardServiceOption &&
              widget.service.id == 'card-issue',
        ),
      );
      expect(find.byType(DashboardServicesSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('fixed services and the assistant prompt emit Home effects', (
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
    await tap(tester, find.byKey(Key('app_service_grid_icon_card-password')));
    expect(service, 'card-password');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(AppTextField),
        matching: find.byType(TextField),
      ),
      '  سوال من  ',
    );
    // Render the Cubit-driven enabled state before tapping the send action.
    await tester.pump();
    await tap(tester, dashboardSemantic(S.current.dashboardSendPrompt));
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
      await tap(
        tester,
        find.byWidgetPredicate(
          (widget) =>
              widget is AppButton &&
              (widget.label == S.current.dashboardEdit ||
                  widget.label == S.current.dashboardAddFavorites),
        ),
      );
      await tap(tester, dashboardButton(S.current.dashboardConfirm));
      await tap(tester, find.byKey(Key('dashboard_menu_button')));
      expect(find.byType(DashboardServicesSheet), findsOneWidget);
      await tap(tester, find.byKey(Key('app_bottom_sheet_left_action')));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'all services opens a separate route and forwards the last service',
    (tester) async {
      String? selected;
      await render(tester, subject(onService: (value) => selected = value));
      await tap(tester, dashboardButton(S.current.dashboardViewAll));
      expect(
        find.descendant(
          of: find.byType(DashboardAllServicesScreen),
          matching: find.byType(SingleChildScrollView),
        ),
        findsOneWidget,
      );
      expect(find.byType(DashboardServicesSheet), findsNothing);
      await tap(
        tester,
        find.byKey(Key('app_service_grid_icon_all-requests-list')),
      );
      expect(selected, 'requests-list');
      await tap(
        tester,
        find.byWidgetPredicate(
          (widget) =>
              widget is AppButton &&
              widget.icon is AvpImage &&
              (widget.icon as AvpImage).image == AppAssets.dashboardCatalogBack,
        ),
      );
      expect(find.byType(DashboardBankServices), findsOneWidget);
    },
  );
  testWidgets(
    'service groups collapse and Arabic search variants match Persian labels',
    (tester) async {
      await render(tester, subject());
      await tap(tester, find.byKey(Key('dashboard_menu_button')));
      await tap(
        tester,
        find.byWidgetPredicate(
          (widget) =>
              widget is DashboardCategoryHeading &&
              widget.category == DashboardCategory.cards,
        ),
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is DashboardServiceOption &&
              widget.service.id == 'card-issue',
        ),
        findsNothing,
      );
      await tap(
        tester,
        find.byWidgetPredicate(
          (widget) =>
              widget is DashboardCategoryHeading &&
              widget.category == DashboardCategory.cards,
        ),
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is DashboardServiceOption &&
              widget.service.id == 'card-issue',
        ),
        findsOneWidget,
      );
      await tester.enterText(
        find.descendant(
          of: find.byType(AppSearchField),
          matching: find.byType(TextField),
        ),
        'تغيير',
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is DashboardServiceOption &&
              widget.service.id == 'card-deposit',
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is DashboardServiceOption &&
              widget.service.id == 'wallet-deposit',
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is DashboardServiceOption &&
              widget.service.id == 'identity-phone',
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is DashboardServiceOption &&
              widget.service.id == 'identity-change',
        ),
        findsOneWidget,
      );
      final clear = find.byType(AppSearchField);
      final clearButton = find.descendant(
        of: clear,
        matching: find.byType(IconButton),
      );
      await tester.tap(clearButton);
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is DashboardCategoryHeading &&
              widget.category == DashboardCategory.modern,
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
