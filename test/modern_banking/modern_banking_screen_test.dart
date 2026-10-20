import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/features/modern_banking/data/repositories/mock_modern_banking_repository.dart';
import 'package:pishkhan_mobile/features/modern_banking/domain/entities/mobile_bank.dart';
import 'package:pishkhan_mobile/features/modern_banking/domain/repositories/modern_banking_repository.dart';
import 'package:pishkhan_mobile/features/modern_banking/presentation/mobile_bank/cubit/mobile_bank_cubit.dart';
import 'package:pishkhan_mobile/features/modern_banking/presentation/mobile_bank/screens/mobile_bank_screen.dart';
import 'package:pishkhan_mobile/features/modern_banking/presentation/password_guide/cubit/mobile_bank_guide_cubit.dart';
import 'package:pishkhan_mobile/features/modern_banking/presentation/password_guide/screens/mobile_bank_guide_screen.dart';
import 'package:pishkhan_mobile/features/modern_banking/presentation/deactivation/screens/mobile_bank_deactivation_screen.dart';
import 'package:pishkhan_mobile/features/modern_banking/presentation/transfer_limits/screens/mobile_bank_limits_screen.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/deposit_request_footer.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/flow_exit_dialog.dart';

import '../deposits/certificate_test_support.dart';

Future<void> captureModern(WidgetTester tester, String name) async {
  final context = tester.element(find.byType(MaterialApp));
  final images = tester.widgetList<AvpImage>(find.byType(AvpImage)).toList();
  await tester.runAsync(() async {
    await Future.wait(
      images.where((widget) => widget.image != null).map((widget) async {
        if (widget.image!.endsWith('.svg')) {
          await SvgAssetLoader(
            widget.image!,
            packageName: widget.package,
          ).loadBytes(context);
        } else {
          await precacheImage(
            AssetImage(widget.image!, package: widget.package),
            context,
          );
        }
      }),
    );
  });
  await tester.pumpAndSettle();
  // SVG picture decoding completes outside the fake test clock after byte loading.
  // Give both the FutureBuilder and its vector renderer a frame before capture.
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 120)),
  );
  await tester.pumpAndSettle();
  await captureCertificate(tester, name);
}

Future<void> tapLabel(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(AppButton, label).last);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadCertificateFonts);
  setUp(() {
    getIt.registerSingleton<ModernBankingRepository>(
      MockModernBankingRepository(),
    );
  });
  tearDown(() => getIt.reset());

  testWidgets(
    'activation UI progresses, blocks duplicate submission and returns pending',
    (tester) async {
      await mountCertificate(tester, const MobileBankScreen());
      expect(find.text(S.current.modernActivationIntro), findsOneWidget);
      await captureModern(tester, 'modern_activation_intro');
      await tapLabel(tester, S.current.modernActivate);
      await captureModern(tester, 'modern_activation_serial_empty');
      expect(
        tester
            .widget<AppButton>(
              find.widgetWithText(AppButton, S.current.issuanceNext),
            )
            .onPressed,
        isNull,
      );
      await tester.enterText(find.byType(TextField), '۳R۱۲۳۴۵۶۷۸');
      await tester.pumpAndSettle();
      await captureModern(tester, 'modern_activation_serial_filled');
      await tapLabel(tester, S.current.issuanceNext);
      await captureModern(tester, 'modern_activation_payment');
      await tester.tap(find.byType(AppCheckbox));
      await tester.pumpAndSettle();
      await tapLabel(tester, S.current.issuanceNext);
      await captureModern(tester, 'modern_activation_instruction');
      await tapLabel(tester, S.current.passwordStartKyc);
      expect(find.text(S.current.modernPreviewNotice), findsOneWidget);
      await captureModern(tester, 'modern_activation_preview');
      await tester.tap(
        find.widgetWithText(AppButton, S.current.passwordSubmit),
      );
      await tester.pump();
      final pendingFinder = find.byWidgetPredicate(
        (widget) =>
            widget is AppButton && widget.label == S.current.passwordSubmit,
      );
      final pendingButton = tester.widget<AppButton>(pendingFinder);
      expect(pendingButton.isLoading, isTrue);
      await tester.tap(pendingFinder);
      await tester.pumpAndSettle();
      expect(
        find.text(S.current.passwordStatusRegisteredTitle),
        findsOneWidget,
      );
      final cubit = tester
          .element(find.text(S.current.passwordStatusRegisteredTitle))
          .read<MobileBankCubit>();
      expect(cubit.state.submissionStatus, RequestStatus.success);
      await captureModern(tester, 'modern_activation_receipt');
      await tester.pumpWidget(const SizedBox.shrink());
      await mountCertificate(tester, const MobileBankScreen());
      expect(find.text(S.current.modernAwaitingIdentity), findsOneWidget);
      expect(find.text(S.current.modernActivate), findsNothing);
      await captureModern(tester, 'modern_activation_pending');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'recovery starts with serial and uses its own request lifecycle',
    (tester) async {
      await mountCertificate(
        tester,
        const MobileBankScreen(operation: MobileBankOperation.passwordRecovery),
      );
      expect(find.text(S.current.modernRecoveryTitle), findsOneWidget);
      await captureModern(tester, 'modern_recovery_serial_empty');
      await tester.enterText(find.byType(TextField), '3R12345678');
      await tester.pumpAndSettle();
      await captureModern(tester, 'modern_recovery_serial_filled');
      await tapLabel(tester, S.current.issuanceNext);
      await tester.tap(find.byType(AppCheckbox));
      await tester.pumpAndSettle();
      await captureModern(tester, 'modern_recovery_payment');
      await tapLabel(tester, S.current.issuanceNext);
      await captureModern(tester, 'modern_recovery_instruction');
      await tapLabel(tester, S.current.passwordStartKyc);
      await captureModern(tester, 'modern_recovery_preview');
      await tapLabel(tester, S.current.passwordSubmit);
      await captureModern(tester, 'modern_recovery_receipt');
      expect(find.text(S.current.passwordTracking), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'approved service shows username and all four operation entries',
    (tester) async {
      await getIt.unregister<ModernBankingRepository>();
      getIt.registerSingleton<ModernBankingRepository>(
        MockModernBankingRepository(
          activationStatus: MobileBankRequestStatus.approved,
        ),
      );
      await mountCertificate(tester, const MobileBankScreen());
      expect(find.text('123456789'), findsOneWidget);
      expect(find.text(S.current.passwordForgot), findsOneWidget);
      expect(find.text(S.current.passwordChange), findsOneWidget);
      expect(find.text(S.current.modernLimitsTitle), findsOneWidget);
      expect(find.text(S.current.modernDeactivate), findsOneWidget);
      await captureModern(tester, 'modern_activation_approved');
      await tester.tap(find.text(S.current.modernLimitsTitle));
      await tester.pumpAndSettle();
      expect(find.byType(MobileBankLimitsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('system Back changes stages and dismissal keeps entered data', (
    tester,
  ) async {
    await mountCertificate(tester, const MobileBankScreen());
    await tapLabel(tester, S.current.modernActivate);
    await tester.enterText(find.byType(TextField), '3R12345678');
    await tester.pumpAndSettle();
    await tapLabel(tester, S.current.issuanceNext);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '3R12345678',
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text(S.current.modernActivate), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tapLabel(tester, S.current.passwordStay);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text(S.current.modernActivate), findsOneWidget);
  });

  testWidgets('guide indicator follows swipes and indicator taps', (
    tester,
  ) async {
    await mountCertificate(tester, const MobileBankGuideScreen());
    await captureModern(tester, 'modern_password_guide_1');
    await tester.drag(find.byType(PageView), const Offset(300, 0));
    await tester.pumpAndSettle();
    final cubit = tester
        .element(find.byType(PageView))
        .read<MobileBankGuideCubit>();
    expect(cubit.state.page, 1);
    await captureModern(tester, 'modern_password_guide_2');
    await tester.drag(find.byType(PageView), const Offset(300, 0));
    await tester.pumpAndSettle();
    expect(cubit.state.page, 2);
    await captureModern(tester, 'modern_password_guide_3');
    await tester.tap(find.bySemanticsLabel(S.current.modernGuidePage(4)));
    await tester.pumpAndSettle();
    expect(cubit.state.page, 3);
    await captureModern(tester, 'modern_password_guide_4');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'assistant asks before discarding serial and Stay preserves the form',
    (tester) async {
      await mountCertificate(tester, const MobileBankScreen());
      await tapLabel(tester, S.current.modernActivate);
      await tester.enterText(find.byType(TextField), '3R12345678');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AppAssistantButton));
      await tester.pumpAndSettle();
      expect(find.byType(FlowExitDialog), findsOneWidget);
      await tapLabel(tester, S.current.passwordStay);
      expect(find.byType(FlowExitDialog), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '3R12345678',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'deactivation username cannot be edited and consent gates submission',
    (tester) async {
      await mountCertificate(tester, const MobileBankDeactivationScreen());
      expect(
        tester.widget<AppTextField>(find.byType(AppTextField)).readOnly,
        isTrue,
      );
      expect(
        tester.widget<AppTextField>(find.byType(AppTextField)).onChanged,
        isNull,
      );
      expect(
        tester
            .widget<DepositRequestFooter>(find.byType(DepositRequestFooter))
            .onSubmit,
        isNull,
      );
      await captureModern(tester, 'modern_deactivation_empty');
      await tester.tap(find.byType(AppSelect<DeactivationReason>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.modernCompromised).last);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AppCheckbox));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<DepositRequestFooter>(find.byType(DepositRequestFooter))
            .onSubmit,
        isNotNull,
      );
      await captureModern(tester, 'modern_deactivation_filled');
      await tapLabel(tester, S.current.passwordChangeSubmit);
      expect(find.text(S.current.modernDeactivationSaved), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'transfer limits switch to edit, normalize digits and validate maxima',
    (tester) async {
      await mountCertificate(tester, const MobileBankLimitsScreen());
      expect(
        tester.widget<AppTextField>(find.byType(AppTextField).first).readOnly,
        isTrue,
      );
      await captureModern(tester, 'modern_limits_current');
      await tapLabel(tester, S.current.modernEdit);
      await captureModern(tester, 'modern_limits_edit');
      await tester.enterText(find.byType(TextField).first, '۲۰۰۰۰۰۰۰۰۱');
      await tester.pumpAndSettle();
      expect(find.text(S.current.modernLimitError), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, '۱۵۰۰۰۰۰۰');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AppCheckbox));
      await tester.pumpAndSettle();
      await tapLabel(tester, S.current.passwordChangeSubmit);
      expect(find.text(S.current.modernLimitsSaved), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final locale in ['en', 'ar']) {
    testWidgets('guide supports $locale at narrow width and large text', (
      tester,
    ) async {
      await mountCertificate(
        tester,
        const MobileBankGuideScreen(),
        locale: locale,
        size: const Size(320, 700),
        scale: 1.4,
      );
      expect(find.byType(PageView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
