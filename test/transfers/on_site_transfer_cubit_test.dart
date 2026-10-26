import 'dart:async';
import 'dart:typed_data';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/platform/selected_document.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/transfers/data/repositories/mock_on_site_transfer_repository.dart';
import 'package:pishkhan_mobile/features/transfers/domain/repositories/on_site_transfer_repository.dart';
import 'package:pishkhan_mobile/features/transfers/presentation/on_site_transfer/cubit/on_site_transfer_cubit.dart';

String inputDate(DateTime date) =>
    JalaliDateFormatter.format(date, usePersianDigits: false);

class ControlledTransferRepository extends MockOnSiteTransferRepository {
  ControlledTransferRepository()
    : super(now: () => DateTime.utc(2026, 10, 20, 8));
  Completer<Result<TransferAttachment>>? pendingUpload;
  Completer<Result<TransferDestination>>? pendingDestination;
  final submissions = <OnSiteTransferRequest>[];
  bool failNextSubmission = false;
  @override
  Future<Result<TransferAttachment>> uploadDestinations(
    SelectedDocument file,
    void Function(double) onProgress,
  ) {
    if (pendingUpload != null) {
      onProgress(.4);
      return pendingUpload!.future;
    }
    return super.uploadDestinations(file, onProgress);
  }

  @override
  Future<Result<TransferDestination>> resolveDestination({
    required String iban,
    required int amountRial,
    required TransferPurpose purpose,
    required String description,
  }) {
    return pendingDestination?.future ??
        super.resolveDestination(
          iban: iban,
          amountRial: amountRial,
          purpose: purpose,
          description: description,
        );
  }

  @override
  Future<Result<TransferReceipt>> submit(OnSiteTransferRequest request) {
    submissions.add(request);
    if (failNextSubmission) {
      failNextSubmission = false;
      return Future.value(const Err(DataFailure('retry')));
    }
    return super.submit(request);
  }
}

void main() {
  late ControlledTransferRepository repository;
  late OnSiteTransferCubit cubit;
  setUp(() {
    repository = ControlledTransferRepository();
    getIt.registerSingleton<OnSiteTransferRepository>(repository);
    cubit = OnSiteTransferCubit();
  });
  tearDown(() async {
    await cubit.close();
    await getIt.reset();
  });
  Future<void> readyForDestinations() async {
    await cubit.fetchCatalog();
    cubit.selectDeposit(cubit.state.catalog!.deposits.first);
    cubit.updateTransferDate(inputDate(DateTime.utc(2026, 10, 21)));
    await cubit.continueFlow();
    cubit.selectAddress(cubit.state.addresses.first);
    cubit.updateVisitDate(inputDate(DateTime.utc(2026, 10, 20)));
    await cubit.continueFlow();
  }

  Future<void> addDestination({String amount = '2000000000'}) async {
    cubit.requestDestinationEditor();
    cubit.updateAmount(amount);
    cubit.selectMethod(TransferMethod.satna);
    cubit.updateIban('820540102680020817909002');
    cubit.selectPurpose(TransferPurpose.salary);
    cubit.updateDescription('123456789');
    await cubit.submitDestination();
  }

  test('construction preserves initial data; catalog resolves only real entry values', () async {
    expect(cubit.state, const OnSiteTransferState.initial());
    await cubit.fetchCatalog();
    expect(cubit.state.catalogStatus, RequestStatus.success);
    expect(cubit.state.deposit, isNull);
    final entered = OnSiteTransferCubit(initialDepositNumber: '10.10009753.8');
    await entered.fetchCatalog();
    expect(entered.state.deposit!.id, 'deposit-1');
    await entered.close();
  });
  test(
    'dates reject past, Friday and cutoff; a visit cannot follow the transfer',
    () async {
      await cubit.fetchCatalog();
      cubit.selectDeposit(cubit.state.catalog!.deposits.first);
      cubit.updateTransferDate(inputDate(DateTime.utc(2026, 10, 19)));
      expect(cubit.state.isTransferDateError, isTrue);
      cubit.updateTransferDate(inputDate(DateTime.utc(2026, 10, 23)));
      expect(cubit.state.canContinue, isFalse);
      cubit.updateTransferDate(inputDate(DateTime.utc(2026, 10, 21)));
      expect(cubit.state.canContinue, isTrue);
      await cubit.continueFlow();
      cubit.selectAddress(cubit.state.addresses.first);
      cubit.updateVisitDate(inputDate(DateTime.utc(2026, 10, 22)));
      expect(cubit.state.isVisitDateError, isTrue);
      expect(cubit.state.canContinue, isFalse);
      final afterCutoff = TransferCatalog(
        deposits: [],
        addresses: [],
        bankTime: DateTime.utc(2026, 10, 20, 10),
      );
      expect(
        TransferScheduleRules.isTransferDateValid(
          DateTime.utc(2026, 10, 20),
          afterCutoff,
        ),
        isFalse,
      );
      final holiday = TransferCatalog(
        deposits: [],
        addresses: [],
        bankTime: DateTime.utc(2026, 10, 20, 8),
        holidays: [DateTime.utc(2026, 10, 21)],
      );
      expect(
        TransferScheduleRules.isTransferDateValid(
          DateTime.utc(2026, 10, 21),
          holiday,
        ),
        isFalse,
      );
    },
  );
  test('manual form validates amount/IBAN, resets drafts and preserves multiple destinations', () async {
    await readyForDestinations();
    cubit.requestDestinationEditor();
    cubit.updateAmount('0');
    cubit.selectMethod(TransferMethod.satna);
    cubit.updateIban('123');
    cubit.selectPurpose(TransferPurpose.salary);
    expect(cubit.state.isAmountError, isTrue);
    expect(cubit.state.isIbanError, isTrue);
    expect(cubit.state.canAddDestination, isFalse);
    await addDestination();
    final first = cubit.state.destinations.single;
    await addDestination(amount: '1000000000');
    expect(cubit.state.destinations.length, 2);
    expect(cubit.state.destinations.first, first);
    cubit.requestDestinationEditor();
    expect(cubit.state.amountInput, isEmpty);
    expect(cubit.state.method, isNull);
    cubit.cancelDestinationEditor();
    cubit.removeDestination(first);
    expect(cubit.state.destinations.single.amountRial, 1000000000);
    cubit.removeDestination(cubit.state.destinations.single);
    expect(cubit.state.canContinue, isFalse);
  });
  test(
    'unchanged failed submission retries the same confirmed payload and key',
    () async {
      await readyForDestinations();
      await addDestination();
      await cubit.continueFlow();
      expect(cubit.state.canContinue, isFalse);
      cubit.updateTerms(true);
      repository.failNextSubmission = true;
      await cubit.submitTransfer();
      expect(cubit.state.submissionStatus, RequestStatus.failure);
      await cubit.submitTransfer();
      expect(repository.submissions[0], same(repository.submissions[1]));
      expect(cubit.state.receipt!.trackingId, startsWith('DEMO-'));
      expect(cubit.state.canContinue, isFalse);
      cubit.applyReceiptDismissal();
      expect(cubit.state.effect, OnSiteTransferEffect.home);
    },
  );
  test(
    'review retains identity for the same payload and changes it after an edit',
    () async {
      await readyForDestinations();
      await addDestination();
      await cubit.continueFlow();
      final original = cubit.state.confirmedRequest!;
      cubit.requestBack();
      await cubit.continueFlow();
      expect(cubit.state.confirmedRequest, original);
      expect(
        cubit.state.confirmedRequest!.idempotencyKey,
        original.idempotencyKey,
      );
      cubit.requestBack();
      await addDestination(amount: '1000000');
      await cubit.continueFlow();
      expect(
        cubit.state.confirmedRequest!.idempotencyKey,
        isNot(original.idempotencyKey),
      );
      expect(cubit.state.confirmedRequest!.destinations.length, 2);
    },
  );
  test('back preserves data and remains available during submission', () async {
    await readyForDestinations();
    await addDestination();
    await cubit.continueFlow();
    cubit.updateTerms(true);
    final pending = cubit.submitTransfer();
    cubit.requestBack();
    expect(cubit.state.step, OnSiteTransferStep.destinations);
    expect(cubit.state.destinations.length, 1);
    cubit.requestBack();
    expect(cubit.state.address, isNotNull);
    cubit.requestBack();
    cubit.requestBack();
    expect(cubit.state.effect, OnSiteTransferEffect.confirmExit);
    cubit.applyExitConfirmation(false);
    expect(cubit.state.effect, OnSiteTransferEffect.confirmExit);
    await pending;
  });
  test(
    'each picker attempt clears the previous error without upload loading',
    () async {
      final states = <OnSiteTransferState>[];
      final subscription = cubit.stream.listen(states.add);
      addTearDown(subscription.cancel);
      for (var attempt = 0; attempt < 2; attempt++) {
        cubit.requestFilePicker();
        expect(cubit.state.uploadStatus, RequestStatus.initial);
        expect(cubit.state.failure, isNull);
        expect(cubit.state.message, isNull);
        cubit.consumeOnSiteTransferInteraction();
        cubit.applyFilePickerFailure(cubit.state.filePickerRequestId);
        expect(cubit.state.uploadStatus, RequestStatus.failure);
        expect(cubit.state.message, isNotNull);
      }
      await Future<void>.delayed(Duration.zero);
      expect(
        states.where((state) => state.uploadStatus == RequestStatus.failure),
        hasLength(2),
      );
    },
  );
  test(
    'cancelling the picker retains a previously uploaded file for review',
    () async {
      await readyForDestinations();
      cubit.requestUploadSheet();
      cubit.requestFilePicker();
      await cubit.applyFileSelection(
        SelectedDocument(name: 'salary.xls', bytes: Uint8List(100)),
        requestId: cubit.state.filePickerRequestId,
      );
      final attachment = cubit.state.pendingAttachment;
      cubit.requestFilePicker();
      await cubit.applyFileSelection(
        null,
        requestId: cubit.state.filePickerRequestId,
      );
      expect(cubit.state.uploadStatus, RequestStatus.success);
      expect(cubit.state.pendingAttachment, attachment);
      expect(cubit.state.canReviewFile, isTrue);
      cubit.applyUploadSheetResult(true);
      expect(cubit.state.confirmedRequest!.attachment, attachment);
    },
  );
  test('file limits are enforced; cancelling and replacing an upload rejects old completion', () async {
    await readyForDestinations();
    cubit.requestUploadSheet();
    cubit.requestFilePicker();
    await cubit.applyFileSelection(
      SelectedDocument(name: 'bad.txt', bytes: Uint8List(2)),
      requestId: cubit.state.filePickerRequestId,
    );
    expect(cubit.state.uploadStatus, RequestStatus.failure);
    repository.pendingUpload = Completer();
    cubit.requestFilePicker();
    final old = cubit.applyFileSelection(
      SelectedDocument(name: 'first.xls', bytes: Uint8List(100)),
      requestId: cubit.state.filePickerRequestId,
    );
    expect(cubit.state.uploadProgress, .4);
    cubit.removeUpload();
    repository.pendingUpload!.complete(
      const Success(
        TransferAttachment(token: 'old', name: 'first.xls', sizeBytes: 100),
      ),
    );
    await old;
    expect(cubit.state.pendingAttachment, isNull);
    expect(cubit.state.uploadName, isEmpty);
  });
  test(
    'Review confirms a file and advances without fabricating destinations',
    () async {
      await readyForDestinations();
      cubit.requestUploadSheet();
      cubit.requestFilePicker();
      await cubit.applyFileSelection(
        SelectedDocument(name: 'salary.xls', bytes: Uint8List(100)),
        requestId: cubit.state.filePickerRequestId,
      );
      expect(cubit.state.canReviewFile, isTrue);
      cubit.applyUploadSheetResult(true);
      expect(cubit.state.step, OnSiteTransferStep.confirmation);
      expect(cubit.state.confirmedRequest!.attachment!.name, 'salary.xls');
      expect(cubit.state.confirmedRequest!.destinations, isEmpty);
      cubit.updateTerms(true);
      await cubit.submitTransfer();
      expect(cubit.state.submissionStatus, RequestStatus.success);
    },
  );
  test('cancelling replacement keeps the approved file; its delete action restores empty entry', () async {
    await readyForDestinations();
    cubit.requestUploadSheet();
    cubit.requestFilePicker();
    await cubit.applyFileSelection(
      SelectedDocument(name: 'salary.xls', bytes: Uint8List(100)),
      requestId: cubit.state.filePickerRequestId,
    );
    cubit.applyUploadSheetResult(true);
    final attachment = cubit.state.attachment;
    cubit.requestBack();
    cubit.requestUploadSheet();
    cubit.removeUpload();
    cubit.applyUploadSheetResult(false);
    expect(cubit.state.attachment, attachment);
    cubit.removeAttachment();
    expect(cubit.state.attachment, isNull);
    expect(cubit.state.canContinue, isFalse);
  });
  test('cancelled picker and editor do not publish stale selections', () async {
    await readyForDestinations();
    cubit.requestUploadSheet();
    cubit.requestFilePicker();
    final id = cubit.state.filePickerRequestId;
    cubit.applyUploadSheetResult(null);
    await cubit.applyFileSelection(
      SelectedDocument(name: 'late.xls', bytes: Uint8List(100)),
      requestId: id,
    );
    expect(cubit.state.pendingAttachment, isNull);
    repository.pendingDestination = Completer();
    cubit.requestDestinationEditor();
    cubit.updateAmount('1000');
    cubit.selectMethod(TransferMethod.satna);
    cubit.updateIban('820540102680020817909002');
    cubit.selectPurpose(TransferPurpose.salary);
    final pending = cubit.submitDestination();
    cubit.cancelDestinationEditor();
    repository.pendingDestination!.complete(
      const Success(
        TransferDestination(
          id: 'late',
          recipientName: 'demo',
          iban: 'IR820540102680020817909002',
          amountRial: 1000,
          purpose: TransferPurpose.salary,
          description: '',
        ),
      ),
    );
    await pending;
    expect(cubit.state.destinations, isEmpty);
  });
}
