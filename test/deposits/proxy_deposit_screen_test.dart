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
import 'package:pishkhan_mobile/features/deposits/data/repositories/mock_proxy_deposits_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/listed_deposit.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/proxy_deposit.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/proxy_deposits_repository.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/proxy_deposit/cubit/proxy_deposit_cubit.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/proxy_deposit/screens/proxy_deposit_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/proxy_deposit/widgets/proxy_deposit_form.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/proxy_deposit/widgets/proxy_deposit_receipt_dialog.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/proxy_deposit/widgets/proxy_subject_details.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import 'certificate_test_support.dart';

Future<void> captureProxy(WidgetTester tester, String name) async {
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
  await captureCertificate(tester, 'proxy-deposit-$name');
}

Finder proxySubmitButton() => find.byWidgetPredicate(
  (widget) => widget is AppButton && widget.label == S.current.issuanceSubmit,
);

Future<void> selectProxySubject(WidgetTester tester) async {
  await tester.tap(find.byType(AppSelect<ProxyCompany>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('خودرو وارداتی - سامانه اتونوین').last);
  await tester.pumpAndSettle();
  await tester.tap(find.byType(AppSelect<ProxySubject>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('خودرو وارداتی').last);
  await tester.pumpAndSettle();
}

class PendingProxyRepository extends MockProxyDepositsRepository {
  bool failsCatalog = true;
  final pending = Completer<Result<ProxyDepositReceipt>>();
  final requests = <ProxyDepositRequest>[];
  @override
  Future<Result<ProxyDepositCatalog>> fetchCatalog() => failsCatalog
      ? Future.value(const Err(DataFailure('unavailable')))
      : super.fetchCatalog();
  @override
  Future<Result<ProxyDepositReceipt>> submitProxyDeposit(
    ProxyDepositRequest request,
  ) {
    requests.add(request);
    return requests.length == 1
        ? pending.future
        : super.submitProxyDeposit(request);
  }
}

void main() {
  setUp(configureDependencies);
  tearDown(() => getIt.reset());
  setUpAll(loadCertificateFonts);

  testWidgets(
    'initial and filled design keep all three fields selectable and derived details read-only',
    (tester) async {
      await mountCertificate(tester, const ProxyDepositScreen());
      expect(tester.getTopLeft(find.byType(AppSelect<ProxyCompany>)).dy, 104);
      expect(tester.getTopLeft(find.byType(AppSelect<ProxySubject>)).dy, 194);
      expect(tester.getTopLeft(find.byType(AppSelect<ListedDeposit>)).dy, 284);
      expect(find.byType(ProxySubjectDetails), findsNothing);
      expect(tester.widget<AppButton>(proxySubmitButton()).onPressed, isNull);
      await captureProxy(tester, 'initial');
      await selectProxySubject(tester);
      await tester.tap(find.byType(AppSelect<ListedDeposit>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('10.1234567.2').last);
      await tester.pumpAndSettle();
      expect(find.byType(ProxySubjectDetails), findsOneWidget);
      expect(
        tester
            .widget<AppSelect<ProxySubject>>(
              find.byType(AppSelect<ProxySubject>),
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
        tester.widget<AppButton>(proxySubmitButton()).onPressed,
        isNotNull,
      );
      await captureProxy(tester, 'filled');
      await tester.tap(proxySubmitButton());
      await tester.pumpAndSettle();
      expect(find.byType(ProxyDepositReceiptDialog), findsOneWidget);
      expect(
        find.textContaining(S.current.proxyDepositMockComplete),
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
        const ProxyDepositScreen(initialDepositNumber: '10.1234567.2'),
      );
      await selectProxySubject(tester);
      await tester.tap(find.byType(AppCheckbox));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AppSelect<ProxyCompany>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('شرکت آزمایشی').last);
      await tester.pumpAndSettle();
      expect(find.byType(ProxySubjectDetails), findsNothing);
      expect(
        tester.widget<AppCheckbox>(find.byType(AppCheckbox)).value,
        isFalse,
      );
      await tester.tap(find.byType(AppSelect<ProxySubject>));
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
      expect(tester.widget<AppButton>(proxySubmitButton()).onPressed, isNull);
    },
  );

  testWidgets(
    'catalog retry, loading controls, Back and submission retry preserve the original request',
    (tester) async {
      final repository = PendingProxyRepository();
      getIt.unregister<ProxyDepositsRepository>();
      getIt.registerSingleton<ProxyDepositsRepository>(repository);
      await mountCertificate(
        tester,
        const ProxyDepositScreen(initialDepositNumber: '10.1234567.2'),
      );
      expect(find.text('درخواست انجام نشد. دوباره تلاش کنید.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      repository.failsCatalog = false;
      await tester.tap(find.text(S.current.dashboardRetry));
      await tester.pumpAndSettle();
      await selectProxySubject(tester);
      await tester.tap(find.byType(AppCheckbox));
      await tester.pumpAndSettle();
      await tester.tap(proxySubmitButton());
      await tester.pump();
      expect(tester.widget<AppButton>(proxySubmitButton()).isLoading, isTrue);
      expect(
        tester
            .widget<AppSelect<ProxyCompany>>(
              find.byType(AppSelect<ProxyCompany>),
            )
            .enabled,
        isFalse,
      );
      expect(
        tester
            .widget<AppSelect<ProxySubject>>(
              find.byType(AppSelect<ProxySubject>),
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
      await tester.tap(proxySubmitButton());
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
      await tester.tap(proxySubmitButton());
      await tester.pumpAndSettle();
      expect(repository.requests.first, repository.requests.last);
      expect(find.byType(ProxyDepositReceiptDialog), findsOneWidget);
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
      expect(find.byType(ProxyDepositScreen), findsOneWidget);
      final cubit = tester
          .element(find.byType(ProxyDepositForm))
          .read<ProxyDepositCubit>();
      expect(cubit.state.deposit!.id, 'proxy-2');
    },
  );

  for (final locale in ['fa', 'en', 'ar']) {
    testWidgets(
      'filled $locale form remains scrollable at 320px and larger text',
      (tester) async {
        await mountCertificate(
          tester,
          const ProxyDepositScreen(initialDepositNumber: '10.1234567.2'),
          size: const Size(320, 640),
          scale: 1.5,
          locale: locale,
        );
        final cubit = tester
            .element(find.byType(ProxyDepositForm))
            .read<ProxyDepositCubit>();
        cubit.selectSubject(cubit.state.subjects.first);
        await tester.pumpAndSettle();
        await tester.drag(
          find.byType(SingleChildScrollView).first,
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ProxySubjectDetails), findsOneWidget);
        expect(
          tester.getBottomRight(proxySubmitButton()).dy,
          lessThanOrEqualTo(600),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
