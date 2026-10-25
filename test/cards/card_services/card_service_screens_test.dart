import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/cards/presentation/change_card_deposit/widgets/change_card_deposit_form.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:pishkhan_mobile/core/router/card_features_navigation.dart';
import 'package:pishkhan_mobile/features/cards/cards.dart';
import 'package:pishkhan_mobile/features/cards/presentation/change_card_deposit/cubit/change_card_deposit_cubit.dart';
import 'package:pishkhan_mobile/features/cards/presentation/expired_gift_balance/cubit/expired_gift_balance_cubit.dart';
import 'package:pishkhan_mobile/features/cards/presentation/expired_gift_balance/widgets/gift_balance_review_sheet.dart';
import 'package:pishkhan_mobile/features/cards/presentation/expired_gift_balance/widgets/gift_balance_filter_sheet.dart';
import 'package:pishkhan_mobile/features/cards/presentation/expired_gift_balance/models/gift_balance_deposit_filter.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../support/router_test_app.dart';
import 'card_service_cubits_test.dart';
import '../support/card_dependency_overrides.dart';

import 'package:pishkhan_mobile/core/di/injection_container.dart';

const previewKey = Key('card_service_preview');

void main() {
  setUp(configureDependencies);
  tearDown(() => getIt.reset());
  setUpAll(() async {
    final loader = FontLoader(AppTypography.defaultFontFamily);
    for (final face in ['Regular']) {
      loader.addFont(
        rootBundle.load(
          'packages/avp_ui/assets/fonts/IRANYekanXFaNum-$face.ttf',
        ),
      );
    }
    await loader.load();
  });
  Future<void> mount(
    WidgetTester t,
    Widget screen, {
    CardServicesRepository? repository,
    Size size = const Size(375, 812),
    Locale locale = const Locale('fa'),
    double scale = 1,
  }) async {
    if (repository != null) await useCardServicesRepository(repository);
    t.view.physicalSize = size;
    t.view.devicePixelRatio = 1;
    t.view.padding = const FakeViewPadding(top: 24, bottom: 40);
    t.view.viewPadding = const FakeViewPadding(top: 24, bottom: 40);
    addTearDown(t.view.reset);
    await t.pumpWidget(
      RepaintBoundary(
        key: previewKey,
        child: TestRouterApp(
          theme: AppTheme.light(),
          locale: locale,
          home: screen,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  Future<void> capture(WidgetTester t, String name) async {
    if (!const bool.fromEnvironment('CAPTURE_CARD_SERVICE_PREVIEWS') &&
        Platform.environment['CAPTURE_CARD_SERVICE_PREVIEWS'] != '1') {
      return;
    }
    final boundary = t.renderObject<RenderRepaintBoundary>(
      find.byKey(previewKey),
    );
    await t.runAsync(() async {
      final warm = await boundary.toImage(pixelRatio: 1);
      warm.dispose();
      final image = await boundary.toImage(pixelRatio: 1);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('build/previews/card-services/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(data!.buffer.asUint8List());
      image.dispose();
    });
  }

  Finder button(String label) =>
      find.byWidgetPredicate((w) => w is AppButton && w.label == label);
  Future<void> choose<T>(WidgetTester t, int index, String number) async {
    await t.tap(find.byType(AppSelect<T>).at(index));
    await t.pumpAndSettle();
    await t.tap(find.text(number).last);
    await t.pumpAndSettle();
  }

  ChangeCardDepositCubit changeCubit(WidgetTester t) => t
      .element(
        find.byType(
          BlocConsumer<ChangeCardDepositCubit, ChangeCardDepositState>,
        ),
      )
      .read<ChangeCardDepositCubit>();
  ExpiredGiftBalanceCubit giftCubit(WidgetTester t) => t
      .element(
        find.byType(
          BlocConsumer<ExpiredGiftBalanceCubit, ExpiredGiftBalanceState>,
        ),
      )
      .read<ExpiredGiftBalanceCubit>();

  testWidgets(
    'change deposit follows empty, card selected, and complete forms',
    (t) async {
      final repo = TestCardServicesRepository();
      await mount(t, const ChangeCardDepositScreen(), repository: repo);
      expect(find.byType(AppSelect<ServiceBankCard>), findsOneWidget);
      expect(
        t.widget<AppButton>(button('تایید و ثبت درخواست')).onPressed,
        isNull,
      );
      await capture(t, 'change-1-empty');
      await choose<ServiceBankCard>(t, 0, '\u200e5041 7212 2345 6787');
      final number = t.renderObject<RenderParagraph>(
        find.text('\u200e5041 7212 2345 6787'),
      );
      final firstGroup = number.getBoxesForSelection(
        const TextSelection(baseOffset: 1, extentOffset: 5),
      );
      final lastGroup = number.getBoxesForSelection(
        const TextSelection(baseOffset: 16, extentOffset: 20),
      );
      expect(firstGroup.first.left, lessThan(lastGroup.first.left));

      expect(find.byType(AppSelect<ServiceBankCard>), findsOneWidget);
      expect(find.byType(AppSelect<CardServiceDeposit>), findsOneWidget);
      expect(find.byType(AppSelect<String>), findsOneWidget);
      expect(
        t.widget<AppSelect<String>>(find.byType(AppSelect<String>)).enabled,
        isFalse,
      );
      await capture(t, 'change-2-card');
      await choose<CardServiceDeposit>(t, 0, '10.123456.2');
      await t.tap(find.byType(AppCheckbox));
      await t.pumpAndSettle();
      expect(changeCubit(t).state.canSubmit, isTrue);
      t.view.physicalSize = const Size(375, 852);
      await t.pumpAndSettle();
      await capture(t, 'change-3-complete');
      await t.tap(button('تایید و ثبت درخواست'));
      await t.pumpAndSettle();
      expect(repo.changes.single.destinationDepositId, 'deposit-2');
      expect(find.textContaining('درخواست آزمایشی ثبت شد'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('change submission disables form actions and blocks Back', (
    t,
  ) async {
    final repo = TestCardServicesRepository()
      ..pendingSubmit = Completer<Result<CardServiceReceipt>>();
    var completions = 0;
    await mount(
      t,
      ChangeCardDepositScreen(onCompleted: (_) => completions++),
      repository: repo,
    );
    await choose<ServiceBankCard>(t, 0, '\u200e5041 7212 2345 6787');
    await choose<CardServiceDeposit>(t, 0, '10.123456.2');
    await t.tap(find.byType(AppCheckbox));
    await t.pumpAndSettle();
    await t.tap(button('تایید و ثبت درخواست'));
    await t.pump();
    expect(
      t.widget<AppButton>(button('تایید و ثبت درخواست')).onPressed,
      isNull,
    );
    expect(t.widget<AppCheckbox>(find.byType(AppCheckbox)).onChanged, isNull);
    expect(
      t
          .widget<AbsorbPointer>(
            find.descendant(
              of: find.byType(ChangeCardDepositForm),
              matching: find.byType(AbsorbPointer),
            ),
          )
          .absorbing,
      isTrue,
    );
    expect(
      t.widget<AppTopBar>(find.byType(AppTopBar)).onTrailingPressed,
      isNull,
    );
    expect(repo.changes, hasLength(1));
    repo.pendingSubmit!.complete(
      const Success(CardServiceReceipt(reference: 'done', isMock: true)),
    );
    await t.pumpAndSettle();
    expect(completions, 1);
    expect(changeCubit(t).state.submissionStatus, RequestStatus.success);
    expect(t.takeException(), isNull);
  });

  testWidgets(
    'one-account gift flow reviews selection and then submits to destination',
    (t) async {
      final repo = TestCardServicesRepository(catalog: singleAccountCatalog());
      await mount(
        t,
        const ExpiredGiftBalanceScreen(),
        repository: repo,
        size: const Size(375, 956),
      );
      expect(
        find.byWidgetPredicate((w) => w is AppButton && w.tooltip == 'فیلتر'),
        findsNothing,
      );
      final firstCard = find
          .ancestor(
            of: find.byType(AppCheckbox).first,
            matching: find.byType(DecoratedBox),
          )
          .first;
      expect(t.getRect(firstCard).top, 312);
      expect(t.getRect(firstCard).height, 92);
      await capture(t, 'gift-1-no-filter');
      await t.tap(find.byType(AppCheckbox).at(0));
      await t.pumpAndSettle();
      await t.tap(find.byType(AppCheckbox).at(2));
      await t.pumpAndSettle();
      expect(giftCubit(t).state.selectedCards.map((card) => card.id).toSet(), {
        'gift-0',
        'gift-2',
      });
      await capture(t, 'gift-2-selected');
      await t.tap(button('مرحله بعد'));
      await t.pumpAndSettle();
      expect(find.byType(GiftBalanceReviewSheet), findsOneWidget);
      expect(find.text('لیست کارت‌های انتخاب شده (2)'), findsOneWidget);
      await capture(t, 'gift-3-review');
      await t.tap(button(S.current.backLabel));
      await t.pumpAndSettle();
      expect(giftCubit(t).state.step, GiftBalanceStep.destination);
      expect(find.text('مجموع مبلغ (ریال)'), findsOneWidget);
      t.view.physicalSize = const Size(375, 812);
      await t.pumpAndSettle();
      await capture(t, 'gift-4-destination');
      await choose<CardServiceDeposit>(t, 0, '10.123456.1');
      await t.tap(find.byType(AppCheckbox));
      await t.pumpAndSettle();
      await capture(t, 'gift-5-complete');
      await t.tap(button('ثبت درخواست'));
      await t.pumpAndSettle();
      expect(repo.transfers.single.cardIds, ['gift-0', 'gift-2']);
      expect(find.textContaining('درخواست آزمایشی ثبت شد'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('multi-account filter is staged, applied and removable', (
    t,
  ) async {
    await mount(
      t,
      const ExpiredGiftBalanceScreen(),
      size: const Size(375, 956),
    );
    await capture(t, 'gift-6-filter-enabled');
    final filter = find.byWidgetPredicate(
      (w) => w is AppButton && w.tooltip == 'فیلتر',
    );
    await t.tap(filter);
    await t.pumpAndSettle();
    await capture(t, 'gift-7-filter-all');
    await choose<GiftBalanceDepositFilter>(t, 0, '10.123456.2');
    expect(giftCubit(t).state.visibleCards.length, 5);
    await capture(t, 'gift-8-filter-draft');
    await t.tap(button('اعمال فیلتر'));
    await t.pumpAndSettle();
    expect(giftCubit(t).state.visibleCards.length, 2);
    await t.tap(find.byType(AppToggle));
    await t.pumpAndSettle();
    expect(giftCubit(t).state.selectedCards.map((card) => card.id).toSet(), {
      'gift-1',
      'gift-3',
    });
    await t.tap(filter);
    await t.pumpAndSettle();
    await choose<GiftBalanceDepositFilter>(t, 0, 'همه');
    await t.tap(button('اعمال فیلتر'));
    await t.pumpAndSettle();
    expect(giftCubit(t).state.visibleCards.length, 5);
    expect(giftCubit(t).state.selectedCards.length, 2);
    expect(t.takeException(), isNull);
  });
  testWidgets(
    'dismissing a filter discards its draft and review dismissal keeps the step',
    (t) async {
      await mount(t, const ExpiredGiftBalanceScreen());
      final cubit = giftCubit(t);
      await t.tap(find.byType(AppCheckbox).first);
      await t.pumpAndSettle();
      final filter = find.byWidgetPredicate(
        (widget) =>
            widget is AppButton &&
            widget.tooltip == S.current.cardFeatureFilter,
      );
      await t.tap(filter);
      await t.pumpAndSettle();
      await choose<GiftBalanceDepositFilter>(t, 0, '10.123456.2');
      Navigator.of(t.element(find.byType(GiftBalanceFilterSheet))).pop();
      await t.pumpAndSettle();
      expect(cubit.state.activeFilter.deposit, isNull);
      expect(cubit.state.visibleCards.length, 5);
      expect(cubit.state.isEditable, isTrue);
      await t.tap(filter);
      await t.pumpAndSettle();
      expect(cubit.state.draftFilter.deposit, isNull);
      Navigator.of(t.element(find.byType(GiftBalanceFilterSheet))).pop();
      await t.pumpAndSettle();
      await t.ensureVisible(button(S.current.giftBalanceNext));
      await t.tap(button(S.current.giftBalanceNext));
      await t.pumpAndSettle();
      Navigator.of(t.element(find.byType(GiftBalanceReviewSheet))).pop();
      await t.pumpAndSettle();
      expect(giftCubit(t), same(cubit));
      expect(cubit.state.step, GiftBalanceStep.selection);
      expect(cubit.state.selectedCards, hasLength(1));
      expect(cubit.state.canContinue, isTrue);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'gift load and transfer retries preserve selection and disable controls while pending',
    (t) async {
      final repository = TestCardServicesRepository()..throwLoad = true;
      var completions = 0;
      await mount(
        t,
        ExpiredGiftBalanceScreen(onCompleted: (_) => completions++),
        repository: repository,
      );
      expect(giftCubit(t).state.catalogStatus, RequestStatus.failure);
      repository.throwLoad = false;
      await t.tap(button(S.current.dashboardRetry));
      await t.pump(const Duration(seconds: 5));
      await t.pumpAndSettle();
      await t.pumpAndSettle();
      await t.tap(find.byType(AppCheckbox).first);
      await t.pumpAndSettle();
      await t.ensureVisible(button(S.current.giftBalanceNext));
      await t.tap(button(S.current.giftBalanceNext));
      await t.pumpAndSettle();
      await t.tap(button(S.current.backLabel));
      await t.pumpAndSettle();
      await choose<CardServiceDeposit>(t, 0, '10.123456.2');
      await t.tap(find.byType(AppCheckbox));
      await t.pumpAndSettle();
      repository.failSubmit = true;
      await t.tap(button(S.current.giftBalanceSubmit));
      await t.pumpAndSettle();
      expect(find.text('درخواست انجام نشد. دوباره تلاش کنید.'), findsOneWidget);
      await t.pump(const Duration(seconds: 5));
      await t.pumpAndSettle();
      expect(giftCubit(t).state.selectedCards, hasLength(1));
      repository.pendingSubmit = Completer<Result<CardServiceReceipt>>();
      await t.tap(button(S.current.giftBalanceSubmit));
      await t.pump();
      expect(
        t.widget<AppButton>(button(S.current.giftBalanceSubmit)).onPressed,
        isNull,
      );
      expect(t.widget<AppCheckbox>(find.byType(AppCheckbox)).onChanged, isNull);
      expect(
        t.widget<AppTopBar>(find.byType(AppTopBar)).onTrailingPressed,
        isNull,
      );
      final review = find.byWidgetPredicate(
        (widget) =>
            widget is AppButton &&
            widget.tooltip == S.current.giftBalanceSelectedList(1),
      );
      expect(t.widget<AppButton>(review).onPressed, isNull);
      await t.tap(button(S.current.giftBalanceSubmit));
      await t.pump();
      expect(repository.transfers, hasLength(2));
      expect(
        repository.transfers.first.idempotencyKey,
        repository.transfers.last.idempotencyKey,
      );
      repository.pendingSubmit!.complete(
        const Success(CardServiceReceipt(reference: 'gift-done', isMock: true)),
      );
      await t.pumpAndSettle();
      expect(completions, 1);
      expect(giftCubit(t).state.submissionStatus, RequestStatus.success);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'review removal updates count and dismissing review keeps selection step',
    (t) async {
      await mount(t, const ExpiredGiftBalanceScreen());
      await t.tap(find.byType(AppCheckbox).first);
      await t.pumpAndSettle();
      await t.tap(button('مرحله بعد'));
      await t.pumpAndSettle();
      await t.tap(find.bySemanticsLabel('حذف کارت 5041721456783407'));
      await t.pumpAndSettle();
      expect(find.text('لیست کارت‌های انتخاب شده (0)'), findsOneWidget);
      await t.tap(button(S.current.backLabel));
      await t.pumpAndSettle();
      expect(giftCubit(t).state.step, GiftBalanceStep.selection);
      expect(t.widget<AppButton>(button('مرحله بعد')).onPressed, isNull);
    },
  );
  testWidgets('load failure retries and submission failure remains editable', (
    t,
  ) async {
    final repo = TestCardServicesRepository()..throwLoad = true;
    await mount(t, const ChangeCardDepositScreen(), repository: repo);
    expect(changeCubit(t).state.catalogStatus, RequestStatus.failure);
    repo.throwLoad = false;
    await t.tap(button('تلاش دوباره'));
    await t.pumpAndSettle();
    await choose<ServiceBankCard>(t, 0, '\u200e5041 7212 2345 6787');
    await choose<CardServiceDeposit>(t, 0, '10.123456.2');
    await t.tap(find.byType(AppCheckbox));
    await t.pumpAndSettle();
    repo.failSubmit = true;
    await t.tap(button('تایید و ثبت درخواست'));
    await t.pumpAndSettle();
    expect(changeCubit(t).state.isEditable, isTrue);
    expect(find.text('درخواست انجام نشد. دوباره تلاش کنید.'), findsOneWidget);
  });
  for (final locale in ['fa', 'en', 'ar']) {
    testWidgets('$locale compact phone with large text has no overflow', (
      t,
    ) async {
      await mount(
        t,
        const ExpiredGiftBalanceScreen(),
        size: const Size(320, 640),
        locale: Locale(locale),
        scale: 1.5,
      );
      expect(t.takeException(), isNull);
      giftCubit(t).selectAllVisible(true);
      await t.pumpAndSettle();
      giftCubit(t).requestReview();
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });
  }
  testWidgets(
    'new services route to their screens with selected-card context',
    (t) async {
      await mount(
        t,
        Builder(
          builder: (context) => AppButton(
            label: 'open',
            onPressed: () => openCardFeaturesService(
              context,
              'card-deposit',
              initialCardNumber: '1234123412341234',
            ),
          ),
        ),
      );
      await t.tap(button('open'));
      await t.pumpAndSettle();
      expect(find.byType(ChangeCardDepositScreen), findsOneWidget);
      expect(changeCubit(t).state.card!.number, '1234123412341234');
      final context = t.element(find.byType(ChangeCardDepositScreen));
      expect(GoRouterState.of(context).uri.path, AppRoutes.changeCardDeposit);
      GoRouter.of(context).pop();
      await t.pumpAndSettle();
      openCardFeaturesService(t.element(button('open')), 'card-expired-gift');
      await t.pumpAndSettle();
      expect(find.byType(ExpiredGiftBalanceScreen), findsOneWidget);
    },
  );
  for (final locale in ['fa', 'en', 'ar']) {
    testWidgets('$locale completed forms fit a compact phone with large text', (
      t,
    ) async {
      await mount(
        t,
        const ChangeCardDepositScreen(),
        size: const Size(320, 640),
        locale: Locale(locale),
        scale: 1.5,
      );
      final change = changeCubit(t);
      change.selectCard(
        change.state.catalog!.cards.firstWhere((card) => card.id == 'card-1'),
      );
      change.selectDestination(
        change.state.destinations.firstWhere(
          (deposit) => deposit.id == 'deposit-2',
        ),
      );
      change.updateTermsAcceptance(true);
      await t.pumpAndSettle();
      expect(change.state.canSubmit, isTrue);
      expect(t.takeException(), isNull);
      await mount(
        t,
        const ExpiredGiftBalanceScreen(),
        size: const Size(320, 640),
        locale: Locale(locale),
        scale: 1.5,
      );
      final gift = giftCubit(t);
      gift.selectAllVisible(true);
      await gift.submitCurrentStep();
      await t.pumpAndSettle();
      await t.tap(button(S.current.backLabel));
      await t.pumpAndSettle();
      gift.selectDestination(
        gift.state.catalog!.deposits.firstWhere(
          (deposit) => deposit.id == 'deposit-2',
        ),
      );
      gift.updateTermsAcceptance(true);
      await t.pumpAndSettle();
      expect(gift.state.canContinue, isTrue);
      expect(t.takeException(), isNull);
    });
  }
  testWidgets(
    'a fresh route uses its repository binding and handles empty catalogs',
    (t) async {
      final first = TestCardServicesRepository();
      await mount(t, const ChangeCardDepositScreen(), repository: first);
      final previous = changeCubit(t);
      previous.selectCard(
        previous.state.catalog!.cards.firstWhere((card) => card.id == 'card-1'),
      );
      await mount(t, const SizedBox.shrink());
      await mount(
        t,
        const ChangeCardDepositScreen(),
        repository: TestCardServicesRepository(catalog: singleAccountCatalog()),
      );
      expect(previous.isClosed, isTrue);
      expect(changeCubit(t).state.card, isNull);
      expect(find.text('موردی برای نمایش وجود ندارد.'), findsOneWidget);
      expect(find.byType(AppSelect<String>), findsNothing);
    },
  );
  testWidgets(
    'Stepper keeps the dot adjacent to a right-aligned title and spacing',
    (t) async {
      await mount(
        t,
        const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: AppStepper(
              currentStep: 1,
              totalSteps: 2,
              title: 'انتخاب کارت‌ها',
              supportingText: 'بعدی',
            ),
          ),
        ),
      );
      final dot = find.byWidgetPredicate(
        (w) => w is Container && w.constraints?.maxWidth == 4,
      );
      final dotRect = t.getRect(dot);
      final title = t.getRect(find.text('انتخاب کارت‌ها'));
      final subtitle = t.getRect(find.text('بعدی'));
      expect(dotRect.left - title.right, closeTo(4, .01));
      expect(
        dotRect.right,
        closeTo(t.getRect(find.byType(AppStepper)).right, .01),
      );
      expect(dotRect.right - subtitle.right, closeTo(8, .01));
      expect(subtitle.top - title.bottom, closeTo(6, .01));
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'change provider initializes once, retains selection on rebuild, and closes on removal',
    (t) async {
      final repo = TestCardServicesRepository();
      await mount(t, const ChangeCardDepositScreen(), repository: repo);
      final cubit = changeCubit(t);
      cubit.selectCard(
        cubit.state.catalog!.cards.firstWhere((card) => card.id == 'card-1'),
      );
      await mount(t, ChangeCardDepositScreen(onTermsRequested: () {}));
      expect(changeCubit(t), same(cubit));
      expect(repo.loadCalls, 1);
      expect(cubit.state.card?.id, 'card-1');
      expect(cubit.state.catalogStatus, RequestStatus.success);
      await mount(t, const Scaffold());
      expect(cubit.isClosed, isTrue);
    },
  );
  testWidgets(
    'gift provider initializes once, retains selection on rebuild, and closes on removal',
    (t) async {
      final repo = TestCardServicesRepository();
      await mount(t, const ExpiredGiftBalanceScreen(), repository: repo);
      final cubit = giftCubit(t);
      cubit.toggleCard(cubit.state.visibleCards.first);
      await mount(t, ExpiredGiftBalanceScreen(onTermsRequested: () {}));
      expect(giftCubit(t), same(cubit));
      expect(repo.loadCalls, 1);
      expect(cubit.state.selectedCards.map((card) => card.id), ['gift-0']);
      expect(cubit.state.step, GiftBalanceStep.selection);
      await mount(t, const Scaffold());
      expect(cubit.isClosed, isTrue);
    },
  );
}
