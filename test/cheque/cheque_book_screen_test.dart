import 'dart:async';
import 'dart:io';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';
import 'package:pishkhan_mobile/core/flow/service_registry.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/cheque/data/repositories/mock_cheque_book_repository.dart';
import 'package:pishkhan_mobile/features/cheque/domain/entities/cheque_book.dart';
import 'package:pishkhan_mobile/features/cheque/domain/repositories/cheque_book_repository.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/book_issuance/cubit/cheque_book_cubit.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/book_issuance/screens/cheque_book_screen.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/book_issuance/widgets/cheque_book_delivery.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/book_issuance/widgets/cheque_book_receipt_dialog.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/features/address/presentation/editor/widgets/address_editor_form.dart';
import 'package:pishkhan_mobile/shared/widgets/app_delete_address_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/app_invoice.dart';

import '../deposits/certificate_test_support.dart';
import 'cheque_book_test_support.dart';

Finder nextButton() => find.widgetWithText(AppButton, S.current.issuanceNext);
Finder submitButton() => find.byWidgetPredicate(
  (widget) => widget is AppButton && widget.label == S.current.chequeSubmit,
);

Future<void> captureBook(WidgetTester tester, String name) async {
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
    await tester.pump();
  }
  await captureCertificate(tester, name);
}

void main() {
  setUpAll(loadCertificateFonts);
  setUp(configureDependencies);
  tearDown(() => getIt.reset());
  void install(TestChequeBookRepository repository) {
    getIt.unregister<ChequeBookRepository>();
    getIt.registerSingleton<ChequeBookRepository>(repository);
  }

  Future<void> selectBook(WidgetTester tester) async {
    await tester.tap(find.byType(AppSelect<ChequeBookDeposit>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10.1234567.1').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AppSelect<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('۵۰').last);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'individual selects address, controls optional recipients and submits once',
    (tester) async {
      final repository = TestChequeBookRepository();
      install(repository);
      await mountCertificate(tester, const ChequeBookScreen());
      expect(tester.widget<AppButton>(nextButton()).onPressed, isNull);
      await captureBook(tester, 'chequebook-initial');
      await selectBook(tester);
      await captureBook(tester, 'chequebook-selected');
      await tester.tap(nextButton());
      await tester.pumpAndSettle();
      expect(find.byType(ChequeBookDelivery), findsOneWidget);
      expect(tester.widget<AppButton>(nextButton()).onPressed, isNull);
      await captureBook(tester, 'chequebook-individual-delivery');
      await tester.tap(find.byType(AppSelect<DeliveryAddress>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('خانه').last);
      await tester.pumpAndSettle();
      await captureBook(tester, 'chequebook-address-selected');
      await tester.tap(nextButton());
      await tester.pumpAndSettle();
      expect(find.byType(AppInvoice), findsOneWidget);
      await captureBook(tester, 'chequebook-confirmation');
      await tester.tap(submitButton());
      await tester.pumpAndSettle();
      expect(find.byType(ChequeBookReceiptDialog), findsOneWidget);
      expect(repository.requests, hasLength(1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'legal recipient form uses shared fields and validates national ID live',
    (tester) async {
      install(TestChequeBookRepository(applicant: ChequeBookApplicant.legal));
      await mountCertificate(
        tester,
        const ChequeBookScreen(initialDepositNumber: '10.1234567.1'),
      );
      await selectBook(tester);
      await tester.tap(nextButton());
      await tester.pumpAndSettle();
      expect(find.byType(AppSelect<DeliveryAddress>), findsNothing);
      expect(find.byType(AppToggle), findsNothing);
      await captureBook(tester, 'chequebook-legal-empty');
      await tester.enterText(find.byType(AppTextField).first, 'آرمان پارسی');
      await tester.enterText(find.byType(AppTextField).last, '008');
      await tester.pumpAndSettle();
      expect(find.text(S.current.authInvalidNationalId), findsOneWidget);
      expect(tester.widget<AppButton>(nextButton()).onPressed, isNull);
      await tester.enterText(find.byType(AppTextField).last, '0081234562');
      await tester.pumpAndSettle();
      expect(tester.widget<AppButton>(nextButton()).onPressed, isNotNull);
      await captureBook(tester, 'chequebook-legal-filled');
      expect(tester.takeException(), isNull);
    },
  );

  for (final registered in [
    [false],
    [false, true],
    [false, false],
  ]) {
    testWidgets(
      'registry addresses $registered render correct warning and deletion availability',
      (tester) async {
        install(TestChequeBookRepository(registered: registered));
        await mountCertificate(tester, const ChequeBookScreen());
        await selectBook(tester);
        await tester.tap(nextButton());
        await tester.pumpAndSettle();
        await captureBook(
          tester,
          'chequebook-residency-${registered.join('-')}',
        );
        expect(find.text(S.current.chequeBookRegistryHost), findsOneWidget);
        expect(
          find.bySemanticsLabel(S.current.issuanceDeleteAddress),
          registered.length > 1 ? findsNWidgets(2) : findsNothing,
        );
        if (registered.length > 1) {
          await tester.tap(
            find.bySemanticsLabel(S.current.issuanceDeleteAddress).first,
          );
          await tester.pumpAndSettle();
          expect(find.byType(AppDeleteAddressSheet), findsOneWidget);
          await captureCertificate(
            tester,
            'chequebook-delete-${registered.join('-')}',
          );
          await tester.tap(find.text(S.current.agentCancel));
          await tester.pumpAndSettle();
          expect(find.byType(AppDeleteAddressSheet), findsNothing);
          await tester.tap(
            find.bySemanticsLabel(S.current.issuanceDeleteAddress).first,
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text(S.current.chequeBookDeleteContinue));
          await tester.pumpAndSettle();
          expect(find.byType(AppDeleteAddressSheet), findsNothing);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'add address reuses the existing modal and cancellation leaves selection empty',
    (tester) async {
      install(TestChequeBookRepository());
      await mountCertificate(tester, const ChequeBookScreen());
      await selectBook(tester);
      await tester.tap(nextButton());
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.issuanceAddAddress));
      await tester.pumpAndSettle();
      expect(find.byType(AddressEditorForm), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(tester.widget<AppButton>(nextButton()).onPressed, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'my addresses is explicitly unavailable; official registry opens native browser',
    (tester) async {
      install(TestChequeBookRepository(registered: [false]));
      String? method;
      const channel = MethodChannel('pishkhan/external_links');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        method = call.method;
        return null;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      await mountCertificate(tester, const ChequeBookScreen());
      await selectBook(tester);
      await tester.tap(nextButton());
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.chequeBookMyAddresses));
      await tester.pump();
      expect(find.text(S.current.chequeContentUnavailable), findsOneWidget);
      await tester.tap(find.text(S.current.chequeBookRegistryHost));
      await tester.pumpAndSettle();
      expect(method, 'openRegistry');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('submission loading disables duplicate confirmation', (
    tester,
  ) async {
    final pending = Completer<Result<ChequeBookReceipt>>();
    final repository = TestChequeBookRepository()..pendingSubmission = pending;
    install(repository);
    await mountCertificate(tester, const ChequeBookScreen());
    await selectBook(tester);
    await tester.tap(nextButton());
    await tester.pumpAndSettle();
    final cubit = tester
        .element(find.byType(ChequeBookDelivery))
        .read<ChequeBookCubit>();
    cubit.selectAddress(cubit.state.deliveryAddresses.first);
    await tester.pumpAndSettle();
    await tester.tap(nextButton());
    await tester.pumpAndSettle();
    await tester.tap(submitButton());
    await tester.pump();
    await tester.tap(submitButton());
    expect(repository.requests, hasLength(1));
    pending.complete(
      const Success(ChequeBookReceipt(reference: 'pending', isMock: true)),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'real mock waits two seconds before advancing and central service preserves entry deposit',
    (tester) async {
      expect(getIt<ChequeBookRepository>(), isA<MockChequeBookRepository>());
      await mountCertificate(
        tester,
        Builder(
          builder: (context) => AppButton(
            label: 'open',
            onPressed: () => ServiceRegistry.openCardService(
              context,
              'cheque-issue',
              initialDepositNumber: '10.1234567.1',
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(ChequeBookScreen), findsOneWidget);
      await tester.tap(find.byType(AppSelect<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('۵۰').last);
      await tester.pumpAndSettle();
      await tester.tap(nextButton());
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(S.current.chequeBookChecking), findsOneWidget);
      await captureBook(tester, 'chequebook-checking');
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.byType(ChequeBookDelivery), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final locale in ['fa', 'en', 'ar']) {
    testWidgets('small viewport and large text are usable in $locale', (
      tester,
    ) async {
      install(TestChequeBookRepository());
      await mountCertificate(
        tester,
        const ChequeBookScreen(),
        locale: locale,
        size: const Size(320, 640),
        scale: 1.5,
      );
      expect(tester.takeException(), isNull);
      expect(tester.getBottomRight(nextButton()).dy, lessThanOrEqualTo(600));
    });
  }
}
