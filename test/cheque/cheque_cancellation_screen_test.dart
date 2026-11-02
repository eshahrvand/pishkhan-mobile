import 'package:pishkhan_mobile/core/config/constant.dart';

import 'dart:async';
import 'dart:io';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/flow/service_registry.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/cheque/domain/entities/cheque_cancellation.dart';
import 'package:pishkhan_mobile/features/cheque/domain/entities/cheque_clearance.dart';
import 'package:pishkhan_mobile/features/cheque/domain/repositories/cheque_cancellation_repository.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/cancellation/cubit/cheque_cancellation_cubit.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/cancellation/screens/cheque_cancellation_screen.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/cancellation/widgets/cheque_cancellation_delete_sheet.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/cancellation/widgets/cheque_cancellation_receipt_dialog.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/cancellation/widgets/cheque_cancellation_review_sheet.dart';
import 'package:pishkhan_mobile/features/postal_offices/presentation/lookup/widgets/postal_offices_sheet.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../deposits/certificate_test_support.dart';
import 'cheque_cancellation_test_support.dart';

Finder button(String label) => find.byWidgetPredicate(
  (widget) => widget is AppButton && widget.label == label,
);
ChequeCancellationCubit cancellationCubit(WidgetTester tester) =>
    tester.element(find.byType(AppTopBar)).read<ChequeCancellationCubit>();
Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tapAt(tester.getCenter(finder));
  await tester.pumpAndSettle();
}

Future<void> captureCancellation(WidgetTester tester, String name) async {
  if (Platform.environment['CAPTURE_CERTIFICATE_PREVIEWS'] != '1') return;
  for (var attempt = 0; attempt < 60; attempt++) {
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
  late TestChequeCancellationRepository repository;
  setUpAll(loadCertificateFonts);
  setUp(() {
    configureDependencies();
    getIt.unregister<ChequeCancellationRepository>();
    repository = TestChequeCancellationRepository();
    getIt.registerSingleton<ChequeCancellationRepository>(repository);
  });
  tearDown(() => getIt.reset());
  Future<void> selection(
    WidgetTester tester, {
    int deposit = 1,
    bool digital = false,
  }) async {
    await tap(tester, find.byType(AppSelect<ChequeDeposit>));
    await tap(tester, find.text('10.1234567.$deposit').last);
    await tap(tester, find.byType(AppSelect<CancellationChequeType>));
    await tap(
      tester,
      find
          .text(
            digital
                ? S.current.chequeCancelDigital
                : S.current.chequeCancelPaper,
          )
          .last,
    );
    await tap(tester, button(S.current.issuanceNext));
  }

  Future<void> enterReasons(WidgetTester tester) async {
    await selection(tester);
    for (var index = 0; index < 3; index++) {
      await tap(tester, find.byType(AppCheckbox).at(index));
    }
    await tap(tester, button(S.current.issuanceNext));
    expect(find.byType(ChequeCancellationReviewSheet), findsOneWidget);
    await captureCancellation(tester, 'cheque-cancel-review');
    await tap(tester, button(S.current.backLabel));
    expect(
      cancellationCubit(tester).state.step,
      ChequeCancellationStep.reasons,
    );
  }

  Future<void> commonReason(WidgetTester tester) async {
    await tap(tester, button(S.current.chequeCancelAllReasons));
    await captureCancellation(tester, 'cheque-cancel-common-reason');
    await tap(tester, find.text(S.current.chequeCancelDamaged).last);
    await captureCancellation(tester, 'cheque-cancel-selected-reason');
    await tap(tester, button(S.current.chequeCancelChoose));
  }

  testWidgets(
    'complete paper flow reviews selected cheques, assigns reasons, opens postal offices and submits once',
    (tester) async {
      await mountCertificate(tester, const ChequeCancellationScreen());
      expect(
        tester.widget<AppButton>(button(S.current.issuanceNext)).onPressed,
        isNull,
      );
      await captureCancellation(tester, 'cheque-cancel-initial');
      await enterReasons(tester);
      await captureCancellation(tester, 'cheque-cancel-reasons-empty');
      await commonReason(tester);
      expect(
        cancellationCubit(tester).state.selectedEntries.every(
          (entry) => entry.reason == ChequeCancellationReason.damagedUnused,
        ),
        isTrue,
      );
      await tap(tester, find.byType(AppSelect<ChequeCancellationReason>).first);
      await tap(tester, find.text(S.current.chequeCancelJudicial).last);
      await tap(tester, button(S.current.chequeCancelChoose));
      await tester.ensureVisible(find.byType(AppStepper));
      await tester.pumpAndSettle();
      await captureCancellation(tester, 'cheque-cancel-reasons-filled');
      await tap(tester, button(S.current.issuanceNext));
      expect(
        tester.widget<AppButton>(button(S.current.chequeSubmit)).onPressed,
        isNull,
      );
      await tap(tester, button(S.current.chequeCancelDownload));
      expect(find.text(S.current.chequeContentUnavailable), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tap(tester, find.text(S.current.chequePostalAction));
      expect(find.byType(PostalOfficesSheet), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tap(tester, find.byType(AppCheckbox));
      expect(cancellationCubit(tester).state.termsAccepted, isTrue);
      expect(cancellationCubit(tester).state.canContinue, isTrue);
      await captureCancellation(tester, 'cheque-cancel-confirmation');
      await tap(tester, button(S.current.chequeSubmit));
      expect(find.byType(ChequeCancellationReceiptDialog), findsOneWidget);
      expect(repository.requests, hasLength(1));
      expect(
        repository.requests.single.entries.first.reason,
        ChequeCancellationReason.judicialOrder,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'search and clear preserve selection; select-all and digital empty state',
    (tester) async {
      await mountCertificate(tester, const ChequeCancellationScreen());
      await selection(tester);
      await captureCancellation(tester, 'cheque-cancel-list');
      expect(
        tester.getSize(
          find.byWidgetPredicate(
            (widget) =>
                widget is AvpImage &&
                widget.image ==
                    '${AppConstants.baseImage}card_features_search.svg',
          ),
        ),
        const Size(20, 20),
      );
      await tap(tester, find.byType(AppToggle));
      expect(cancellationCubit(tester).state.selectedEntries, hasLength(10));
      await captureCancellation(tester, 'cheque-cancel-all-selected');
      await tap(tester, find.byType(AppToggle));
      await tester.enterText(find.byType(AppTextField), '۱۳۷/۴۸۷۵۶۷');
      await tester.pumpAndSettle();
      expect(find.byType(AppCheckbox), findsOneWidget);
      expect(find.byType(AppToggle), findsNothing);
      await tap(tester, find.byType(AppCheckbox));
      await captureCancellation(tester, 'cheque-cancel-search');
      await tap(tester, find.byType(IconButton));
      expect(cancellationCubit(tester).state.selectedEntries, hasLength(1));
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await selection(tester, deposit: 2, digital: true);
      expect(find.text(S.current.chequeCancelEmpty), findsOneWidget);
      expect(
        tester.widget<AppButton>(button(S.current.issuanceNext)).onPressed,
        isNull,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'review deletion opens once, cancel retains cheque, confirm updates list and next stage',
    (tester) async {
      await mountCertificate(tester, const ChequeCancellationScreen());
      await selection(tester);
      await tap(tester, find.byType(AppCheckbox).first);
      await tap(tester, button(S.current.issuanceNext));
      final remove = find.ancestor(
        of: find.byWidgetPredicate(
          (widget) =>
              widget is AvpImage &&
              widget.image == '${AppConstants.baseImage}issuance_trash.svg',
        ),
        matching: find.byType(InkWell),
      );
      await tap(tester, remove.last);
      expect(find.byType(ChequeCancellationDeleteSheet), findsOneWidget);
      await captureCancellation(tester, 'cheque-cancel-delete-review');
      await tap(tester, button(S.current.dashboardCancel));
      expect(cancellationCubit(tester).state.selectedEntries, hasLength(1));
      await tap(tester, remove.last);
      await tap(tester, button(S.current.chequeCancelRemove));
      expect(find.text(S.current.chequeCancelEmpty), findsOneWidget);
      await tap(tester, button(S.current.backLabel));
      expect(
        cancellationCubit(tester).state.step,
        ChequeCancellationStep.cheques,
      );
      expect(
        tester.widget<AppButton>(button(S.current.issuanceNext)).onPressed,
        isNull,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'reason cancellation discards draft and removing final selection returns to list',
    (tester) async {
      await mountCertificate(tester, const ChequeCancellationScreen());
      await enterReasons(tester);
      await tap(tester, find.byType(AppSelect<ChequeCancellationReason>).first);
      await captureCancellation(tester, 'cheque-cancel-single-reason');
      await tap(tester, find.text(S.current.chequeCancelJudicial).last);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(
        cancellationCubit(tester).state.selectedEntries.first.reason,
        isNull,
      );
      while (cancellationCubit(tester).state.selectedEntries.isNotEmpty) {
        await tap(
          tester,
          find.bySemanticsLabel(S.current.chequeCancelRemove).first,
        );
        await captureCancellation(tester, 'cheque-cancel-delete-reason');
        await tap(tester, button(S.current.chequeCancelRemove));
      }
      expect(
        cancellationCubit(tester).state.step,
        ChequeCancellationStep.cheques,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('320px enlarged text keeps reason sheets and footer usable', (
    tester,
  ) async {
    await mountCertificate(
      tester,
      const ChequeCancellationScreen(),
      size: const Size(320, 640),
      scale: 1.4,
    );
    await enterReasons(tester);
    await commonReason(tester);
    await tap(tester, button(S.current.issuanceNext));
    await tap(tester, find.byType(AppCheckbox));
    await tap(tester, button(S.current.chequeSubmit));
    expect(find.byType(ChequeCancellationReceiptDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'service registry opens cancellation route and forwards deposit',
    (tester) async {
      await mountCertificate(
        tester,
        Builder(
          builder: (context) => AppButton(
            label: 'open',
            onPressed: () => ServiceRegistry.openCardService(
              context,
              'cheque-cancel',
              initialDepositNumber: '10.1234567.2',
            ),
          ),
        ),
      );
      await tap(tester, button('open'));
      expect(find.byType(ChequeCancellationScreen), findsOneWidget);
      expect(cancellationCubit(tester).state.deposit!.number, '10.1234567.2');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'pending submit ignores repeat taps while system back is blocked',
    (tester) async {
      await mountCertificate(tester, const ChequeCancellationScreen());
      await enterReasons(tester);
      await commonReason(tester);
      await tap(tester, button(S.current.issuanceNext));
      await tap(tester, find.byType(AppCheckbox));
      repository.pendingSubmission =
          Completer<Result<ChequeCancellationReceipt>>();
      await tester.tap(button(S.current.chequeSubmit));
      await tester.pump();
      await tester.tap(button(S.current.chequeSubmit));
      expect(repository.requests, hasLength(1));
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(
        cancellationCubit(tester).state.step,
        ChequeCancellationStep.confirmation,
      );
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(
        cancellationCubit(tester).state.step,
        ChequeCancellationStep.confirmation,
      );
      repository.pendingSubmission!.complete(
        const Success(
          ChequeCancellationReceipt(reference: 'test', isMock: true),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ChequeCancellationReceiptDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
