import 'dart:typed_data';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/platform/selected_document.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/transfers/data/repositories/mock_on_site_transfer_repository.dart';
import 'package:pishkhan_mobile/features/transfers/domain/repositories/on_site_transfer_repository.dart';
import 'package:pishkhan_mobile/features/transfers/presentation/on_site_transfer/cubit/on_site_transfer_cubit.dart';
import 'package:pishkhan_mobile/features/transfers/presentation/on_site_transfer/screens/on_site_transfer_screen.dart';
import 'package:pishkhan_mobile/features/transfers/presentation/on_site_transfer/widgets/transfer_destination_sheet.dart';
import 'package:pishkhan_mobile/features/transfers/presentation/on_site_transfer/widgets/transfer_receipt_dialog.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../deposits/certificate_test_support.dart';

class RetryingTransferRepository extends MockOnSiteTransferRepository {
  RetryingTransferRepository()
    : super(now: () => DateTime.utc(2026, 10, 20, 8));
  bool failDestination = true;
  bool failSubmission = true;
  final requests = <OnSiteTransferRequest>[];
  @override
  Future<Result<TransferDestination>> resolveDestination({
    required String iban,
    required int amountRial,
    required TransferPurpose purpose,
    required String description,
  }) => failDestination
      ? Future.value(const Err(DataFailure('timeout')))
      : super.resolveDestination(
          iban: iban,
          amountRial: amountRial,
          purpose: purpose,
          description: description,
        );
  @override
  Future<Result<TransferReceipt>> submit(OnSiteTransferRequest request) {
    requests.add(request);
    return failSubmission
        ? Future.value(const Err(DataFailure('timeout')))
        : super.submit(request);
  }
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
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
  }
}

void main() {
  setUpAll(loadCertificateFonts);
  setUp(configureDependencies);
  tearDown(() => getIt.reset());

  test(
    'transfer adapter converts unexpected catalog and progress errors to Err',
    () async {
      final catalog = await MockOnSiteTransferRepository(
        now: () => throw StateError('clock'),
      ).fetchCatalog();
      expect(catalog, const Err<TransferCatalog>(UnexpectedFailure()));
      final upload = await MockOnSiteTransferRepository().uploadDestinations(
        SelectedDocument(name: 'targets.xls', bytes: Uint8List.fromList([1])),
        (_) => throw StateError('unexpected progress processing'),
      );
      expect(upload, const Err<TransferAttachment>(UnexpectedFailure()));
    },
  );

  testWidgets(
    'manual lookup and transfer failures repeat; close, feedback and receipt ignore old text',
    (tester) async {
      final repository = RetryingTransferRepository();
      await getIt.unregister<OnSiteTransferRepository>();
      getIt.registerSingleton<OnSiteTransferRepository>(repository);
      await mountCertificate(tester, const OnSiteTransferScreen());
      final cubit = tester
          .element(find.byType(AppTopBar))
          .read<OnSiteTransferCubit>();
      cubit.selectDeposit(cubit.state.catalog!.deposits.first);
      cubit.updateTransferDate(
        JalaliDateFormatter.format(
          DateTime.utc(2026, 10, 21),
          usePersianDigits: false,
        ),
      );
      await cubit.continueFlow();
      cubit.selectAddress(cubit.state.addresses.first);
      cubit.updateVisitDate(
        JalaliDateFormatter.format(
          DateTime.utc(2026, 10, 20),
          usePersianDigits: false,
        ),
      );
      await cubit.continueFlow();
      cubit.requestDestinationEditor();
      await tester.pumpAndSettle();
      cubit.updateAmount('2000000000');
      cubit.selectMethod(TransferMethod.satna);
      cubit.updateIban('820540102680020817909002');
      cubit.selectPurpose(TransferPurpose.salary);
      await repeatFailure(tester, cubit.submitDestination);
      repository.failDestination = false;
      final lookup = cubit.submitDestination();
      await tester.pumpAndSettle();
      await lookup;
      expect(find.byType(TransferDestinationSheet), findsNothing);
      expect(cubit.state.destinations, hasLength(1));
      expect(find.byType(SnackBar), findsNothing);
      cubit.requestUnavailable();
      await tester.pumpAndSettle();
      expect(find.text(S.current.cardFeatureUnavailable), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await cubit.continueFlow();
      cubit.updateTerms(true);
      await repeatFailure(tester, cubit.submitTransfer);
      repository.failSubmission = false;
      final submission = cubit.submitTransfer();
      await tester.pumpAndSettle();
      await submission;
      expect(cubit.state.submissionStatus, RequestStatus.success);
      expect(cubit.state.failure, isNotNull);
      expect(repository.requests.toSet(), hasLength(1));
      expect(find.byType(TransferReceiptDialog), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
