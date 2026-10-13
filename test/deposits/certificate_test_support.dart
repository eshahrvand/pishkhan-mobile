import 'dart:io';
import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';

import '../support/router_test_app.dart';

// Used only for capturing the entire application, including route overlays.
final certificatePreviewKey = GlobalKey();
Future<void> loadCertificateFonts() async {
  final loader = FontLoader(AppTypography.defaultFontFamily);
  for (final face in ['Regular', 'Medium', 'DemiBold', 'Bold', 'Light']) {
    loader.addFont(
      rootBundle.load('packages/avp_ui/assets/fonts/IRANYekanXFaNum-$face.ttf'),
    );
  }
  await loader.load();
}

Future<void> mountCertificate(
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
      key: certificatePreviewKey,
      child: TestRouterApp(
        home: screen,
        theme: AppTheme.light(),
        locale: Locale(locale),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
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

Future<void> captureCertificate(WidgetTester tester, String name) async {
  if (Platform.environment['CAPTURE_CERTIFICATE_PREVIEWS'] != '1') return;
  final boundary =
      certificatePreviewKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final warm = await boundary.toImage();
    warm.dispose();
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('build/previews/certificates/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}
