import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:pishkhan_mobile/features/loans/presentation/request/widgets/loan_credit_scale.dart';

import 'loan_preview_support.dart';

import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';
import 'package:pishkhan_mobile/features/loans/presentation/request/widgets/loan_installments_sheet.dart';
import 'package:pishkhan_mobile/features/loans/presentation/request/widgets/loan_guarantor_warning.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/loans/data/repositories/mock_loan_application_repository.dart';
import 'package:pishkhan_mobile/features/loans/domain/entities/loan_application.dart';
import 'package:pishkhan_mobile/features/loans/presentation/request/cubit/loan_request_cubit.dart';
import 'package:pishkhan_mobile/features/loans/presentation/request/screens/loan_request_screen.dart';
import 'package:pishkhan_mobile/features/loans/presentation/request/widgets/loan_assessment.dart';
import 'package:pishkhan_mobile/features/loans/presentation/request/widgets/loan_credit_status.dart';
import 'package:pishkhan_mobile/features/loans/presentation/request/widgets/loan_value_row.dart';
import 'package:pishkhan_mobile/features/loans/presentation/request/widgets/loan_contract_sheet.dart';
import 'package:pishkhan_mobile/features/loans/presentation/request/widgets/loan_otp_sheet.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import 'loan_test_dependencies.dart';

void main() {
  setUpAll(loadLoanFonts);
  tearDown(() async {
    await getIt.reset();
  });
  Future<GoRouter> mount(
    WidgetTester tester, {
    Size size = const Size(375, 812),
    LoanCreditTier tier = LoanCreditTier.excellent,
    MockLoanApplicationRepository? repository,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 40);
    tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 40);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await installLoanDependencies(
      repository ??
          MockLoanApplicationRepository(delay: Duration.zero, tier: tier),
    );
    final router = GoRouter(
      initialLocation: '/loans/request',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('home')),
        ),
        GoRoute(
          path: '/loans/request',
          builder: (_, _) => const LoanRequestScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      RepaintBoundary(
        key: loanPreviewKey,
        child: MaterialApp.router(
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          locale: const Locale('fa'),
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets(
    'entering red updates the visible tier immediately without waiting for quote',
    (tester) async {
      final repository = SlowQuoteRepository();
      final router = await mount(
        tester,
        repository: repository,
        size: const Size(375, 1600),
      );
      await tester.tap(
        find.widgetWithText(AppButton, S.current.loanRequestTitle),
      );
      await tester.pumpAndSettle();
      final flow = tester
          .element(find.byType(LoanAssessment))
          .read<LoanRequestCubit>();
      await flow.selectDeposit(flow.state.catalog!.deposits.first);
      await tester.pumpAndSettle();
      final confirmed = flow.state.quote;
      repository.delayQuotes = true;
      final slider = find.byType(AppSlider).first;
      await tester.ensureVisible(slider);
      await tester.pumpAndSettle();
      final origin = tester.getTopLeft(slider);
      final width = tester.getSize(slider).width;
      await tester.tapAt(origin + Offset(width * .9, 24));
      await tester.pump();
      await tester.pump();
      expect(flow.state.quoteStatus, RequestStatus.loading);
      expect(flow.state.quote, same(confirmed));
      expect(flow.state.assessment!.range, LoanCreditRange.unsuitable);
      final tier = tester.widget<LoanValueRow>(
        find.widgetWithText(LoanValueRow, S.current.loanRequestTier),
      );
      expect(tier.value, S.current.loanRequestUnsuitable);
      expect(tier.color, AppPalette.error500);
      expect(flow.state.canContinue, false);
      // The new range must already have its true color before the request
      // finishes, including the first use of an asynchronously compiled SVG.
      final chartPoint =
          tester.getTopLeft(find.byType(LoanCreditScale)) +
          const Offset(10, 30);
      await tester.runAsync(() async {
        final boundary =
            loanPreviewKey.currentContext!.findRenderObject()
                as RenderRepaintBoundary;
        final image = await boundary.toImage();
        final rgba = (await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        ))!;
        final offset =
            (chartPoint.dy.floor() * image.width + chartPoint.dx.floor()) * 4;
        expect(List.generate(4, (channel) => rgba.getUint8(offset + channel)), [
          254,
          228,
          226,
          255,
        ]);
        image.dispose();
      });
      final height = tester.getSize(find.byType(LoanAssessment)).height;
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(LoanAssessment)).height, height);
      expect(flow.state.quote!.range, LoanCreditRange.unsuitable);
      await tester.tapAt(origin + Offset(width * .1, 24));
      await tester.pump();
      await tester.pump();
      expect(flow.state.assessment!.range, LoanCreditRange.excellent);
      expect(flow.state.canContinue, false);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(flow.state.canContinue, true);
      expect(tester.takeException(), null);
      await tester.pumpWidget(const SizedBox());
      router.dispose();
    },
  );

  testWidgets(
    'slider refresh preserves assessment geometry and scroll offset',
    (tester) async {
      final repository = SlowQuoteRepository();
      final router = await mount(
        tester,
        size: const Size(320, 640),
        repository: repository,
      );
      await tester.tap(
        find.widgetWithText(AppButton, S.current.loanRequestTitle),
      );
      await tester.pumpAndSettle();
      final flow = tester
          .element(find.byType(LoanAssessment))
          .read<LoanRequestCubit>();
      await flow.selectDeposit(flow.state.catalog!.deposits.first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(AppSlider).last);
      await tester.pumpAndSettle();
      final scroll = tester
          .state<ScrollableState>(
            find
                .descendant(
                  of: find.byType(SingleChildScrollView),
                  matching: find.byType(Scrollable),
                )
                .first,
          )
          .position;
      final amountRect = tester.getRect(find.byType(AppSlider).first);
      final monthsRect = tester.getRect(find.byType(AppSlider).last);
      final creditRect = tester.getRect(find.byType(LoanCreditStatus));
      final height = tester.getSize(find.byType(LoanAssessment)).height;
      final offset = scroll.pixels;
      final previousQuote = flow.state.quote;
      repository.delayQuotes = true;

      for (final sliderIndex in [0, 1]) {
        tester
            .widget<AppSlider>(find.byType(AppSlider).at(sliderIndex))
            .onChanged!(const RangeValues(0, .08));
        await tester.pump();
        await tester.pump();
        expect(flow.state.quoteStatus, RequestStatus.loading);
        expect(flow.state.quote, same(previousQuote));
        expect(flow.state.canContinue, false);
        expect(tester.getRect(find.byType(AppSlider).first), amountRect);
        expect(tester.getRect(find.byType(AppSlider).last), monthsRect);
        expect(tester.getRect(find.byType(LoanCreditStatus)), creditRect);
        expect(tester.getSize(find.byType(LoanAssessment)).height, height);
        expect(scroll.pixels, offset);
        expect(
          tester
              .widget<AppButton>(
                find.widgetWithText(AppButton, S.current.loanRequestTable),
              )
              .isActive,
          false,
        );
      }
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(flow.state.quoteStatus, RequestStatus.success);
      expect(flow.state.quote!.input.amountRial, flow.state.amountRial);
      expect(flow.state.quote!.input.months, flow.state.months);
      expect(tester.getRect(find.byType(AppSlider).first), amountRect);
      expect(tester.getRect(find.byType(AppSlider).last), monthsRect);
      expect(scroll.pixels, offset);
      expect(tester.takeException(), null);
      await tester.pumpWidget(const SizedBox());
      router.dispose();
    },
  );

  testWidgets(
    'unsuitable assessment shows capacity details and keeps next disabled',
    (tester) async {
      final router = await mount(tester, size: const Size(320, 640));
      await tester.tap(
        find.widgetWithText(AppButton, S.current.loanRequestTitle),
      );
      await tester.pumpAndSettle();
      final flow = tester
          .element(find.byType(LoanAssessment))
          .read<LoanRequestCubit>();
      await flow.selectDeposit(flow.state.catalog!.deposits.first);
      await flow.updateAmount(.7);
      await tester.pumpAndSettle();
      expect(find.text(S.current.loanRequestNeededCapacity), findsOneWidget);
      expect(find.text(S.current.loanRequestCapacityDeficit), findsOneWidget);
      await tester.ensureVisible(
        find.text(S.current.loanRequestCapacityDeficit),
      );
      await tester.pumpAndSettle();
      await captureLoan(tester, 'unsuitable_corrected');
      expect(
        tester
            .widget<AppButton>(
              find.widgetWithText(AppButton, S.current.loanRequestNext),
            )
            .isActive,
        false,
      );
      expect(tester.takeException(), null);
      await tester.pumpWidget(const SizedBox());
      router.dispose();
    },
  );

  testWidgets(
    'current request shows validity and resumes from the top of its step',
    (tester) async {
      final repository = MockLoanApplicationRepository(
        delay: Duration.zero,
        tier: LoanCreditTier.fullySuitable,
      );
      final result = await repository.quote(
        const LoanQuoteInput(
          deposit: LoanDeposit(
            'deposit-1',
            '10.10009753.1',
            LoanCreditTier.fullySuitable,
          ),
          amountRial: 1000000000,
          months: 10,
          repayment: LoanRepayment.installments,
        ),
      );
      final quote = (result as Success<LoanQuote>).data;
      final router = await mount(
        tester,
        repository: MockLoanApplicationRepository(
          delay: Duration.zero,
          currentDraft: LoanDraft(
            id: quote.id,
            quote: quote,
            step: LoanApplicationStep.collateral,
            expiresAt: DateTime.now().toUtc().add(const Duration(seconds: 59)),
          ),
        ),
      );
      expect(find.text(S.current.loanRequestCurrentHeader), findsOneWidget);
      await captureLoan(tester, 'current_request_corrected');
      await tester.tap(
        find.widgetWithText(AppButton, S.current.loanRequestContinue),
      );
      await tester.pumpAndSettle();
      final scroll = tester
          .state<ScrollableState>(
            find
                .descendant(
                  of: find.byType(SingleChildScrollView),
                  matching: find.byType(Scrollable),
                )
                .first,
          )
          .position;
      expect(scroll.pixels, 0);
      await captureLoan(tester, 'current_request_resumed');
      expect(tester.takeException(), null);
      await tester.pumpWidget(const SizedBox());
      router.dispose();
    },
  );

  testWidgets('schedule link is compact and opens typed installment cards', (
    tester,
  ) async {
    final router = await mount(tester);
    await tester.tap(
      find.widgetWithText(AppButton, S.current.loanRequestTitle),
    );
    await tester.pumpAndSettle();
    final flow = tester
        .element(find.byType(LoanAssessment))
        .read<LoanRequestCubit>();
    await flow.selectDeposit(flow.state.catalog!.deposits.first);
    await tester.pumpAndSettle();
    final link = find.widgetWithText(AppButton, S.current.loanRequestTable);
    await tester.ensureVisible(link);
    await tester.pumpAndSettle();
    expect(tester.getSize(link).width, lessThan(200));
    expect(tester.widget<AppButton>(link).trailingIcon, isNotNull);
    await tester.tap(link);
    await tester.pumpAndSettle();
    expect(find.byType(LoanInstallmentsSheet), findsOneWidget);
    expect(find.text(S.current.loanRequestScheduleTitle), findsOneWidget);
    expect(find.text(S.current.loanRequestFee), findsOneWidget);
    await captureLoan(tester, 'installments_corrected');
    expect(tester.takeException(), null);
    await tester.pumpWidget(const SizedBox());
    router.dispose();
  });

  for (final tier in [
    LoanCreditTier.excellent,
    LoanCreditTier.fullySuitable,
    LoanCreditTier.suitable,
    LoanCreditTier.socialCore,
  ]) {
    testWidgets(
      'assessment and required collateral render on compact screen for $tier',
      (tester) async {
        final router = await mount(
          tester,
          tier: tier,
          size: const Size(320, 640),
        );
        await tester.tap(
          find.widgetWithText(AppButton, S.current.loanRequestTitle),
        );
        await tester.pumpAndSettle();
        final flow = tester
            .element(find.byType(LoanAssessment))
            .read<LoanRequestCubit>();
        await flow.selectDeposit(flow.state.catalog!.deposits.first);
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.text(S.current.loanRequestAvailability),
        );
        await tester.pumpAndSettle();
        await captureLoan(tester, 'assessment_${tier.name}');
        await flow.continueFlow();
        await flow.continueFlow();
        await tester.pumpAndSettle();
        if (tier == LoanCreditTier.fullySuitable ||
            tier == LoanCreditTier.suitable) {
          if (tier == LoanCreditTier.suitable) {
            flow.updateGuarantorNationalId('0081234562');
            await flow.checkGuarantor();
            await tester.pumpAndSettle();
            expect(find.byType(LoanGuarantorWarning), findsOneWidget);
            await captureLoan(tester, 'guarantor_rejected');
            flow.updateGuarantorNationalId('0013543921');
            await flow.checkGuarantor();
            await tester.pumpAndSettle();
          }
          await captureLoan(tester, 'collateral_${tier.name}');
        }
        expect(tester.takeException(), null);
        await tester.pumpWidget(const SizedBox());
        router.dispose();
      },
    );
  }

  testWidgets(
    'entry, assessment, contract, OTP and receipt use the same scope',
    (tester) async {
      final router = await mount(tester);
      await captureLoan(tester, 'introduction');
      expect(tester.takeException(), null, reason: 'introduction');
      await tester.tap(
        find.widgetWithText(AppButton, S.current.loanRequestTitle),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LoanAssessment), findsOneWidget);
      expect(
        find.widgetWithText(AppButton, S.current.loanRequestNext),
        findsNothing,
      );
      final flow = tester
          .element(find.byType(LoanAssessment))
          .read<LoanRequestCubit>();
      await flow.selectDeposit(flow.state.catalog!.deposits.first);
      await tester.pumpAndSettle();
      await captureLoan(tester, 'assessment');
      expect(tester.takeException(), null, reason: 'assessment');
      await flow.continueFlow();
      await flow.continueFlow();
      await tester.pumpAndSettle();
      final position = tester
          .state<ScrollableState>(
            find
                .descendant(
                  of: find.byType(SingleChildScrollView),
                  matching: find.byType(Scrollable),
                )
                .first,
          )
          .position;
      expect(position.pixels, 0);
      await captureLoan(tester, 'contract');
      flow.requestInsurance();
      await tester.pumpAndSettle();
      expect(find.text(S.current.loanRequestInsuranceDetails), findsOneWidget);
      await captureLoan(tester, 'insurance_corrected');
      await tester.tap(find.widgetWithText(AppButton, S.current.backLabel));
      await tester.pumpAndSettle();
      expect(tester.takeException(), null, reason: 'contract');
      await tester.tap(
        find.widgetWithText(AppButton, S.current.loanRequestContractContinue),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LoanContractSheet), findsOneWidget);
      await captureLoan(tester, 'contract_sheet');
      expect(tester.takeException(), null, reason: 'contract sheet');
      await tester.tap(find.text(S.current.loanRequestTerms));
      await tester.pumpAndSettle();
      expect(flow.state.termsAccepted, isTrue);
      await tester.tap(
        find.widgetWithText(AppButton, S.current.loanRequestContractAccept),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LoanOtpSheet), findsOneWidget);
      await captureLoan(tester, 'otp');
      expect(tester.takeException(), null, reason: 'otp');
      expect(
        tester.element(find.byType(LoanOtpSheet)).read<LoanRequestCubit>(),
        same(flow),
      );
      await tester.enterText(
        find.descendant(
          of: find.byType(LoanOtpSheet),
          matching: find.byType(TextField),
        ),
        '98760',
      );
      await tester.pumpAndSettle();
      await captureLoan(tester, 'otp_filled');
      await tester.tap(
        find.widgetWithText(AppButton, S.current.loanRequestSubmit),
      );
      await tester.pumpAndSettle();
      expect(find.text(S.current.loanRequestSuccess), findsOneWidget);
      expect(flow.state.step, LoanApplicationStep.introduction);
      await captureLoan(tester, 'receipt');
      expect(tester.takeException(), null, reason: 'receipt');
      await tester.tap(
        find.widgetWithText(AppButton, S.current.passwordUnderstood),
      );
      await tester.pumpAndSettle();
      expect(find.text(S.current.loanRequestReady), findsOneWidget);
      await captureLoan(tester, 'ready_corrected');
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      final copyIcon = find.byWidgetPredicate(
        (widget) =>
            widget is AvpImage &&
            widget.image?.endsWith('loan_request_copy.svg') == true,
      );
      await tester.ensureVisible(copyIcon);
      await tester.tap(copyIcon);
      await tester.pumpAndSettle();
      expect(copied, flow.state.catalog!.latestRecord!.id);

      expect(tester.takeException(), null);
      await tester.pumpWidget(const SizedBox());
      router.dispose();
    },
  );

  testWidgets(
    'compact screen keeps primary action and modal dismissal reachable',
    (tester) async {
      final router = await mount(tester, size: const Size(320, 640));
      await tester.tap(
        find.widgetWithText(AppButton, S.current.loanRequestTitle),
      );
      await tester.pumpAndSettle();
      final flow = tester
          .element(find.byType(LoanAssessment))
          .read<LoanRequestCubit>();
      await flow.selectDeposit(flow.state.catalog!.deposits.first);
      await tester.pumpAndSettle();
      flow.requestCreditInfo();
      await tester.pumpAndSettle();
      expect(
        find.textContaining(S.current.loanRequestCreditInfo.split('\n').first),
        findsOneWidget,
      );
      await captureLoan(tester, 'credit_guide_corrected');
      tester
          .widget<AppBottomSheetHeader>(find.byType(AppBottomSheetHeader))
          .onLeftAction!();
      await tester.pumpAndSettle();
      expect(flow.state.step, LoanApplicationStep.assessment);
      expect(tester.takeException(), null);
      await tester.pumpWidget(const SizedBox());
      router.dispose();
    },
  );
  testWidgets('OTP remains reachable with keyboard on a compact viewport', (
    tester,
  ) async {
    final router = await mount(tester, size: const Size(320, 640));
    await tester.tap(
      find.widgetWithText(AppButton, S.current.loanRequestTitle),
    );
    await tester.pumpAndSettle();
    final flow = tester
        .element(find.byType(LoanAssessment))
        .read<LoanRequestCubit>();
    await flow.selectDeposit(flow.state.catalog!.deposits.first);
    await flow.continueFlow();
    await flow.continueFlow();
    await flow.applyContractResult(true);
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    final back = find.descendant(
      of: find.byType(LoanOtpSheet),
      matching: find.widgetWithText(AppButton, S.current.backLabel),
    );
    await tester.ensureVisible(back);
    await tester.tap(back);
    await tester.pumpAndSettle();
    expect(find.byType(LoanOtpSheet), findsNothing);
    expect(flow.state.step, LoanApplicationStep.contract);
    expect(tester.takeException(), null);
    await tester.pumpWidget(const SizedBox());
    router.dispose();
  });
  testWidgets(
    'unknown credit explains the blocker once and disables progression',
    (tester) async {
      final router = await mount(tester, tier: LoanCreditTier.unknown);
      await tester.tap(
        find.widgetWithText(AppButton, S.current.loanRequestTitle),
      );
      await tester.pumpAndSettle();
      final flow = tester
          .element(find.byType(LoanAssessment))
          .read<LoanRequestCubit>();
      await flow.selectDeposit(flow.state.catalog!.deposits.first);
      await tester.pumpAndSettle();
      expect(find.text(S.current.loanRequestUnknownHint), findsOneWidget);
      await tester.tap(
        find.widgetWithText(AppButton, S.current.loanRequestTitle),
      );
      await tester.pumpAndSettle();
      expect(flow.state.step, LoanApplicationStep.assessment);
      expect(tester.takeException(), null);
      await tester.pumpWidget(const SizedBox());
      router.dispose();
    },
  );
}

class SlowQuoteRepository extends MockLoanApplicationRepository {
  SlowQuoteRepository() : super(delay: Duration.zero);

  bool delayQuotes = false;

  @override
  Future<Result<LoanQuote>> quote(LoanQuoteInput input) async {
    if (delayQuotes) {
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    return super.quote(input);
  }
}
