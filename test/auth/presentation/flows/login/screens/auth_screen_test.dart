import 'package:flutter_localizations/flutter_localizations.dart';

import '../../../../../support/auth_ui_finders.dart';
import '../../../../../support/router_test_app.dart';

import 'dart:io';
import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/screens/auth_screen.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
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
    AuthState state = const AuthState.initial(),
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
    await tester.pumpWidget(
      RepaintBoundary(
        key: previewKey,
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
          builder: (context, child) =>
              Directionality(textDirection: TextDirection.rtl, child: child!),
          home: AuthScreen(
            initialState: state,
            onAuthenticated: onAuthenticated,
            onGuestServiceRequested: onGuestServiceRequested,
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
    return tester
        .element(find.byType(BlocBuilder<AuthCubit, AuthState>).first)
        .read<AuthCubit>();
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
      final directory = Directory('build/previews/login');
      await directory.create(recursive: true);
      await File('${directory.path}/$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
      full.dispose();
      picture.dispose();
    });
  }

  const filled = AuthState.initial(
    nationalId: '0081234562',
    phone: '09121127934',
    captcha: '011759',
    formValid: true,
    maskedPhone: '0912*******34',
  );
  final loginOtp = filled.copyWith(
    step: AuthStep.loginOtp,
    isLoginForm: false,
    isOtp: true,
  );
  final changePhone = filled.copyWith(
    step: AuthStep.changePhone,
    isLoginForm: false,
    isChangePhone: true,
  );
  final changePhoneOtp = changePhone.copyWith(
    step: AuthStep.changePhoneOtp,
    isOtp: true,
  );
  final cases = <(String, AuthState)>[
    ('phase1-empty', const AuthState.initial()),
    ('phase1-filled', filled),
    ('phase1-wait-otp', loginOtp),
    ('phase1-enter-otp', loginOtp.copyWith(otp: '2345', otpValid: true)),
    (
      'phase3-empty',
      const AuthState.initial(
        step: AuthStep.changePhone,
        isLoginForm: false,
        isChangePhone: true,
      ),
    ),
    ('phase3-filled', changePhone),
    ('phase3-wait-otp', changePhoneOtp),
    ('phase3-enter-otp', changePhoneOtp.copyWith(otp: '2345', otpValid: true)),
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
      for (final input in tester.widgetList<TextField>(
        find.byType(TextField),
      )) {
        expect(input.textDirection, TextDirection.rtl);
        expect(input.textAlign, TextAlign.start);
      }
      expect(tester.getTopLeft(authControl(tester, 'auth_menu_button')).dy, 28);
      if (state.step == AuthStep.loginOtp ||
          state.step == AuthStep.changePhoneOtp) {
        expect(find.text('کد ارسال شد.'), findsOneWidget);
        final submit = authControl(tester, 'submit_otp_button');
        expect(tester.getSize(submit).height, 44);
        expect(tester.getTopLeft(submit).dy, 248);
        final otp = authControl(tester, '${state.step.name}-otp');
        expect(tester.getSize(otp).width, 188);
        expect(tester.getTopLeft(otp).dy, 180);
        await preview(tester, name);
        await tester.tap(submit);
        await tester.pump();
        expect(submitted, name.endsWith('enter-otp'));
      } else {
        final nationalId = authControl(
          tester,
          '${state.step.name}-national-id',
        );
        expect(tester.getSize(nationalId).height, 44);
        expect(
          tester.getTopLeft(nationalId).dy,
          (state.step == AuthStep.changePhone ||
                  state.step == AuthStep.changePhoneOtp)
              ? 200
              : 180,
        );
        expect(
          tester.getSize(authControl(tester, 'auth_captcha_image')).width,
          148,
        );
        final submit = authControl(tester, 'request_otp_button');
        expect(tester.getSize(submit).height, 40);
        expect(
          tester.getTopLeft(submit).dy,
          (state.step == AuthStep.changePhone ||
                  state.step == AuthStep.changePhoneOtp)
              ? 456
              : 412,
        );
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
      await tester.tap(authControl(tester, 'auth_menu_button'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final sheet = authControl(tester, 'auth_services_sheet');
      expect(tester.getTopLeft(sheet).dy, 246);
      expect(tester.getSize(sheet).height, 528);
      expect(find.text('نکات امنیتی'), findsOneWidget);
      expect(find.text('راهنمای بروزرسانی'), findsOneWidget);
      await preview(tester, 'phase2-guest-services', keyboard: false);
      await tester.tap(find.text('گزارش تمکن'));
      await tester.pumpAndSettle();
      expect(selected, 'deposits.assetReport');
      expect(authControl(tester, 'auth_services_sheet'), findsNothing);
      debugDisableShadows = priorShadowSetting;
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'identity errors appear from the first digit and clear on valid input',
    (tester) async {
      final cubit = await mount(tester, keyboard: false);
      final national = find.descendant(
        of: authControl(tester, 'login-national-id'),
        matching: find.byType(TextField),
      );
      final phone = find.descendant(
        of: authControl(tester, 'login-phone'),
        matching: find.byType(TextField),
      );
      expect(cubit.state.isNationalIdError, isFalse);
      expect(cubit.state.isPhoneError, isFalse);

      await tester.enterText(national, '۰');
      await tester.pump();
      expect(cubit.state.isNationalIdError, isTrue);
      expect(find.text(S.current.authInvalidNationalId), findsOneWidget);
      await tester.enterText(national, '۰۰۸۱۲۳۴۵۶۲');
      await tester.pump();
      expect(cubit.state.isNationalIdError, isFalse);
      expect(find.text(S.current.authInvalidNationalId), findsNothing);

      await tester.enterText(phone, '۰');
      await tester.pump();
      expect(cubit.state.isPhoneError, isTrue);
      expect(find.text(S.current.authInvalidPhone), findsOneWidget);
      await tester.enterText(phone, '۰۹۱۲۱۱۲۷۹۳۴');
      await tester.pump();
      expect(cubit.state.isPhoneError, isFalse);
      expect(find.text(S.current.authInvalidPhone), findsNothing);
      await tester.enterText(phone, '۰۹');
      await tester.pump();
      expect(cubit.state.isPhoneError, isTrue);
      expect(find.text(S.current.authInvalidPhone), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'normalizes Persian input, validates submission and preserves fields on back',
    (tester) async {
      final cubit = await mount(tester);
      await tester.tap(authControl(tester, 'request_otp_button'));
      await tester.pumpAndSettle();
      expect(
        [
          cubit.state.isNationalIdError,
          cubit.state.isPhoneError,
          cubit.state.isCaptchaError,
        ],
        [false, false, false],
      );
      for (final (field, value) in [
        ('national-id', '۰۰۸۱۲۳۴۵۶۲'),
        ('phone', '۰۹۱۲۱۱۲۷۹۳۴'),
        ('captcha', '۰۱۱۷۵۹'),
      ]) {
        final finder = find.descendant(
          of: authControl(tester, 'login-$field'),
          matching: find.byType(TextField),
        );
        await tester.ensureVisible(finder);
        await tester.enterText(finder, value);
      }
      await tester.pumpAndSettle();
      expect(cubit.state.nationalId, '0081234562');
      expect(
        [
          cubit.state.isNationalIdError,
          cubit.state.isPhoneError,
          cubit.state.isCaptchaError,
        ],
        [false, false, false],
      );
      await tester.ensureVisible(authControl(tester, 'request_otp_button'));
      await tester.tap(authControl(tester, 'request_otp_button'));
      await tester.pumpAndSettle();
      expect(cubit.state.step, AuthStep.loginOtp);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(cubit.state.step, AuthStep.login);
      expect(find.text('0081234562'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final changePhone in [false, true]) {
    testWidgets(
      'request OTP requires valid identity and complete captcha (changePhone: $changePhone)',
      (tester) async {
        final cubit = await mount(
          tester,
          keyboard: false,
          state: changePhone
              ? const AuthState.initial(
                  step: AuthStep.changePhone,
                  isLoginForm: false,
                  isChangePhone: true,
                )
              : const AuthState.initial(),
        );
        final step = changePhone ? 'changePhone' : 'login';
        final button = authControl(tester, 'request_otp_button');
        Finder input(String field) => find.descendant(
          of: authControl(tester, '$step-$field'),
          matching: find.byType(TextField),
        );
        void expectActive(bool active) {
          expect(tester.widget<AppButton>(button).isActive, active);
          expect(
            tester
                .widget<InkWell>(
                  find.descendant(of: button, matching: find.byType(InkWell)),
                )
                .onTap,
            active ? isNotNull : isNull,
          );
        }

        expectActive(false);
        await tester.tap(button);
        await tester.pump();
        expect(cubit.state.isOtp, isFalse);
        expect(cubit.state.isNationalIdError, isFalse);

        await tester.enterText(input('captcha'), '۱۲۳۴۵');
        await tester.enterText(input('national-id'), '۰۰۸۱۲۳۴۵۶۲');
        await tester.enterText(input('phone'), '۰۹۱۲۱۱۲۷۹۳۴');
        await tester.pump();
        expectActive(false);

        await tester.enterText(input('captcha'), '۱۲۳۴۵۶');
        await tester.pump();
        expectActive(true);

        await tester.enterText(input('national-id'), '۰۰۸۱۲۳۴۵۶۳');
        await tester.pump();
        expectActive(false);
        await tester.enterText(input('national-id'), '۰۰۸۱۲۳۴۵۶۲');
        await tester.pump();
        expectActive(true);

        await tester.enterText(input('phone'), '۰۸۱۲۱۱۲۷۹۳۴');
        await tester.pump();
        expectActive(false);
        await tester.enterText(input('phone'), '۰۹۱۲۱۱۲۷۹۳۴');
        await tester.pump();
        expectActive(true);

        cubit.refreshCaptcha();
        await tester.pump();
        expectActive(false);
        expect(cubit.state.captcha, isEmpty);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  test(
    'request OTP blocks keyboard or direct submission while loading',
    () async {
      final cubit = AuthCubit(
        initialState: filled.copyWith(status: RequestStatus.loading),
      );
      expect(cubit.requestOtp(), isFalse);
      expect(cubit.state.step, AuthStep.login);
      await cubit.close();
    },
  );

  testWidgets(
    'expired OTP clears on resend and change-phone back keeps entered values',
    (tester) async {
      final cubit = await mount(
        tester,
        state: changePhoneOtp.copyWith(otp: '2345', secondsRemaining: 0),
      );
      var submit = tester.widget<AppButton>(
        authControl(tester, 'submit_otp_button'),
      );
      expect(submit.onPressed, isNull);
      await tester.tap(authControl(tester, 'otp_timer_button'));
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
        state: const AuthState.initial(
          step: AuthStep.changePhone,
          isLoginForm: false,
          isChangePhone: true,
        ),
        onGuestServiceRequested: (id) => selected = id,
      );
      tester.view.physicalSize = const Size(320, 480);
      await tester.pumpAndSettle();
      await tester.ensureVisible(authControl(tester, 'request_otp_button'));
      expect(tester.takeException(), isNull);
      await tester.tap(authControl(tester, 'auth_menu_button'));
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
