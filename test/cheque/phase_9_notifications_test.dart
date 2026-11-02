import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/cheque/domain/entities/cheque_book.dart';
import 'package:pishkhan_mobile/features/cheque/domain/entities/cheque_cancellation.dart';
import 'package:pishkhan_mobile/features/cheque/domain/entities/cheque_clearance.dart';
import 'package:pishkhan_mobile/features/cheque/domain/repositories/cheque_book_repository.dart';
import 'package:pishkhan_mobile/features/cheque/domain/repositories/cheque_cancellation_repository.dart';
import 'package:pishkhan_mobile/features/cheque/domain/repositories/cheque_clearance_repository.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/book_issuance/cubit/cheque_book_cubit.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/book_issuance/screens/cheque_book_screen.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/book_issuance/widgets/cheque_book_content.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/book_issuance/widgets/cheque_book_receipt_dialog.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/cancellation/cubit/cheque_cancellation_cubit.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/cancellation/screens/cheque_cancellation_screen.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/cancellation/widgets/cheque_cancellation_review_sheet.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/cancellation/widgets/cheque_cancellation_reason_sheet.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/cancellation/widgets/cheque_cancellation_receipt_dialog.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/clearance/cubit/cheque_clearance_cubit.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/clearance/screens/cheque_clearance_screen.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/clearance/widgets/cheque_clearance_receipt_dialog.dart';
import 'package:pishkhan_mobile/features/postal_offices/presentation/lookup/widgets/postal_offices_sheet.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../deposits/certificate_test_support.dart';
import 'cheque_book_test_support.dart';
import 'cheque_cancellation_test_support.dart';
import 'cheque_clearance_cubit_test.dart' show ControlledChequeRepository;

class RetryingBookRepository extends TestChequeBookRepository {
  RetryingBookRepository() : super(registered: [false, true]);
  bool failsResidency = true;
  bool failsSave = true;
  @override
  Future<Result<ChequeBookResidency>> checkResidency(String depositId) =>
      failsResidency
      ? Future.value(const Err(DataFailure('timeout')))
      : super.checkResidency(depositId);
  @override
  Future<Result<DeliveryAddress>> saveDeliveryAddress(
    DeliveryAddress address,
  ) => failsSave
      ? Future.value(const Err(DataFailure('timeout')))
      : super.saveDeliveryAddress(address);
}

Future<void> clearSnack(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
  expect(find.byType(SnackBar), findsNothing);
}

Future<void> repeatFailure(
  WidgetTester tester,
  Future<void> Function() action,
) async {
  for (var attempt = 0; attempt < 2; attempt++) {
    final request = action();
    await tester.pumpAndSettle();
    await request;
    expect(find.byType(SnackBar), findsOneWidget);
    await clearSnack(tester);
  }
}

void main() {
  setUpAll(loadCertificateFonts);
  setUp(configureDependencies);
  tearDown(() => getIt.reset());

  testWidgets(
    'clearance retry errors repeat; postal/content and success receipt ignore retained failure',
    (tester) async {
      final repository = ControlledChequeRepository()
        ..submissionResult = const Err(DataFailure('timeout'));
      await getIt.unregister<ChequeClearanceRepository>();
      getIt.registerSingleton<ChequeClearanceRepository>(repository);
      await mountCertificate(tester, const ChequeClearanceScreen());
      final cubit = tester
          .element(find.byType(AppTopBar))
          .read<ChequeClearanceCubit>();
      cubit.selectDeposit(cubit.state.catalog!.deposits.first);
      cubit.updateChequeNumber('123/123456');
      cubit.selectReason(ChequeClearanceReason.originalCheque);
      cubit.updateTermsAcceptance(true);
      await repeatFailure(tester, cubit.submitClearance);
      cubit.requestPostalOffices();
      await tester.pumpAndSettle();
      expect(find.byType(PostalOfficesSheet), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      Navigator.of(tester.element(find.byType(PostalOfficesSheet))).pop();
      await tester.pumpAndSettle();
      cubit.requestTerms();
      await tester.pumpAndSettle();
      expect(find.text(S.current.chequeContentUnavailable), findsOneWidget);
      await clearSnack(tester);
      repository.submissionResult = null;
      final request = cubit.submitClearance();
      await tester.pumpAndSettle();
      await request;
      expect(cubit.state.submissionStatus, RequestStatus.success);
      expect(cubit.state.failure, isNotNull);
      expect(repository.submissions.toSet(), hasLength(1));
      expect(find.byType(ChequeClearanceReceiptDialog), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'cancellation list and submit failures repeat; review/reason and receipt remain available',
    (tester) async {
      final repository = TestChequeCancellationRepository()
        ..controlLists = true
        ..submissionResult = const Err(DataFailure('timeout'));
      await getIt.unregister<ChequeCancellationRepository>();
      getIt.registerSingleton<ChequeCancellationRepository>(repository);
      await mountCertificate(tester, const ChequeCancellationScreen());
      final cubit = tester
          .element(find.byType(AppTopBar))
          .read<ChequeCancellationCubit>();
      cubit.selectDeposit(cubit.state.catalog!.deposits.first);
      cubit.selectType(CancellationChequeType.paper);
      await repeatFailure(tester, () {
        final request = cubit.fetchCheques();
        repository.listRequests.last.complete(
          const Err(DataFailure('timeout')),
        );
        return request;
      });
      repository.controlLists = false;
      await cubit.fetchCheques();
      cubit.toggleCheque(cubit.state.cheques.first);
      await cubit.continueFlow();
      await tester.pumpAndSettle();
      expect(find.byType(ChequeCancellationReviewSheet), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      Navigator.of(tester.element(find.byType(ChequeCancellationReviewSheet)))
          .pop(true);
      await tester.pumpAndSettle();
      expect(cubit.state.step, ChequeCancellationStep.reasons);
      cubit.requestReason(cubit.state.selectedEntries.single);
      await tester.pumpAndSettle();
      expect(find.byType(ChequeCancellationReasonSheet), findsOneWidget);
      cubit.selectReasonDraft(ChequeCancellationReason.damagedUnused);
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.chequeCancelChoose));
      await tester.pumpAndSettle();
      await cubit.continueFlow();
      cubit.updateTermsAcceptance(true);
      await repeatFailure(tester, cubit.submitCancellation);
      cubit.requestLetter();
      await tester.pumpAndSettle();
      expect(find.text(S.current.chequeContentUnavailable), findsOneWidget);
      await clearSnack(tester);
      repository.submissionResult = null;
      final request = cubit.submitCancellation();
      await tester.pumpAndSettle();
      await request;
      expect(cubit.state.submissionStatus, RequestStatus.success);
      expect(cubit.state.failure, isNotNull);
      expect(repository.requests.toSet(), hasLength(1));
      expect(find.byType(ChequeCancellationReceiptDialog), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'each book operation reports repeated errors; recovery and submission preserve the confirmed identity',
    (tester) async {
      final repository = RetryingBookRepository()..throwsCatalog = true;
      await getIt.unregister<ChequeBookRepository>();
      getIt.registerSingleton<ChequeBookRepository>(repository);
      await mountCertificate(tester, const ChequeBookScreen());
      final cubit = tester
          .element(find.byType(ChequeBookContent))
          .read<ChequeBookCubit>();
      expect(find.byType(SnackBar), findsOneWidget);
      await clearSnack(tester);
      await cubit.fetchCatalog();
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      await clearSnack(tester);
      repository.throwsCatalog = false;
      await cubit.fetchCatalog();
      cubit.selectDeposit(cubit.state.catalog!.deposits.first);
      cubit.selectLeafCount(50);
      await repeatFailure(tester, cubit.fetchResidency);
      repository.failsResidency = false;
      await cubit.fetchResidency();
      final residence = cubit.state.residency!.residences.first.address;
      repository.failsDeletion = true;
      await repeatFailure(tester, () => cubit.deleteAddress(residence));
      repository.failsDeletion = false;
      await cubit.deleteAddress(residence);
      expect(cubit.state.step, ChequeBookStep.delivery);
      final address = cubit.state.deliveryAddresses.single;
      cubit.selectAddress(address);
      await repeatFailure(tester, () => cubit.applyAddressResult(address));
      repository.failsSave = false;
      await cubit.applyAddressResult(address);
      expect(cubit.state.address!.id, 'saved-address');
      repository.failsQuote = true;
      await repeatFailure(tester, cubit.fetchQuote);
      cubit.requestUnavailableContent();
      await tester.pumpAndSettle();
      expect(find.text(S.current.chequeContentUnavailable), findsOneWidget);
      await clearSnack(tester);
      repository.failsQuote = false;
      await cubit.fetchQuote();
      repository.failsSubmission = true;
      await repeatFailure(tester, cubit.submitIssuance);
      repository.failsSubmission = false;
      await cubit.submitIssuance();
      await tester.pumpAndSettle();
      expect(cubit.state.submissionStatus, RequestStatus.success);
      expect(cubit.state.failure, isNotNull);
      expect(repository.requests.toSet(), hasLength(1));
      expect(find.byType(ChequeBookReceiptDialog), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
