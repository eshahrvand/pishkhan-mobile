import 'dart:io';
import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/auth/presentation/auth_screen.dart';
import 'package:pishkhan_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';

const previewKey = Key('auth_preview');

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

  Future<AuthCubit> mount(
    WidgetTester tester, {
    AuthState state = const AuthState(),
    bool keyboard = true,
    VoidCallback? onAuthenticated,
    ValueChanged<String>? onGuestServiceRequested,
  }) async {
    tester.view.physicalSize = const Size(375, 814);
    tester.view.devicePixelRatio = 1;
    tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 40);
    tester.view.padding = FakeViewPadding(top: 24, bottom: keyboard ? 0 : 40);
    tester.view.viewInsets = FakeViewPadding(bottom: keyboard ? 315 : 0);
    addTearDown(tester.view.reset);
    final cubit = AuthCubit(initialState: state);
    await tester.pumpWidget(
      RepaintBoundary(
        key: previewKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          locale: const Locale('fa'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) =>
              Directionality(textDirection: TextDirection.rtl, child: child!),
          home: BlocProvider.value(
            value: cubit,
            child: AuthScreen(
              onAuthenticated: onAuthenticated,
              onGuestServiceRequested: onGuestServiceRequested,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final context = tester.element(find.byType(AuthScreen));
      await precacheImage(const AssetImage(AuthAssets.background), context);
      await precacheImage(const AssetImage(AuthAssets.captcha), context);
    });
    await tester.pumpAndSettle();
    addTearDown(cubit.close);
    return cubit;
  }

  Future<void> preview(
    WidgetTester tester,
    String name, {
    bool keyboard = true,
  }) async {
    if (Platform.environment['UPDATE_LOGIN_PREVIEWS'] != '1') return;
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(previewKey),
      );
      final full = await boundary.toImage(pixelRatio: 1);
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final height = keyboard ? 475 : 750;
      canvas.drawImageRect(
        full,
        Rect.fromLTWH(0, 24, 375, height.toDouble()),
        Rect.fromLTWH(0, 0, 375, height.toDouble()),
        Paint(),
      );
      final picture = recorder.endRecording();
      final image = await picture.toImage(375, height);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final directory = Directory('doc/login-review');
      await directory.create(recursive: true);
      await File('${directory.path}/$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
      full.dispose();
      picture.dispose();
    });
  }

  const filled = AuthState(
    nationalId: '0081234567',
    phone: '09121127934',
    captcha: '011759',
  );
  final cases = <(String, AuthState)>[
    ('phase1-empty', const AuthState()),
    ('phase1-filled', filled),
    ('phase1-wait-otp', filled.copyWith(step: AuthStep.loginOtp)),
    ('phase1-enter-otp', filled.copyWith(step: AuthStep.loginOtp, otp: '2345')),
    ('phase3-empty', const AuthState(step: AuthStep.changePhone)),
    ('phase3-filled', filled.copyWith(step: AuthStep.changePhone)),
    ('phase3-wait-otp', filled.copyWith(step: AuthStep.changePhoneOtp)),
    (
      'phase3-enter-otp',
      filled.copyWith(step: AuthStep.changePhoneOtp, otp: '2345'),
    ),
  ];

  for (final (name, state) in cases) {
    testWidgets('$name matches the frame layout and available actions', (
      tester,
    ) async {
      final priorShadowSetting = debugDisableShadows;
      debugDisableShadows = false;
      addTearDown(() => debugDisableShadows = priorShadowSetting);
      var submitted = false;
      await mount(
        tester,
        state: state,
        onAuthenticated: () => submitted = true,
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getTopLeft(find.byKey(const Key('auth_menu_button'))).dy,
        28,
      );
      if (state.isOtp) {
        expect(find.text('کد ارسال شد.'), findsOneWidget);
        final submit = find.byKey(const Key('submit_otp_button'));
        expect(tester.getSize(submit).height, 44);
        expect(tester.getTopLeft(submit).dy, 248);
        final otp = find.byKey(ValueKey('${state.step.name}-otp'));
        expect(tester.getSize(otp).width, 188);
        expect(tester.getTopLeft(otp).dy, 180);
        await preview(tester, name);
        await tester.tap(submit);
        await tester.pump();
        expect(submitted, state.isOtpValid);
      } else {
        final nationalId = find.byKey(
          ValueKey('${state.step.name}-national-id'),
        );
        expect(tester.getSize(nationalId).height, 44);
        expect(
          tester.getTopLeft(nationalId).dy,
          state.isChangePhone ? 200 : 180,
        );
        expect(
          tester.getSize(find.byKey(const Key('auth_captcha_image'))).width,
          148,
        );
        final submit = find.byKey(const Key('request_otp_button'));
        expect(tester.getSize(submit).height, 40);
        expect(tester.getTopLeft(submit).dy, state.isChangePhone ? 456 : 412);
        await preview(tester, name);
      }
      debugDisableShadows = priorShadowSetting;
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets(
    'phase2 guest sheet matches the layout and forwards service selections',
    (tester) async {
      final priorShadowSetting = debugDisableShadows;
      debugDisableShadows = false;
      addTearDown(() => debugDisableShadows = priorShadowSetting);
      String? selected;
      await mount(
        tester,
        keyboard: false,
        onGuestServiceRequested: (id) => selected = id,
      );
      await tester.tap(find.byKey(const Key('auth_menu_button')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final sheet = find.byKey(const Key('auth_services_sheet'));
      expect(tester.getTopLeft(sheet).dy, 246);
      expect(tester.getSize(sheet).height, 528);
      expect(find.text('نکات امنیتی'), findsOneWidget);
      expect(find.text('راهنمای بروزرسانی'), findsOneWidget);
      await preview(tester, 'phase2-guest-services', keyboard: false);
      await tester.tap(find.text('گزارش تمکن'));
      await tester.pumpAndSettle();
      expect(selected, 'deposits.assetReport');
      expect(find.byKey(const Key('auth_services_sheet')), findsNothing);
      debugDisableShadows = priorShadowSetting;
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'normalizes Persian input, validates submission and preserves fields on back',
    (tester) async {
      final cubit = await mount(tester);
      await tester.tap(find.byKey(const Key('request_otp_button')));
      await tester.pumpAndSettle();
      expect(cubit.state.invalidFields, {'nationalId', 'phone', 'captcha'});
      for (final (field, value) in [
        ('national-id', '۰۰۸۱۲۳۴۵۶۷'),
        ('phone', '۰۹۱۲۱۱۲۷۹۳۴'),
        ('captcha', '۰۱۱۷۵۹'),
      ]) {
        final finder = find.descendant(
          of: find.byKey(ValueKey('login-$field')),
          matching: find.byType(TextField),
        );
        await tester.ensureVisible(finder);
        await tester.enterText(finder, value);
      }
      await tester.pumpAndSettle();
      expect(cubit.state.nationalId, '0081234567');
      expect(cubit.state.invalidFields, isEmpty);
      await tester.ensureVisible(find.byKey(const Key('request_otp_button')));
      await tester.tap(find.byKey(const Key('request_otp_button')));
      await tester.pumpAndSettle();
      expect(cubit.state.step, AuthStep.loginOtp);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(cubit.state.step, AuthStep.login);
      expect(find.text('0081234567'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'expired OTP clears on resend and change-phone back keeps entered values',
    (tester) async {
      final cubit = await mount(
        tester,
        state: filled.copyWith(
          step: AuthStep.changePhoneOtp,
          otp: '2345',
          secondsRemaining: 0,
        ),
      );
      var submit = tester.widget<AppButton>(
        find.byKey(const Key('submit_otp_button')),
      );
      expect(submit.onPressed, isNull);
      await tester.tap(find.byKey(const Key('otp_timer_button')));
      await tester.pump();
      expect(cubit.state.otp, isEmpty);
      expect(cubit.state.secondsRemaining, 60);
      await tester.pump(const Duration(seconds: 60));
      expect(cubit.state.secondsRemaining, 0);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(cubit.state.step, AuthStep.changePhone);
      expect(find.text('09121127934'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(cubit.state.step, AuthStep.login);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'small viewports keep the phone form and last guest service reachable',
    (tester) async {
      String? selected;
      await mount(
        tester,
        keyboard: false,
        state: const AuthState(step: AuthStep.changePhone),
        onGuestServiceRequested: (id) => selected = id,
      );
      tester.view.physicalSize = const Size(320, 480);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('request_otp_button')));
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const Key('auth_menu_button')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('نکات امنیتی'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('نکات امنیتی'));
      await tester.pumpAndSettle();
      expect(selected, 'links.security');
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
