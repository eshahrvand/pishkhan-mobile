import 'package:flutter_localizations/flutter_localizations.dart';

import 'dart:io';
import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../support/router_test_app.dart';

// Used only for capturing the entire application, including route overlays.
final walletPreviewKey = GlobalKey();
Future<void> loadWalletFonts() async {
  final loader = FontLoader(AppTypography.defaultFontFamily);
  for (final face in ['Regular', 'Medium', 'DemiBold', 'Bold', 'Light']) {
    loader.addFont(
      rootBundle.load('packages/avp_ui/assets/fonts/IRANYekanXFaNum-$face.ttf'),
    );
  }
  await loader.load();
  await (FontLoader(
    'CertificateLatin',
  )..addFont(rootBundle.load('assets/fonts/Roboto-Latin.ttf'))).load();
}

Future<void> mountWallet(
  WidgetTester tester,
  Widget screen, {
  Size size = const Size(375, 812),
  String locale = 'fa',
  double scale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 24, bottom: 40);
  tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 40);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    RepaintBoundary(
      key: walletPreviewKey,
      child: TestRouterApp(
        home: screen,
        theme: AppTheme.light(),
        locale: Locale(locale),
        supportedLocales: S.delegate.supportedLocales,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> captureWallet(WidgetTester tester, String name) async {
  if (Platform.environment['CAPTURE_WALLET_PREVIEWS'] != '1') return;
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 150)),
  );
  await tester.pumpAndSettle();
  final boundary =
      walletPreviewKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final warm = await boundary.toImage();
    warm.dispose();
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('build/previews/wallet/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}
