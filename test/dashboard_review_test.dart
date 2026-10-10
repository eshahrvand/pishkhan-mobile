import 'dart:io';
import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/dashboard_screen.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_reso_banner.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';

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
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: const Locale('fa'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: Directionality(textDirection: TextDirection.rtl, child: child!),
      ),
      home: home,
    ),
  );
  Future<void> tap(WidgetTester tester, String key) async {
    final finder = find.byKey(Key(key));

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
      await tester.pumpWidget(
        app(
          DashboardScreen(initialFavorites: favorites, enableAnimations: false),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final context = tester.element(find.byType(DashboardScreen));
        await precacheImage(const AssetImage(AppAssets.dashboardReso), context);
        await precacheImage(
          const AssetImage(AppAssets.dashboardTexture),
          context,
        );
      });
      await tester.pumpAndSettle();
      if (action == 'edit' || action == 'reset') {
        await tap(tester, 'dashboard_customize');
      }
      if (action == 'reset') await tap(tester, 'dashboard_reset');
      if (action == 'sheet' || action == 'search') {
        await tap(tester, 'dashboard_menu_button');
      }
      if (action == 'search') {
        tester.view.viewInsets = const FakeViewPadding(bottom: 315);
        tester.view.padding = const FakeViewPadding(top: 24);
        await tester.enterText(
          find.descendant(
            of: find.byKey(const Key('dashboard_service_search')),
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
      if (action == 'all') await tap(tester, 'dashboard_all_services');
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
          final directory = Directory('doc/dashboard-review');
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
        const Scaffold(body: DashboardResoBanner()),
        reduceMotion: reduce,
      );
      await tester.pumpWidget(subject());
      await tester.pump();
      final field = find.byType(TextField);
      String? hint() => tester.widget<TextField>(field).decoration?.hintText;
      final start = hint();
      final glow = find.byKey(const Key('dashboard_banner_glow_large'));
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
          const Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: RepaintBoundary(
                key: preview,
                child: SizedBox(width: 343, child: DashboardResoBanner()),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.runAsync(() async {
        final context = tester.element(find.byType(DashboardResoBanner));
        await precacheImage(const AssetImage(AppAssets.dashboardReso), context);
        await precacheImage(
          const AssetImage(AppAssets.dashboardTexture),
          context,
        );
      });
      await tester.pump();
      final person = find.byKey(const Key('dashboard_reso_foreground'));
      final caption = find.byKey(const Key('dashboard_reso_caption'));
      final field = find.byKey(const Key('dashboard_assistant_prompt'));
      final large = find.byKey(const Key('dashboard_banner_glow_large'));
      final small = find.byKey(const Key('dashboard_banner_glow_small'));
      final overlay = find.byKey(const Key('dashboard_reso_overlay'));
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
          final folder = Directory('doc/reso-background-review');
          await folder.create(recursive: true);
          await File('${folder.path}/$name.png')
              .writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }

      await capture('rest');
      for (final name in ['outbound', 'midpoint', 'inbound', 'returned']) {
        await tester.pump(const Duration(milliseconds: 2250));
        expect([
          tester.getRect(person),
          tester.getRect(caption),
          tester.getRect(field),
        ], fixed);
        if (name == 'midpoint') {
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
      expect(
        tester.widget<Positioned>(overlay).left,
        closeTo(initial[2], .001),
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
