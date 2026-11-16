import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_svg/flutter_svg.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/features/loans/data/repositories/mock_loan_application_repository.dart';
import 'package:pishkhan_mobile/features/loans/presentation/request/cubit/loan_request_cubit.dart';
import 'package:pishkhan_mobile/features/loans/presentation/request/widgets/loan_assessment.dart';
import 'package:pishkhan_mobile/features/loans/presentation/request/widgets/loan_credit_scale.dart';
import 'package:pishkhan_mobile/features/loans/presentation/request/widgets/loan_value_row.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import 'loan_preview_support.dart';
import 'loan_test_dependencies.dart';

void main() {
  setUpAll(loadLoanFonts);
  tearDown(() async {
    await getIt.reset();
  });
  for (final amount in [500000000, 1500000000, 2500000000, 3500000000]) {
    testWidgets(
      'native-width assessment renders amount $amount with measured design geometry',
      (tester) async {
        tester.view.physicalSize = const Size(375, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await installLoanDependencies(
          MockLoanApplicationRepository(delay: Duration.zero),
        );
        await S.load(const Locale('fa'));
        final cubit = LoanRequestCubit();
        await cubit.fetchCatalog();
        await cubit.continueFlow();
        await cubit.selectDeposit(cubit.state.catalog!.deposits.first);
        await cubit.updateAmount((amount - 1000000) / 4999000000);
        // This key measures/captures the entire scrollable form, without production keys.
        final captureKey = GlobalKey();
        await tester.pumpWidget(
          BlocProvider.value(
            value: cubit,
            child: MaterialApp(
              theme: AppTheme.light(),
              locale: const Locale('fa'),
              supportedLocales: S.delegate.supportedLocales,
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: Scaffold(
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: RepaintBoundary(
                      key: captureKey,
                      child: ColoredBox(
                        color: AppPalette.gray50,
                        child: LoanAssessment(state: cubit.state),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        // SVG source loads cross fake-time and real-isolate boundaries. Advance
        // both in bounded steps; awaiting a fake-time source Future in runAsync
        // would deadlock. Every image in this form is SVG, plus two thumb SVGs.
        final expectedPictures = find.byType(AvpImage).evaluate().length + 2;
        for (var frame = 0; frame < 20; frame++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 50)),
          );
          await tester.pump();
          if (find.byType(SvgPicture).evaluate().length >= expectedPictures) {
            break;
          }
        }
        expect(
          find.byType(SvgPicture).evaluate().length,
          greaterThanOrEqualTo(expectedPictures),
        );
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pumpAndSettle();
        final origin = tester.getTopLeft(find.byType(LoanAssessment));
        final field = find.widgetWithText(
          LoanValueRow,
          S.current.loanRequestAmount,
        );
        final months = find.widgetWithText(
          LoanValueRow,
          S.current.loanRequestMonths,
        );
        final monthly = find.widgetWithText(
          LoanValueRow,
          S.current.loanRequestMonthly,
        );
        expect(tester.getSize(field).height, 44);
        expect(tester.getSize(months).height, 44);
        expect(tester.getSize(monthly).height, 44);
        expect(tester.getSize(find.byType(LoanCreditScale)).height, 60);
        // Figma metadata: form x16/y172; amount y260, duration y400, monthly y540.
        expect((tester.getTopLeft(field) - origin).dy, closeTo(260, .1));
        expect((tester.getTopLeft(months) - origin).dy, closeTo(400, .1));
        expect((tester.getTopLeft(monthly) - origin).dy, closeTo(540, .1));
        if (amount == 500000000) {
          expect(tester.getSize(find.byType(LoanAssessment)).height, 1032);
        }
        expect(tester.takeException(), null);
        await tester.runAsync(() async {
          final boundary =
              captureKey.currentContext!.findRenderObject()
                  as RenderRepaintBoundary;
          final warm = await boundary.toImage();
          warm.dispose();
          final image = await boundary.toImage();
          final rgba = (await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!;
          List<int> pixelAt(int x, int y) => List.generate(
            4,
            (channel) => rgba.getUint8((y * image.width + x) * 4 + channel),
          );
          expect(pixelAt(5, 334), [
            50,
            213,
            131,
            255,
          ], reason: 'green guide is Figma success400');
          expect(pixelAt(338, 344), [
            249,
            112,
            102,
            255,
          ], reason: 'red guide remains Figma error400');
          expect(pixelAt(5, 545), [
            239,
            248,
            255,
            255,
          ], reason: 'monthly surface is Figma brand50');
          expect(pixelAt(8, 268), [
            253,
            253,
            253,
            255,
          ], reason: 'amount surface is Figma gray25');
          final chartSample = switch (amount) {
            500000000 => (10, [21, 112, 239, 255]),
            1500000000 => (125, [83, 177, 253, 255]),
            2500000000 => (240, [178, 221, 255, 255]),
            _ => (10, [254, 228, 226, 255]),
          };
          expect(
            pixelAt(chartSample.$1, 728),
            chartSample.$2,
            reason: 'selected assessment band uses its original Figma artwork',
          );
          if (Platform.environment['CAPTURE_LOAN_PREVIEWS'] == '1') {
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final file = File(
              'build/previews/loans/full_assessment_$amount.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes!.buffer.asUint8List());
          }
          image.dispose();
        });
        await tester.pumpWidget(const SizedBox());
        await cubit.close();
      },
    );
  }
}
