import 'dart:io';
import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/router/card_features_navigation.dart';
import 'package:pishkhan_mobile/features/password_services/password_services.dart';
import 'package:pishkhan_mobile/features/password_services/presentation/cubit/second_password_cubit.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_invoice.dart';

import 'second_password_cubit_test.dart'
    show ControlledPasswordRepository, select, readyToSubmit;

void main() {
  setUpAll(() async {
    final loader = FontLoader(AppTypography.defaultFontFamily);
    for (final face in ['Regular', 'Medium', 'DemiBold', 'Bold']) {
      loader.addFont(
        rootBundle.load(
          'packages/avp_ui/assets/fonts/IRANYekanXFaNum-$face.ttf',
        ),
      );
    }
    await loader.load();
  });
  const preview = Key('password_preview');
  Widget subject(
    Widget child, {
    Locale locale = const Locale('fa'),
    double scale = 1,
  }) => RepaintBoundary(
    key: preview,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: locale,
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
      home: child,
    ),
  );
  Future<void> mount(
    WidgetTester t, {
    PasswordServicesRepository? repository,
    Size size = const Size(375, 812),
    double scale = 1,
    Locale locale = const Locale('fa'),
  }) async {
    t.view.physicalSize = size;
    t.view.devicePixelRatio = 1;
    t.view.padding = const FakeViewPadding(top: 24, bottom: 40);
    t.view.viewPadding = const FakeViewPadding(top: 24, bottom: 40);
    addTearDown(t.view.reset);
    await t.pumpWidget(
      subject(
        SecondPasswordScreen(repository: repository),
        scale: scale,
        locale: locale,
      ),
    );
    await t.runAsync(() async {
      for (final path in [
        'assets/images/password_instruction.png',
        'assets/images/password_recording.png',
      ]) {
        await precacheImage(
          AssetImage(path),
          t.element(find.byType(SecondPasswordScreen)),
        );
      }
    });
    await t.pumpAndSettle();
  }

  SecondPasswordCubit c(WidgetTester t) => t
      .element(
        find.byType(BlocConsumer<SecondPasswordCubit, SecondPasswordState>),
      )
      .read<SecondPasswordCubit>();
  Future<void> tap(WidgetTester t, String key) async {
    await t.tap(find.byKey(Key(key)));
    await t.pumpAndSettle();
  }

  Future<void> save(WidgetTester t, String name) async {
    await t.pumpAndSettle();
    if (!const bool.fromEnvironment('UPDATE_PASSWORD_PREVIEWS')) return;
    t.binding.buildOwner!.reassemble(t.binding.rootElement!);
    await t.pumpAndSettle();
    await t.runAsync(() async {
      final boundary = t.renderObject<RenderRepaintBoundary>(
        find.byKey(preview),
      );
      // Warm the raster cache before capturing retained text/icon layers.
      final warmup = await boundary.toImage(pixelRatio: 2);
      warmup.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final image = await boundary.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final folder = Directory('doc/password-services-review');
      await folder.create(recursive: true);
      await File('${folder.path}/$name.png')
          .writeAsBytes(data!.buffer.asUint8List());
      image.dispose();
    });
  }

  for (final frame in [
    'selection-empty',
    'card-types',
    'card-numbers',
    'password-types',
    'selection-filled',
    'pending',
    'password-empty',
    'password-filled',
    'serial-empty',
    'serial-filled',
    'instruction',
    'recording',
    'submitted',
    'approved',
  ]) {
    testWidgets('renders $frame with authored geometry', (t) async {
      final r = ControlledPasswordRepository();
      if (frame == 'pending' || frame == 'approved') {
        r.current = PasswordRequestRecord(
          status: frame == 'pending'
              ? PasswordRequestStatus.pending
              : PasswordRequestStatus.approved,
          trackingCode: '98649466583',
        );
      }
      await mount(t, repository: r);
      final controller = c(t);
      if (frame == 'card-types') await tap(t, 'password_card_kind');
      if (frame == 'card-numbers') {
        controller.selectKind(PasswordCardKind.resalat);
        await t.pump();
        await tap(t, 'password_card_number');
      }
      if (frame == 'password-types') await tap(t, 'password_type');
      if (![
        'selection-empty',
        'card-types',
        'card-numbers',
        'password-types',
      ].contains(frame)) {
        select(controller);
        await t.pump();
        if (frame != 'selection-filled') {
          await controller.next();
          await t.pumpAndSettle();
        }
        if ([
          'password-filled',
          'serial-empty',
          'serial-filled',
          'instruction',
          'recording',
          'submitted',
        ].contains(frame)) {
          controller.passwordChanged('829164');
          controller.confirmationChanged('829164');
          controller.acceptTerms(true);
          await t.pump();
          // Inputs hold actual editing controllers; remount the form after state seeding.
          if (frame == 'password-filled') {
            controller.back();
            await t.pump();
            await controller.next();
            await t.pumpAndSettle();
          } else {
            await controller.next();
            await t.pump();
          }
        }
        if ([
          'serial-filled',
          'instruction',
          'recording',
          'submitted',
        ].contains(frame)) {
          controller.serialChanged('3R12345678');
          await t.pump();
          if (frame == 'serial-filled') {
            controller.back();
            await t.pump();
            await controller.next();
            await t.pump();
          } else {
            await controller.next();
            await t.pumpAndSettle();
          }
        }
        if (['recording', 'submitted'].contains(frame)) {
          await controller.next();
          await t.pumpAndSettle();
        }
        if (frame == 'submitted') {
          controller.confirmMockRecording();
          await controller.submit();
          await t.pumpAndSettle();
        }
      }
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(
        Directionality.of(t.element(find.byType(SecondPasswordScreen))),
        TextDirection.rtl,
      );
      if (frame == 'selection-empty') {
        expect(
          t.getTopLeft(find.byKey(const Key('password_card_kind'))).dy,
          144,
        );
        expect(t.getTopLeft(find.byKey(const Key('password_next'))).dy, 712);
        expect(
          t.widget<AppButton>(find.byKey(const Key('password_next'))).onPressed,
          isNull,
        );
      }
      if (frame == 'selection-filled') {
        final invoice = t.widget<AppInvoice>(find.byType(AppInvoice));
        expect(invoice.borderRadius, BorderRadius.zero);
        expect(invoice.zeroHeightDividers, true);
        expect(t.getTopLeft(find.byType(AppInvoice)).dy, 524);
        expect(t.getSize(find.byType(AppInvoice)).height, 130);
      }
      if (frame == 'card-types') {
        expect(
          t.getTopLeft(find.byKey(const Key('app_bottom_sheet_header'))).dy,
          440,
        );
      }
      if (frame == 'instruction') {
        expect(t.getSize(find.byType(AppVideoPlayer)), const Size(343, 343));
        expect(t.getTopLeft(find.byType(AppVideoPlayer)).dy, 164);
      }
      if (frame == 'pending') {
        expect(
          find.text('شما یک درخواست اعتبارسنجی باز دارید'),
          findsOneWidget,
        );
      }
      if (frame == 'approved') {
        expect(find.text('درخواست شما با موفقیت انجام شد'), findsOneWidget);
      }
      await save(t, frame);
    });
  }
  testWidgets(
    'connected selectors, secure inputs, normalization, serial, mock KYC and receipt',
    (t) async {
      await mount(t, repository: ControlledPasswordRepository());
      await tap(t, 'password_card_kind');
      await tap(t, 'password_option_PasswordCardKind.resalat');
      await tap(t, 'password_card_number');
      await tap(t, 'password_option_password-card-1');
      await tap(t, 'password_type');
      await tap(t, 'password_option_second');
      await tap(t, 'password_next');
      Future<void> enter(String key, String value) async {
        await t.enterText(
          find.descendant(
            of: find.byKey(Key(key)),
            matching: find.byType(TextField),
          ),
          value,
        );
        await t.pump();
      }

      await enter('password_value', '۸۲۹۱۶۴');
      await enter('password_confirmation', '٨٢٩١٦٤');
      final password = t.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('password_value')),
          matching: find.byType(TextField),
        ),
      );
      expect(password.obscureText, true);
      expect(password.enableIMEPersonalizedLearning, false);
      await tap(t, 'password_terms');
      await tap(t, 'password_next');
      await enter('password_serial', '۳R۱۲۳۴۵۶۷۸');
      await tap(t, 'password_next');
      expect(find.byType(AppVideoPlayer), findsOneWidget);
      await tap(t, 'password_next');
      expect(
        t.widget<AppButton>(find.byKey(const Key('password_next'))).onPressed,
        isNull,
      );
      await tap(t, 'password_confirm_mock');
      await tap(t, 'password_next');
      expect(find.byKey(const Key('password_tracking')), findsOneWidget);
      expect(c(t).state.password, '');
      expect(
        find.text(
          'این نتیجه آزمایشی است؛ رمز بانکی تنظیم نشده و پیامکی ارسال نمی‌شود.',
        ),
        findsOneWidget,
      );
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('retry, empty and system back are usable', (t) async {
    final r = ControlledPasswordRepository()
      ..catalog = PasswordCatalog(cards: []);
    await mount(t, repository: r);
    expect(find.text('کارتی برای نمایش وجود ندارد.'), findsNothing);
    r.catalog = MockPasswordServicesRepository.sampleCatalog;
    await t.tap(find.byKey(const Key('password_retry')));
    await t.pumpAndSettle();
    select(c(t));
    await c(t).next();
    await t.pumpAndSettle();
    await t.binding.handlePopRoute();
    await t.pumpAndSettle();
    expect(c(t).state.step, SecondPasswordStep.selection);
    expect(t.takeException(), isNull);
  });
  for (final locale in ['fa', 'en', 'ar']) {
    testWidgets('narrow and large-text $locale keeps controls reachable', (
      t,
    ) async {
      await mount(
        t,
        repository: ControlledPasswordRepository(),
        size: const Size(320, 700),
        scale: 1.3,
        locale: Locale(locale),
      );
      await readyToSubmit(c(t));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      await t.ensureVisible(find.byKey(const Key('password_confirm_mock')));
      await t.pump();
      expect(find.byKey(const Key('password_next')), findsOneWidget);
    });
  }
  testWidgets(
    'allowlist routes password entry and excludes forgotten/first PIN features',
    (t) async {
      await t.pumpWidget(
        subject(
          Builder(
            builder: (context) => Scaffold(
              body: AppButton(
                label: 'Open',
                onPressed: () => openCardFeaturesService(
                  context,
                  'card-pin-second-set',
                  initialCardNumber: '5041721456783407',
                ),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('Open'));
      await t.pumpAndSettle();
      expect(find.byType(SecondPasswordScreen), findsOneWidget);
      expect(c(t).state.cardId, 'password-card-1');
      expect(
        openCardFeaturesService(
          t.element(find.byType(SecondPasswordScreen)),
          'card-pin-first-change',
        ),
        false,
      );
      expect(
        openCardFeaturesService(
          t.element(find.byType(SecondPasswordScreen)),
          'card-pin-second-forgot',
        ),
        false,
      );
    },
  );
}
