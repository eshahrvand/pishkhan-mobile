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
import 'package:pishkhan_mobile/features/deposits/data/repositories/mock_deposit_restrictions_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/deposit_restriction.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/deposit_restrictions_repository.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/deposit_restriction/cubit/deposit_restriction_cubit.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/deposit_restriction/screens/deposit_restriction_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/deposit_restriction/widgets/deposit_block_details.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/deposit_restriction/widgets/deposit_restriction_form.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/deposit_restriction/widgets/deposit_restriction_receipt_dialog.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_invoice.dart';

import 'certificate_test_support.dart';

Future<void> captureRestriction(WidgetTester tester, String name) async {
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
  await captureCertificate(tester, 'deposit-restriction-$name');
}

Finder submitRestrictionButton() => find.byWidgetPredicate(
  (widget) => widget is AppButton && widget.label == S.current.issuanceSubmit,
);

class PendingRestrictionRepository extends MockDepositRestrictionsRepository {
  bool failsCatalog = true;
  final submission = Completer<Result<DepositRestrictionReceipt>>();
  final requests = <DepositRestrictionRequest>[];
  @override
  Future<Result<DepositRestrictionCatalog>> fetchCatalog(
    DepositRestrictionOperation operation,
  ) {
    return failsCatalog
        ? Future.value(const Err(DataFailure('unavailable')))
        : super.fetchCatalog(operation);
  }

  @override
  Future<Result<DepositRestrictionReceipt>> submitRestriction(
    DepositRestrictionRequest request,
  ) {
    requests.add(request);
    return requests.length == 1
        ? submission.future
        : super.submitRestriction(request);
  }
}

void main() {
  setUp(configureDependencies);
  tearDown(() => getIt.reset());
  setUpAll(loadCertificateFonts);

  for (final operation in DepositRestrictionOperation.values) {
    testWidgets(
      '${operation.name} initial and filled design; explicit simulated receipt',
      (tester) async {
        await mountCertificate(
          tester,
          DepositRestrictionScreen(operation: operation),
        );
        expect(
          tester.widget<AppButton>(submitRestrictionButton()).onPressed,
          isNull,
        );
        expect(
          tester
              .getTopLeft(find.byType(AppSelect<DepositRestrictionOption>))
              .dy,
          144,
        );
        expect(
          tester.getTopLeft(find.byType(AppInvoice)).dy,
          operation == DepositRestrictionOperation.block ? 434 : 454,
        );
        await captureRestriction(tester, '${operation.name}-initial');
        await tester.tap(find.byType(AppSelect<DepositRestrictionOption>));
        await tester.pumpAndSettle();
        await tester.tap(
          find
              .text(
                operation == DepositRestrictionOperation.block
                    ? '10.1234567.1'
                    : '10.1234567.2',
              )
              .last,
        );
        await tester.pumpAndSettle();
        if (operation == DepositRestrictionOperation.unblock) {
          expect(find.byType(DepositBlockDetailsCard), findsOneWidget);
          expect(find.text('۱۴۰۴/۰۹/۱۰'), findsOneWidget);
        }
        await tester.ensureVisible(
          find.byType(AppSelect<DepositRestrictionReason>),
        );
        await tester.tap(find.byType(AppSelect<DepositRestrictionReason>));
        await tester.pumpAndSettle();
        await tester.tap(
          find.text(S.current.depositRestrictionManagement).last,
        );
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'شخصی');
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.tap(find.byType(AppCheckbox));
        await tester.pumpAndSettle();
        expect(
          tester.widget<AppButton>(submitRestrictionButton()).onPressed,
          isNotNull,
        );
        await captureRestriction(tester, '${operation.name}-filled');
        await tester.tap(submitRestrictionButton());
        await tester.pumpAndSettle();
        expect(find.byType(DepositRestrictionReceiptDialog), findsOneWidget);
        expect(
          find.textContaining(S.current.depositRestrictionMockComplete),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'failed catalog retries; pending controls gate taps while Back remains available',
    (tester) async {
      final repository = PendingRestrictionRepository();
      getIt.unregister<DepositRestrictionsRepository>();
      getIt.registerSingleton<DepositRestrictionsRepository>(repository);
      await mountCertificate(
        tester,
        const DepositRestrictionScreen(
          operation: DepositRestrictionOperation.block,
          initialDepositNumber: '10.1234567.1',
        ),
      );
      expect(find.text(S.current.dashboardLoadError), findsOneWidget);
      repository.failsCatalog = false;
      await tester.tap(find.text(S.current.dashboardRetry));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AppSelect<DepositRestrictionReason>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.depositRestrictionManagement));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AppCheckbox));
      await tester.pumpAndSettle();
      await tester.tap(submitRestrictionButton());
      await tester.pump();
      expect(
        tester.widget<AppButton>(submitRestrictionButton()).isLoading,
        isTrue,
      );
      expect(
        tester
            .widget<AppSelect<DepositRestrictionOption>>(
              find.byType(AppSelect<DepositRestrictionOption>),
            )
            .enabled,
        isFalse,
      );
      expect(
        tester.widget<AppCheckbox>(find.byType(AppCheckbox)).onChanged,
        isNull,
      );
      await tester.tap(submitRestrictionButton());
      await tester.pump();
      expect(repository.requests.length, 1);
      await tester.tap(find.byTooltip(S.current.backLabel));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AlertDialog), findsOneWidget);
      // Dismissal returns the raw result to Cubit and keeps the pending form alive.
      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 300));
      repository.submission.complete(const Err(DataFailure('timeout')));
      await tester.pumpAndSettle();
      expect(find.text(S.current.issuanceSubmitError), findsOneWidget);
      await tester.tap(submitRestrictionButton());
      await tester.pumpAndSettle();
      expect(repository.requests.first, repository.requests.last);
      expect(find.byType(DepositRestrictionReceiptDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final operation in DepositRestrictionOperation.values) {
    testWidgets(
      '${operation.name} service routes preserve eligible entry; no UI dependency resolution',
      (tester) async {
        await mountCertificate(
          tester,
          Builder(
            builder: (context) => AppButton(
              label: 'open',
              onPressed: () => ServiceRegistry.openCardService(
                context,
                operation == DepositRestrictionOperation.block
                    ? 'deposit-block'
                    : 'deposit-unblock',
                initialDepositNumber:
                    operation == DepositRestrictionOperation.block
                    ? '10.1234567.1'
                    : '10.1234567.2',
              ),
            ),
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        final cubit = tester
            .element(find.byType(DepositRestrictionForm))
            .read<DepositRestrictionCubit>();
        expect(cubit.operation, operation);
        expect(cubit.state.deposit, isNotNull);
      },
    );
  }

  for (final locale in ['fa', 'en', 'ar']) {
    testWidgets(
      'small $locale viewport and larger text keep filled unblock form scrollable',
      (tester) async {
        await mountCertificate(
          tester,
          const DepositRestrictionScreen(
            operation: DepositRestrictionOperation.unblock,
            initialDepositNumber: '10.1234567.2',
          ),
          size: const Size(320, 640),
          scale: 1.5,
          locale: locale,
        );
        await tester.drag(
          find.byType(SingleChildScrollView).first,
          const Offset(0, -650),
        );
        await tester.pumpAndSettle();
        expect(find.byType(AppInvoice), findsOneWidget);
        expect(
          tester.getBottomRight(submitRestrictionButton()).dy,
          lessThanOrEqualTo(600),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
