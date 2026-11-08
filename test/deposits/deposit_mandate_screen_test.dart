import 'dart:async';
import 'dart:io';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/flow/service_registry.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/deposits/data/repositories/mock_deposit_mandate_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/listed_deposit.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/deposit_mandate.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/deposit_mandate_repository.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/deposit_mandate/cubit/deposit_mandate_cubit.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/deposit_mandate/screens/deposit_mandate_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/deposit_mandate/widgets/deposit_mandate_form.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/deposit_mandate/widgets/deposit_mandate_receipt_dialog.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/deposit_mandate/widgets/deposit_mandate_subject_details.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import 'certificate_test_support.dart';

Future<void> captureDepositMandate(WidgetTester tester, String name) async {
  if (Platform.environment['CAPTURE_CERTIFICATE_PREVIEWS'] != '1') return;
  for (var attempt = 0; attempt < 40; attempt++) {
    if (find
            .descendant(
              of: find.byType(AvpImage),
              matching: find.byType(SvgPicture),
            )
            .evaluate()
            .length ==
        find.byType(AvpImage).evaluate().length) {
      break;
    }
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
  }
  await captureCertificate(tester, 'deposit-mandate-$name');
}

Finder depositMandateSubmitButton() => find.byWidgetPredicate(
  (widget) => widget is AppButton && widget.label == S.current.issuanceSubmit,
);

Future<void> selectDepositMandateSubject(WidgetTester tester) async {
  await tester.tap(find.byType(AppSelect<DepositMandateCompany>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('خودرو وارداتی - سامانه اتونوین').last);
  await tester.pumpAndSettle();
  await tester.tap(find.byType(AppSelect<DepositMandateSubject>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('خودرو وارداتی').last);
  await tester.pumpAndSettle();
}

class PendingDepositMandateRepository extends MockDepositMandateRepository {
  bool failsCatalog = true;
  final pending = Completer<Result<DepositMandateReceipt>>();
  final requests = <DepositMandateRequest>[];
  @override
  Future<Result<DepositMandateCatalog>> fetchCatalog() => failsCatalog
      ? Future.value(const Err(DataFailure('unavailable')))
      : super.fetchCatalog();
  @override
  Future<Result<DepositMandateReceipt>> submitDepositMandate(
    DepositMandateRequest request,
  ) {
    requests.add(request);
    return requests.length == 1
        ? pending.future
        : super.submitDepositMandate(request);
  }
}

void main() {
  setUp(configureDependencies);
  tearDown(() => getIt.reset());
  setUpAll(loadCertificateFonts);

  testWidgets(
    'initial and filled design keep all three fields selectable and derived details read-only',
    (tester) async {
      await mountCertificate(tester, const DepositMandateScreen());
      expect(
        tester.getTopLeft(find.byType(AppSelect<DepositMandateCompany>)).dy,
        104,
      );
      expect(
        tester.getTopLeft(find.byType(AppSelect<DepositMandateSubject>)).dy,
        194,
      );
      expect(tester.getTopLeft(find.byType(AppSelect<ListedDeposit>)).dy, 284);
      expect(find.byType(DepositMandateSubjectDetails), findsNothing);
      expect(
        tester.widget<AppButton>(depositMandateSubmitButton()).isActive,
        isFalse,
      );
      await captureDepositMandate(tester, 'initial');
      await selectDepositMandateSubject(tester);
      await tester.tap(find.byType(AppSelect<ListedDeposit>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('10.1234567.2').last);
      await tester.pumpAndSettle();
      expect(find.byType(DepositMandateSubjectDetails), findsOneWidget);
      expect(
        tester
            .widget<AppSelect<DepositMandateSubject>>(
              find.byType(AppSelect<DepositMandateSubject>),
            )
            .enabled,
        isTrue,
      );
      expect(find.text('سازمان حمایت از مصرف کننده'), findsOneWidget);
      expect(find.text(CurrencyFormatter.format(5000000000)), findsOneWidget);
      for (final field in tester.widgetList<AppTextField>(
        find.byType(AppTextField),
      )) {
        expect(field.readOnly, isTrue);
        expect(field.onChanged, isNull);
      }
      await tester.tap(find.byType(AppCheckbox));
      await tester.pumpAndSettle();
      expect(
        tester.widget<AppButton>(depositMandateSubmitButton()).isActive,
        isTrue,
      );
      await captureDepositMandate(tester, 'filled');
      await tester.tap(depositMandateSubmitButton());
      await tester.pumpAndSettle();
      expect(find.byType(DepositMandateReceiptDialog), findsOneWidget);
      expect(
        find.textContaining(S.current.depositMandateMockComplete),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'changing company clears derived information and requires a fresh compatible deposit and consent',
    (tester) async {
      await mountCertificate(
        tester,
        const DepositMandateScreen(initialDepositNumber: '10.1234567.2'),
      );
      await selectDepositMandateSubject(tester);
      await tester.tap(find.byType(AppCheckbox));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AppSelect<DepositMandateCompany>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('شرکت آزمایشی').last);
      await tester.pumpAndSettle();
      expect(find.byType(DepositMandateSubjectDetails), findsNothing);
      expect(
        tester.widget<AppCheckbox>(find.byType(AppCheckbox)).value,
        isFalse,
      );
      await tester.tap(find.byType(AppSelect<DepositMandateSubject>));
      await tester.pumpAndSettle();
      expect(find.text('خودرو وارداتی'), findsNothing);
      await tester.tap(find.text('طرح آزمایشی').last);
      await tester.pumpAndSettle();
      expect(find.text('کارگزار آزمایشی'), findsOneWidget);
      expect(
        tester
            .widget<AppSelect<ListedDeposit>>(
              find.byType(AppSelect<ListedDeposit>),
            )
            .value,
        isNull,
      );
      expect(
        tester.widget<AppButton>(depositMandateSubmitButton()).isActive,
        isFalse,
      );
    },
  );

  testWidgets(
    'catalog retry, loading controls, Back and submission retry preserve the original request',
    (tester) async {
      final repository = PendingDepositMandateRepository();
      getIt.unregister<DepositMandateRepository>();
      getIt.registerSingleton<DepositMandateRepository>(repository);
      await mountCertificate(
        tester,
        const DepositMandateScreen(initialDepositNumber: '10.1234567.2'),
      );
      expect(find.text('درخواست انجام نشد. دوباره تلاش کنید.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      repository.failsCatalog = false;
      await tester.tap(find.text(S.current.dashboardRetry));
      await tester.pumpAndSettle();
      await selectDepositMandateSubject(tester);
      await tester.tap(find.byType(AppCheckbox));
      await tester.pumpAndSettle();
      await tester.tap(depositMandateSubmitButton());
      await tester.pump();
      expect(
        tester.widget<AppButton>(depositMandateSubmitButton()).isLoading,
        isTrue,
      );
      expect(
        tester
            .widget<AppSelect<DepositMandateCompany>>(
              find.byType(AppSelect<DepositMandateCompany>),
            )
            .enabled,
        isFalse,
      );
      expect(
        tester
            .widget<AppSelect<DepositMandateSubject>>(
              find.byType(AppSelect<DepositMandateSubject>),
            )
            .enabled,
        isFalse,
      );
      expect(
        tester
            .widget<AppSelect<ListedDeposit>>(
              find.byType(AppSelect<ListedDeposit>),
            )
            .enabled,
        isFalse,
      );
      await tester.tap(depositMandateSubmitButton());
      await tester.pump();
      expect(repository.requests.length, 1);
      await tester.tap(find.byTooltip(S.current.backLabel));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AlertDialog), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 300));
      repository.pending.complete(const Err(DataFailure('timeout')));
      await tester.pumpAndSettle();
      expect(find.text('درخواست انجام نشد. دوباره تلاش کنید.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.tap(depositMandateSubmitButton());
      await tester.pumpAndSettle();
      expect(repository.requests.first, repository.requests.last);
      expect(find.byType(DepositMandateReceiptDialog), findsOneWidget);
    },
  );

  testWidgets(
    'existing service opens the central route and resolves its deposit entry',
    (tester) async {
      await mountCertificate(
        tester,
        Builder(
          builder: (context) => AppButton(
            label: 'open',
            onPressed: () => ServiceRegistry.openCardService(
              context,
              'deposit-proxy',
              initialDepositNumber: '۱۰.۱۲۳۴۵۶۷.۲',
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(DepositMandateScreen), findsOneWidget);
      final cubit = tester
          .element(find.byType(DepositMandateForm))
          .read<DepositMandateCubit>();
      expect(cubit.state.deposit!.id, 'proxy-2');
    },
  );

  for (final locale in ['fa', 'en', 'ar']) {
    testWidgets(
      'filled $locale form remains scrollable at 320px and larger text',
      (tester) async {
        await mountCertificate(
          tester,
          const DepositMandateScreen(initialDepositNumber: '10.1234567.2'),
          size: const Size(320, 640),
          scale: 1.5,
          locale: locale,
        );
        final cubit = tester
            .element(find.byType(DepositMandateForm))
            .read<DepositMandateCubit>();
        cubit.selectSubject(cubit.state.subjects.first);
        await tester.pumpAndSettle();
        await tester.drag(
          find.byType(SingleChildScrollView).first,
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();
        expect(find.byType(DepositMandateSubjectDetails), findsOneWidget);
        expect(
          tester.getBottomRight(depositMandateSubmitButton()).dy,
          lessThanOrEqualTo(600),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
