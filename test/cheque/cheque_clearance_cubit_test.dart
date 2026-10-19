import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:pishkhan_mobile/core/router/validated_return_location.dart';
import 'package:pishkhan_mobile/core/validators/cheque_request_validator.dart';
import 'package:pishkhan_mobile/features/cheque/data/repositories/mock_cheque_clearance_repository.dart';
import 'package:pishkhan_mobile/features/cheque/domain/entities/cheque_clearance.dart';
import 'package:pishkhan_mobile/features/cheque/domain/repositories/cheque_clearance_repository.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/clearance/cubit/cheque_clearance_cubit.dart';

class ControlledChequeRepository implements ChequeClearanceRepository {
  final delegate = MockChequeClearanceRepository();
  final postalRequests = <Completer<Result<List<PostalOffice>>>>[];
  final submissions = <ChequeClearanceRequest>[];
  Result<ChequeClearanceReceipt>? submissionResult;
  bool failCatalog = false;

  @override
  Future<Result<ChequeClearanceCatalog>> fetchCatalog() => failCatalog
      ? Future.value(const Err(DataFailure('offline')))
      : delegate.fetchCatalog();

  @override
  Future<Result<List<PostalOffice>>> fetchPostalOffices(String cityId) {
    final completer = Completer<Result<List<PostalOffice>>>();
    postalRequests.add(completer);
    return completer.future;
  }

  @override
  Future<Result<ChequeClearanceReceipt>> submitClearance(
    ChequeClearanceRequest request,
  ) {
    submissions.add(request);
    return submissionResult == null
        ? delegate.submitClearance(request)
        : Future.value(submissionResult);
  }
}

void main() {
  late ControlledChequeRepository repository;
  late ChequeClearanceCubit cubit;
  setUp(() {
    repository = ControlledChequeRepository();
    getIt.registerSingleton<ChequeClearanceRepository>(repository);
    cubit = ChequeClearanceCubit();
  });
  tearDown(() async {
    await cubit.close();
    await getIt.reset();
  });

  Future<void> fill(
    ChequeClearanceReason reason, {
    String number = '123/123456',
  }) async {
    await cubit.fetchCatalog();
    cubit.selectDeposit(cubit.state.catalog!.deposits.first);
    cubit.updateChequeNumber(number);
    cubit.selectReason(reason);
  }

  test('constructor preserves state; fetch failure can be retried', () async {
    expect(cubit.state, const ChequeClearanceState.initial());
    repository.failCatalog = true;
    await cubit.fetchCatalog();
    expect(cubit.state.catalogStatus, RequestStatus.failure);
    expect(cubit.state.isEditable, isFalse);
    repository.failCatalog = false;
    await cubit.fetchCatalog();
    expect(cubit.state.catalogStatus, RequestStatus.success);
    expect(cubit.state.catalogFailure, isNull);
    expect(cubit.state.isEditable, isTrue);
  });

  for (final reason in ChequeClearanceReason.values) {
    test(
      '$reason prepares its documents and accepts only complete requests',
      () async {
        await fill(reason);
        final judicial = reason == ChequeClearanceReason.judicialLetter;
        expect(cubit.state.isJudicialLetterRequired, judicial);
        expect(
          cubit.state.isConsentRequired,
          reason == ChequeClearanceReason.notarizedConsent,
        );
        expect(
          cubit.state.requiredDocument == null,
          reason == ChequeClearanceReason.depositAndBlock ||
              reason == ChequeClearanceReason.olderThanThreeYears,
        );
        cubit.updateTermsAcceptance(true);
        expect(cubit.state.canSubmit, !judicial);
        if (judicial) {
          cubit.updateJudicialLetterNumber('abc');
          expect(cubit.state.isJudicialLetterNumberError, isTrue);
          expect(cubit.state.canSubmit, isFalse);
          cubit.updateJudicialLetterNumber('100345678');
          expect(cubit.state.isJudicialLetterNumberError, isFalse);
          expect(cubit.state.canSubmit, isTrue);
        }
        final future = cubit.submitClearance();
        expect(cubit.state.submissionStatus, RequestStatus.loading);
        expect(cubit.state.isEditable, isFalse);
        await future;
        expect(cubit.state.submissionStatus, RequestStatus.success);
        expect(cubit.state.receipt!.isMock, isTrue);
        expect(cubit.state.canSubmit, isFalse);
        expect(
          repository.submissions.single.judicialLetterNumber,
          judicial ? '100345678' : null,
        );
      },
    );
  }

  test(
    'unknown cheque is a field error only after submission; editing recovers',
    () async {
      await fill(ChequeClearanceReason.depositAndBlock, number: '999/999999');
      expect(cubit.state.chequeNumberError, isNull);
      cubit.updateTermsAcceptance(true);
      await cubit.submitClearance();
      expect(cubit.state.chequeNumberError, ChequeNumberError.notFound);
      expect(cubit.state.submissionFailure, isNull);
      expect(cubit.state.isEditable, isTrue);
      cubit.updateTermsAcceptance(false);
      cubit.updateTermsAcceptance(true);
      expect(cubit.state.canSubmit, isFalse);
      cubit.updateChequeNumber('123/123456');
      expect(cubit.state.chequeNumberError, isNull);
      expect(cubit.state.canSubmit, isTrue);
      await cubit.submitClearance();
      expect(cubit.state.submissionStatus, RequestStatus.success);
    },
  );

  test(
    'deposit and reason changes discard dependent values and consent',
    () async {
      await fill(ChequeClearanceReason.judicialLetter);
      cubit.updateJudicialLetterNumber('100');
      cubit.updateTermsAcceptance(true);
      final key = cubit.state.idempotencyKey;
      cubit.selectReason(ChequeClearanceReason.originalCheque);
      expect(
        cubit.state.requiredDocument,
        ChequeClearanceDocument.originalCheque,
      );
      expect(cubit.state.judicialLetterNumber, isEmpty);
      expect(cubit.state.isJudicialLetterRequired, isFalse);
      expect(cubit.state.termsAccepted, isFalse);
      expect(cubit.state.idempotencyKey, isNot(key));
      cubit.selectDeposit(cubit.state.catalog!.deposits.last);
      expect(cubit.state.chequeNumber, isEmpty);
      expect(cubit.state.isChequeNumberValid, isFalse);
      expect(cubit.state.canSubmit, isFalse);
    },
  );

  test(
    'transient submission failure preserves the request key for retry',
    () async {
      await fill(ChequeClearanceReason.olderThanThreeYears);
      cubit.updateTermsAcceptance(true);
      repository.submissionResult = const Err(DataFailure('offline'));
      final key = cubit.state.idempotencyKey;
      await cubit.submitClearance();
      expect(cubit.state.submissionStatus, RequestStatus.failure);
      expect(cubit.state.isEditable, isTrue);
      expect(cubit.state.canSubmit, isTrue);
      repository.submissionResult = null;
      await cubit.submitClearance();
      expect(repository.submissions.map((request) => request.idempotencyKey), [
        key,
        key,
      ]);
      expect(cubit.state.submissionStatus, RequestStatus.success);
    },
  );

  test('postal search resets dependent city and ignores a dismissed sheet response after reopening', () async {
    await fill(ChequeClearanceReason.notarizedConsent);
    cubit.requestPostalOffices();
    cubit.selectProvince(cubit.state.catalog!.provinces.first);
    cubit.selectCity(cubit.state.cities.first);
    final old = cubit.searchPostalOffices();
    cubit.requestPostalOffices();
    cubit.selectProvince(cubit.state.catalog!.provinces.last);
    expect(cubit.state.city, isNull);
    expect(cubit.state.canSearchPostalOffices, isFalse);
    cubit.selectCity(cubit.state.cities.single);
    final fresh = cubit.searchPostalOffices();
    repository.postalRequests.last.complete(const Success([]));
    await fresh;
    repository.postalRequests.first.complete(
      const Success([PostalOffice(id: 'old', address: 'old office')]),
    );
    await old;
    expect(cubit.state.postalOffices, isEmpty);
    expect(cubit.state.postalStep, ChequePostalStep.results);
    expect(cubit.state.city!.id, 'isfahan-city');
  });

  test(
    'postal failure retries; sharing uses the actual retrieved offices',
    () async {
      await fill(ChequeClearanceReason.originalCheque);
      cubit.requestPostalOffices();
      cubit.selectProvince(cubit.state.catalog!.provinces.first);
      cubit.selectCity(cubit.state.cities.first);
      var lookup = cubit.searchPostalOffices();
      repository.postalRequests.last.complete(
        const Err(DataFailure('offline')),
      );
      await lookup;
      expect(cubit.state.postalOfficesStatus, RequestStatus.failure);
      expect(cubit.state.postalStep, ChequePostalStep.location);
      lookup = cubit.searchPostalOffices();
      repository.postalRequests.last.complete(
        const Success([
          PostalOffice(id: 'office', address: 'address from service'),
        ]),
      );
      await lookup;
      cubit.requestPostalShare();
      expect(cubit.state.effect, ChequeClearanceEffect.sharePostalOffices);
      expect(cubit.state.postalShareText, contains('address from service'));
      expect(cubit.state.postalShareText, contains(cubit.state.city!.name));
      cubit.requestPostalSearch();
      expect(cubit.state.postalStep, ChequePostalStep.location);
    },
  );

  test('dirty back and assistant exits wait for actual confirmation', () async {
    cubit.requestBack();
    expect(cubit.state.effect, ChequeClearanceEffect.back);
    await fill(ChequeClearanceReason.originalCheque);
    cubit.requestBack();
    expect(cubit.state.effect, ChequeClearanceEffect.confirmExit);
    cubit.applyExitConfirmation(null);
    expect(cubit.state.effect, isNull);
    cubit.requestAssistant();
    cubit.applyExitConfirmation(true);
    expect(cubit.state.effect, ChequeClearanceEffect.assistant);
  });

  test('mock idempotency prevents duplicate execution and cross-deposit cheque access', () async {
    final request = ChequeClearanceRequest(
      depositId: 'cheque-deposit-2',
      chequeNumber: '123/123456',
      reason: ChequeClearanceReason.depositAndBlock,
      idempotencyKey: 'same',
    );
    final first = await repository.delegate.submitClearance(
      request,
    ) as Success<ChequeClearanceReceipt>;
    final replay = await repository.delegate.submitClearance(
      request,
    ) as Success<ChequeClearanceReceipt>;
    expect(replay.data, first.data);
    final conflict = await repository.delegate.submitClearance(
      const ChequeClearanceRequest(
        depositId: 'cheque-deposit-1',
        chequeNumber: '123/123457',
        reason: ChequeClearanceReason.depositAndBlock,
        idempotencyKey: 'same',
      ),
    );
    expect((conflict as Err).failure.code, 'cheque.idempotency-conflict');
    final wrongDeposit = await repository.delegate.submitClearance(
      const ChequeClearanceRequest(
        depositId: 'cheque-deposit-1',
        chequeNumber: '123/123456',
        reason: ChequeClearanceReason.originalCheque,
        idempotencyKey: 'other',
      ),
    );
    expect((wrongDeposit as Err).failure.code, 'cheque.not-found');
  });

  test(
    'numeric input syntax and the post-login route allow only intended values',
    () {
      expect(ChequeRequestValidator.isChequeNumberValid('123/123456'), isTrue);
      expect(ChequeRequestValidator.isChequeNumberValid('123456'), isTrue);
      expect(ChequeRequestValidator.isChequeNumberValid('12//3'), isFalse);
      expect(ChequeRequestValidator.isChequeNumberValid('abc'), isFalse);
      expect(
        validatedReturnLocation(AppRoutes.chequeClearance),
        AppRoutes.chequeClearance,
      );
      expect(
        validatedReturnLocation(
          '${AppRoutes.chequeClearance}?redirect=https://example.com',
        ),
        AppRoutes.home,
      );
    },
  );
}
