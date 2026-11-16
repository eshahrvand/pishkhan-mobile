import 'dart:io';
import 'dart:ui' as ui;

import 'package:pishkhan_mobile/core/config/constant.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Test-only capture boundary includes root-navigator sheets.
final loanPreviewKey = GlobalKey();
Future<void> loadLoanFonts() async {
  final loader = FontLoader(AppTypography.defaultFontFamily);
  for (final face in ['Regular', 'Medium', 'DemiBold', 'Bold', 'Light']) {
    loader.addFont(
      rootBundle.load('packages/avp_ui/assets/fonts/IRANYekanXFaNum-$face.ttf'),
    );
  }
  await loader.load();
}

Future<void> captureLoan(WidgetTester tester, String name) async {
  if (Platform.environment['CAPTURE_LOAN_PREVIEWS'] != '1') return;
  await tester.runAsync(
    () => precacheImage(
      const AssetImage(
        '${AppConstants.baseImage}loan_request_video_poster.png',
      ),
      loanPreviewKey.currentContext!,
    ),
  );
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 150)),
  );
  await tester.pumpAndSettle();
  final boundary =
      loanPreviewKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final warm = await boundary.toImage();
    warm.dispose();
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('build/previews/loans/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}
