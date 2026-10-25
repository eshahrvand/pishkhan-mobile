import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/home_cubit.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';

import '../../../../support/home_tab_test_scope.dart';
import '../../../../support/dashboard_ui_finders.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import '../../../../support/dashboard_test_repositories.dart';
import '../../../../../support/router_test_app.dart';

import 'dart:io';
import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/screens/dashboard_screen.dart';

const _preview = Key('dashboard_preview');
const _six = [
  'card-issue',
  'loan-consolidate',
  'cheque-issue',
  'card-deposit',
  'modern-mobile',
  'deposit-proxy',
];
const _eight = [..._six, 'modern-internet', 'loan-deposit'];

void main() {
  setUp(configureDependencies);
  tearDown(() => getIt.reset());
  setUpAll(() async {
    final fonts = FontLoader(AppTypography.defaultFontFamily);
    for (final weight in ['Regular', 'Medium', 'DemiBold', 'Bold']) {
      fonts.addFont(
        rootBundle.load(
          'packages/avp_ui/assets/fonts/IRANYekanXFaNum-$weight.ttf',
        ),
      );
    }
    await fonts.load();
  });
  Widget app(Widget home, {bool reduceMotion = false}) => RepaintBoundary(
    key: _preview,
    child: TestRouterApp(
      debugShowCheckedModeBanner: false,
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
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: Directionality(textDirection: TextDirection.rtl, child: child!),
      ),
      home: home,
    ),
  );
  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  for (final (name, height, favorites, action)
      in <(String, double, List<String>, String?)>[
        ('phase1-default', 870, [], null),
        ('phase1-setting', 1086, [], 'edit'),
        ('phase2-services', 1086, [], 'sheet'),
        ('phase2-search', 814, [], 'search'),
        ('phase3-edit-six', 1204, _six, 'edit'),
        ('phase3-edit-eight', 1254, _eight, 'edit'),
        ('phase3-reset', 1034, _six, 'reset'),
        ('phase4-customized', 1116, _six, null),
        ('phase4-all-services', 2240, [], 'all'),
      ]) {
    testWidgets('$name renders without layout errors', (tester) async {
      tester.view.physicalSize = Size(375, height);
      tester.view.devicePixelRatio = 1;
      tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 40);
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 40);
      addTearDown(tester.view.reset);
      final shadows = debugDisableShadows;
      debugDisableShadows = false;
      addTearDown(() {
        debugDisableShadows = shadows;
      });
      await tester.pumpWidget(
        app(
          dashboardScope(
            repositories: dashboardTestRepositories(favorites: favorites),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final context = tester.element(find.byType(DashboardScreen));
        await precacheImage(
          const AssetImage('${AppConstants.baseImage}dashboard_reso.png'),
          context,
        );
        await precacheImage(
          const AssetImage('${AppConstants.baseImage}dashboard_texture.png'),
          context,
        );
      });
      await tester.pumpAndSettle();
      if (action == 'edit' || action == 'reset') {
        await tap(
          tester,
          find.byWidgetPredicate(
            (widget) =>
                widget is AppButton &&
                (widget.label == S.current.dashboardEdit ||
                    widget.label == S.current.dashboardAddFavorites),
          ),
        );
      }
      if (action == 'reset') {
        await tap(tester, dashboardButton(S.current.dashboardResetTitle));
      }
      if (action == 'sheet' || action == 'search') {
        await tap(tester, find.byKey(Key('dashboard_menu_button')));
      }
      if (action == 'search') {
        tester.view.viewInsets = const FakeViewPadding(bottom: 315);
        tester.view.padding = const FakeViewPadding(top: 24);
        await tester.enterText(
          find.descendant(
            of: find.byType(AppSearchField),
            matching: find.byType(TextField),
          ),
          'تغییر',
        );
        await tester.pumpAndSettle();
      }
      if (action == 'search') {
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
      }
      if (action == 'all') {
        await tap(tester, dashboardButton(S.current.dashboardViewAll));
      }
      expect(tester.takeException(), isNull);
      if (Platform.environment['UPDATE_DASHBOARD_PREVIEWS'] == '1') {
        await tester.runAsync(() async {
          final full = await tester
              .renderObject<RenderRepaintBoundary>(find.byKey(_preview))
              .toImage(pixelRatio: 1);
          final cropHeight =
              height.toInt() - 24 - (action == 'search' ? 315 : 40);
          final recorder = ui.PictureRecorder();
          Canvas(recorder).drawImageRect(
            full,
            Rect.fromLTWH(0, 24, 375, cropHeight.toDouble()),
            Rect.fromLTWH(0, 0, 375, cropHeight.toDouble()),
            Paint(),
          );
          final picture = recorder.endRecording();
          final image = await picture.toImage(375, cropHeight);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final directory = Directory('build/previews/dashboard');
          await directory.create(recursive: true);
          await File('${directory.path}/$name.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
          picture.dispose();
          full.dispose();
        });
      }
      debugDisableShadows = shadows;
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
  testWidgets(
    'typing hint and moving glow preserve user input and respect reduced motion',
    (tester) async {
      Widget subject({bool reduce = false}) => app(
        BlocProvider(
          create: (_) => HomeCubit(),
          child: const Scaffold(body: DashboardResoBanner()),
        ),
        reduceMotion: reduce,
      );
      await tester.pumpWidget(subject());
      await tester.pump();
      final field = find.byType(TextField);
      String? hint() => tester.widget<TextField>(field).decoration?.hintText;
      final start = hint();
      final glow = dashboardImagePosition(
        '${AppConstants.baseImage}dashboard_glow_large.svg',
      );
      final startX = tester.widget<Positioned>(glow).left;
      await tester.pump(const Duration(milliseconds: 450));
      expect(hint(), isNot(start));
      await tester.pump(const Duration(seconds: 3));
      expect(tester.widget<Positioned>(glow).left, isNot(startX));
      await tester.enterText(field, 'سوال خودم');
      await tester.pump(const Duration(seconds: 12));
      expect(tester.widget<TextField>(field).controller!.text, 'سوال خودم');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(subject(reduce: true));
      await tester.pump();
      final reducedHint = hint();
      final reducedX = tester.widget<Positioned>(glow).left;
      await tester.pump(const Duration(seconds: 6));
      expect(hint(), reducedHint);
      expect(tester.widget<Positioned>(glow).left, reducedX);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'background layers travel and return while foreground bounds stay fixed',
    (tester) async {
      const preview = Key('reso_motion_preview');
      await tester.pumpWidget(
        app(
          BlocProvider(
            create: (_) => HomeCubit(),
            child: const Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: RepaintBoundary(
                  key: preview,
                  child: SizedBox(width: 343, child: DashboardResoBanner()),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.runAsync(() async {
        final context = tester.element(find.byType(DashboardResoBanner));
        await precacheImage(
          const AssetImage('${AppConstants.baseImage}dashboard_reso.png'),
          context,
        );
        await precacheImage(
          const AssetImage('${AppConstants.baseImage}dashboard_texture.png'),
          context,
        );
      });
      await tester.pump();
      final person = dashboardImagePosition(
        '${AppConstants.baseImage}dashboard_reso.png',
      );
      final caption = find
          .ancestor(
            of: find.text(S.current.dashboardResoTitle),
            matching: find.byType(Positioned),
          )
          .first;
      final field = find.byType(AppTextField);
      final large = dashboardImagePosition(
        '${AppConstants.baseImage}dashboard_glow_large.svg',
      );
      final small = dashboardImagePosition(
        '${AppConstants.baseImage}dashboard_glow_small.svg',
      );
      final overlay = dashboardImagePosition(
        '${AppConstants.baseImage}dashboard_reso_overlay.svg',
      );
      final fixed = [
        tester.getRect(person),
        tester.getRect(caption),
        tester.getRect(field),
      ];
      final initial = [
        tester.widget<Positioned>(large).left!,
        tester.widget<Positioned>(small).left!,
        tester.widget<Positioned>(overlay).left!,
      ];
      Future<void> capture(String name) async {
        if (!const bool.fromEnvironment('UPDATE_RESO_MOTION_PREVIEWS')) return;
        tester.binding.buildOwner!.reassemble(tester.binding.rootElement!);
        await tester.pump();
        await tester.runAsync(() async {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(preview),
          );
          final warm = await boundary.toImage(pixelRatio: 2);
          warm.dispose();
          await Future<void>.delayed(const Duration(milliseconds: 50));
          final image = await boundary.toImage(pixelRatio: 2);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          final folder = Directory('build/previews/reso-background');
          await folder.create(recursive: true);
          await File('${folder.path}/$name.png')
              .writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }

      await capture('rest');
      for (final name in ['outbound', 'midpoint', 'inbound', 'returned']) {
        await tester.pump(const Duration(milliseconds: 1875));
        expect([
          tester.getRect(person),
          tester.getRect(caption),
          tester.getRect(field),
        ], fixed);
        if (name == 'midpoint') {
          final glowRect = tester.getRect(large);
          final bannerRect = tester.getRect(
            find
                .descendant(
                  of: find.byType(DashboardResoBanner),
                  matching: find.byWidgetPredicate(
                    (widget) => widget is SizedBox && widget.height != null,
                  ),
                )
                .first,
          );
          expect(
            glowRect.center.dx,
            greaterThanOrEqualTo(bannerRect.center.dx),
          );
          expect(
            tester.widget<Positioned>(large).left,
            greaterThan(initial[0]),
          );
          expect(tester.widget<Positioned>(small).left, lessThan(initial[1]));
          expect(
            tester.widget<Positioned>(overlay).left,
            greaterThan(initial[2]),
          );
        }
        await capture(name);
      }
      expect(tester.widget<Positioned>(large).left, closeTo(initial[0], .001));
      expect(tester.widget<Positioned>(small).left, closeTo(initial[1], .001));
      // Other background layers retain their separate nine-second period.
      await tester.pump(const Duration(milliseconds: 1500));
      expect(
        tester.widget<Positioned>(overlay).left,
        closeTo(initial[2], .001),
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
