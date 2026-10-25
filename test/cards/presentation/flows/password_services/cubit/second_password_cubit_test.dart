import '../../../../../support/registered_dependency.dart';

import 'package:pishkhan_mobile/core/enums/request_status.dart';

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/validators/second_password_validator.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/password_services.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/cubit/second_password_cubit.dart';

class ControlledPasswordRepository implements PasswordServicesRepository {
  PasswordCatalog catalog = MockPasswordServicesRepository.sampleCatalog;
  Failure? loadFailure, statusFailure, submitFailure;
  PasswordRequestRecord current = const PasswordRequestRecord(
    status: PasswordRequestStatus.none,
  );
  Completer<Result<PasswordCatalog>>? loading;
  Completer<Result<PasswordRequestRecord>>? checking, submitting;
  final requests = <SetSecondPasswordRequest>[];
  bool mockReceipt = true;
  @override
  Future<Result<PasswordCatalog>> load() async => loading != null
      ? loading!.future
      : loadFailure != null
      ? Err(loadFailure!)
      : Success(catalog);
  @override
  Future<Result<PasswordRequestRecord>> status(
    String id, {
    PasswordOperation operation = PasswordOperation.setSecondPassword,
  }) async => checking != null
      ? checking!.future
      : statusFailure != null
      ? Err(statusFailure!)
      : Success(current);
  @override
  Future<Result<PasswordRequestRecord>> submit(
    SetSecondPasswordRequest request,
  ) async {
    requests.add(request);
    return submitting != null
        ? submitting!.future
        : submitFailure != null
        ? Err(submitFailure!)
        : Success(
            PasswordRequestRecord(
              status: PasswordRequestStatus.pending,
              trackingCode: '98649466583',
              isMock: mockReceipt,
            ),
          );
  }
}

void select(SecondPasswordCubit c) {
  c.selectKind(PasswordCardKind.resalat);
  c.selectCard(
    c.state.cardsForSelectedKind.firstWhere(
      (card) => card.id == 'password-card-1',
    ),
  );
  c.selectPasswordType(PasswordType.second);
}

Future<void> readyToSubmit(SecondPasswordCubit c) async {
  select(c);
  await c.submitCurrentStep();
  c.updatePassword('829164');
  c.updateConfirmation('829164');
  c.updateTermsAcceptance(true);
  await c.submitCurrentStep();
  c.updateNationalCardSerial('3R12345678');
  await c.submitCurrentStep();
  await c.submitCurrentStep();
  c.confirmMockRecording();
}

void main() {
  test(
    'Freezed password state never prints credentials, including after copyWith',
    () {
      const state = SecondPasswordState.initial(
        password: '829164',
        currentPassword: '5638',
        confirmation: '829164',
        nationalCardSerial: '3R12345678',
      );
      for (final value in [state, state.copyWith(termsAccepted: true)]) {
        final printed = value.toString();
        for (final secret in ['829164', '5638', '3R12345678']) {
          expect(printed, isNot(contains(secret)));
        }
      }
    },
  );

  test(
    'recovery requires an operation and permits an already configured card',
    () async {
      for (final operation in [
        PasswordOperation.changePassword,
        PasswordOperation.forgotPassword,
      ]) {
        final r = ControlledPasswordRepository()
          ..catalog = PasswordCatalog(
            cards: [
              PasswordCard(
                id: 'password-card-1',
                number: '1',
                canSetSecondPassword: false,
              ),
            ],
          );
        final c =
            withRegisteredDependency<
              PasswordServicesRepository,
              SecondPasswordCubit
            >(r, () => SecondPasswordCubit(selectOperation: true));
        await c.fetchCatalog();
        select(c);
        expect(c.state.canContinue, false);
        c.selectOperationType(operation);
        expect(c.state.isSelectionComplete, true);
        await c.submitCurrentStep();
        expect(c.state.step, SecondPasswordStep.password);
        c.updatePassword('829164');
        c.updateConfirmation('829164');
        if (operation == PasswordOperation.changePassword) {
          c.updateCurrentPassword('1234');
        }
        c.updateTermsAcceptance(true);
        if (operation == PasswordOperation.forgotPassword) {
          await c.submitCurrentStep();
          c.updateNationalCardSerial('3R12345678');
          await c.submitCurrentStep();
          await c.submitCurrentStep();
          c.confirmMockRecording();
        }
        await c.submitCurrentStep();
        expect(r.requests.single.operation, operation);
        expect(c.state.submissionStatus, RequestStatus.success);
        await c.close();
      }
    },
  );
  test(
    'changing operation clears credentials, consent, KYC and retry identity',
    () async {
      final r = ControlledPasswordRepository()
        ..submitFailure = const DataFailure('retry');
      final c =
          withRegisteredDependency<
            PasswordServicesRepository,
            SecondPasswordCubit
          >(r, () => SecondPasswordCubit(selectOperation: true));
      await c.fetchCatalog();
      select(c);
      c.selectOperationType(PasswordOperation.forgotPassword);
      await c.submitCurrentStep();
      c.updatePassword('829164');
      c.updateConfirmation('829164');
      c.updateTermsAcceptance(true);
      await c.submitCurrentStep();
      c.updateNationalCardSerial('3R12345678');
      await c.submitCurrentStep();
      await c.submitCurrentStep();
      c.confirmMockRecording();
      await c.submitCurrentStep();
      final oldKey = r.requests.single.idempotencyKey;
      while (c.state.step != SecondPasswordStep.selection) {
        c.requestBack();
      }
      c.selectOperationType(PasswordOperation.changePassword);
      expect(c.state.password, isEmpty);
      expect(c.state.currentPassword, isEmpty);
      expect(c.state.nationalCardSerial, isEmpty);
      expect(c.state.termsAccepted, false);
      expect(c.state.isRecordingConfirmed, false);
      await c.submitCurrentStep();
      c.updateCurrentPassword('1234');
      c.updatePassword('829164');
      c.updateConfirmation('829164');
      c.updateTermsAcceptance(true);
      await c.submitCurrentStep();
      expect(r.requests.last.operation, PasswordOperation.changePassword);
      expect(r.requests.last.idempotencyKey, isNot(oldKey));
      c.requestBack();
      c.selectCard(
        c.state.cardsForSelectedKind.firstWhere(
          (card) => card.id == 'password-card-1',
        ),
      );
      expect(c.state.operation, isNull);
      await c.close();
    },
  );
  test('recovery eligibility and wallet gate new requests; existing receipt remains readable', () async {
    final r = ControlledPasswordRepository()
      ..catalog = PasswordCatalog(
        cards: [
          PasswordCard(
            id: 'password-card-1',
            number: '1',
            canResetSecondPassword: false,
          ),
        ],
        walletBalanceRial: 0,
      );
    final c =
        withRegisteredDependency<
          PasswordServicesRepository,
          SecondPasswordCubit
        >(r, () => SecondPasswordCubit(selectOperation: true));
    await c.fetchCatalog();
    select(c);
    c.selectOperationType(PasswordOperation.forgotPassword);
    await c.submitCurrentStep();
    expect(c.state.step, SecondPasswordStep.selection);
    expect(c.state.failure, isNotNull);
    r.current = const PasswordRequestRecord(
      status: PasswordRequestStatus.approved,
      trackingCode: '123',
    );
    await c.submitCurrentStep();
    expect(c.state.record!.status, PasswordRequestStatus.approved);
    await c.close();
  });
  test('mock recovery receipt survives reentry and remains distinct from setup and change', () async {
    final r = MockPasswordServicesRepository();
    final c =
        withRegisteredDependency<
          PasswordServicesRepository,
          SecondPasswordCubit
        >(r, () => SecondPasswordCubit(selectOperation: true));
    await c.fetchCatalog();
    select(c);
    c.selectOperationType(PasswordOperation.forgotPassword);
    await c.submitCurrentStep();
    c.updatePassword('829164');
    c.updateConfirmation('829164');
    c.updateTermsAcceptance(true);
    await c.submitCurrentStep();
    c.updateNationalCardSerial('3R12345678');
    await c.submitCurrentStep();
    await c.submitCurrentStep();
    c.confirmMockRecording();
    await c.submitCurrentStep();
    await c.close();
    for (final operation in PasswordOperation.values) {
      final result = await r.status('password-card-1', operation: operation);
      expect(
        (result as Success<PasswordRequestRecord>).data.status,
        operation == PasswordOperation.forgotPassword
            ? PasswordRequestStatus.pending
            : PasswordRequestStatus.none,
      );
    }
    final next =
        withRegisteredDependency<
          PasswordServicesRepository,
          SecondPasswordCubit
        >(r, () => SecondPasswordCubit(selectOperation: true));
    await next.fetchCatalog();
    select(next);
    next.selectOperationType(PasswordOperation.forgotPassword);
    await next.submitCurrentStep();
    expect(next.state.record!.status, PasswordRequestStatus.pending);
    await next.close();
  });
  test('change requires current PIN but applies new rules only to new PIN; submits from password', () async {
    final r = ControlledPasswordRepository()
      ..catalog = PasswordCatalog(
        cards: MockPasswordServicesRepository.sampleCatalog.cards,
        walletBalanceRial: 0,
      );
    final c =
        withRegisteredDependency<
          PasswordServicesRepository,
          SecondPasswordCubit
        >(r, () => SecondPasswordCubit(selectOperation: true));
    await c.fetchCatalog();
    select(c);
    c.selectOperationType(PasswordOperation.changePassword);
    await c.submitCurrentStep();
    expect(c.state.step, SecondPasswordStep.password);
    c.updatePassword('829164');
    c.updateConfirmation('829164');
    c.updateTermsAcceptance(true);
    expect(c.state.canContinue, false);
    c.updateCurrentPassword('۱۲۳۴');
    expect(c.state.currentPassword, '1234');
    expect(c.state.termsAccepted, false);
    c.updateTermsAcceptance(true);
    expect(c.state.canContinue, true);
    await c.submitCurrentStep();
    expect(r.requests.single.currentPassword, '1234');
    expect(r.requests.single.nationalCardSerial, isEmpty);
    expect(r.requests.single.kycReference, isEmpty);
    expect(c.state.submissionStatus, RequestStatus.success);
    expect(c.state.currentPassword, isEmpty);
    expect(c.state.password, isEmpty);
    expect(r.requests.single.toString(), isNot(contains('1234')));
    await c.close();
  });
  test('change retries with stable identity and publishes pending interaction state', () async {
    final r = ControlledPasswordRepository()
      ..submitFailure = const DataFailure('retry');
    final c =
        withRegisteredDependency<
          PasswordServicesRepository,
          SecondPasswordCubit
        >(r, () => SecondPasswordCubit(selectOperation: true));
    await c.fetchCatalog();
    select(c);
    c.selectOperationType(PasswordOperation.changePassword);
    await c.submitCurrentStep();
    c.updateCurrentPassword('1234');
    c.updatePassword('829164');
    c.updateConfirmation('829164');
    c.updateTermsAcceptance(true);
    await c.submitCurrentStep();
    final firstKey = r.requests.single.idempotencyKey;
    await c.submitCurrentStep();
    expect(r.requests.last.idempotencyKey, firstKey);
    c.updateCurrentPassword('4321');
    c.updateTermsAcceptance(true);
    r.submitFailure = null;
    r.submitting = Completer();
    final task = c.submitCurrentStep();
    expect(c.state.isEditable, isFalse);
    expect(c.state.canContinue, isFalse);
    expect(c.state.currentPassword, '4321');
    expect(c.state.operation, PasswordOperation.changePassword);
    expect(r.requests.length, 3);
    expect(r.requests.last.idempotencyKey, isNot(firstKey));
    r.submitting!.complete(
      const Success(
        PasswordRequestRecord(status: PasswordRequestStatus.pending),
      ),
    );
    await task;
    expect(c.state.currentPassword, isEmpty);
    await c.close();
  });
  test('PIN rules reject repeated patterns, sequences and known dates', () {
    for (final value in [
      '1234',
      '4321',
      '7890',
      '0987',
      '1111',
      '1212',
      '123123',
      '12a4',
      '123',
      '1234567',
    ]) {
      expect(SecondPasswordValidator.isValid(value, []), false, reason: value);
    }
    expect(SecondPasswordValidator.isValid('829164', []), true);
    expect(SecondPasswordValidator.isValid('829164', ['829164']), false);
    expect(SecondPasswordValidator.isValid('۹۸۷۶', []), false);
    expect(SecondPasswordValidator.validSerial('3R12345678'), true);
    for (final serial in ['12345678', 'RR1234', 'R12', '3R12!45678']) {
      expect(SecondPasswordValidator.validSerial(serial), false);
    }
  });
  test('selection, consent, confirmation, normalization and serial gate every step', () async {
    final c =
        withRegisteredDependency<
          PasswordServicesRepository,
          SecondPasswordCubit
        >(ControlledPasswordRepository(), () => SecondPasswordCubit());
    await c.fetchCatalog();
    c.selectPasswordType(PasswordType.second);
    expect(c.state.canContinue, false);
    select(c);
    expect(c.state.canContinue, true);
    await c.submitCurrentStep();
    c.updatePassword('۸۲۹۱۶۴');
    c.updateConfirmation('٨٢٩١٦٤');
    expect(c.state.password, '829164');
    expect(c.state.canContinue, false);
    c.updateTermsAcceptance(true);
    expect(c.state.canContinue, true);
    c.updateConfirmation('829163');
    expect(c.state.termsAccepted, false);
    c.updateConfirmation('829164');
    c.updateTermsAcceptance(true);
    await c.submitCurrentStep();
    expect(c.state.canContinue, false);
    c.updateNationalCardSerial('۳r۱۲۳۴۵۶۷۸');
    expect(c.state.nationalCardSerial, '3R12345678');
    expect(c.state.canContinue, true);
    await c.close();
  });
  test('pending and approved status stop before password entry', () async {
    for (final status in [
      PasswordRequestStatus.pending,
      PasswordRequestStatus.approved,
    ]) {
      final r = ControlledPasswordRepository()
        ..current = PasswordRequestRecord(status: status, trackingCode: '123');
      r.catalog = PasswordCatalog(
        cards: [
          PasswordCard(
            id: 'password-card-1',
            number: '1',
            canSetSecondPassword: false,
          ),
        ],
        walletBalanceRial: 0,
      );
      final c =
          withRegisteredDependency<
            PasswordServicesRepository,
            SecondPasswordCubit
          >(r, () => SecondPasswordCubit());
      await c.fetchCatalog();
      select(c);
      await c.submitCurrentStep();
      expect(c.state.step, SecondPasswordStep.selection);
      expect(c.state.record!.status, status);
      c.applyRecordDismissal();
      expect(c.state.record, isNull);
      await c.close();
    }
  });
  test('wallet shortage and ineligible card never start setting', () async {
    final r = ControlledPasswordRepository()
      ..catalog = PasswordCatalog(
        cards: [
          PasswordCard(
            id: 'password-card-1',
            number: '1',
            canSetSecondPassword: false,
          ),
        ],
      );
    final c =
        withRegisteredDependency<
          PasswordServicesRepository,
          SecondPasswordCubit
        >(r, () => SecondPasswordCubit());
    await c.fetchCatalog();
    select(c);
    await c.submitCurrentStep();
    expect(c.state.step, SecondPasswordStep.selection);
    expect(c.state.failure, isNotNull);
    await c.close();
    r.catalog = PasswordCatalog(
      cards: MockPasswordServicesRepository.sampleCatalog.cards,
      walletBalanceRial: 0,
    );
    final poor =
        withRegisteredDependency<
          PasswordServicesRepository,
          SecondPasswordCubit
        >(r, () => SecondPasswordCubit());
    await poor.fetchCatalog();
    select(poor);
    await poor.submitCurrentStep();
    expect(poor.state.step, SecondPasswordStep.selection);
    expect(poor.state.failure, isNotNull);
    await poor.close();
  });
  test('submission disables editing and result clears credentials', () async {
    final r = ControlledPasswordRepository()..submitting = Completer();
    final c =
        withRegisteredDependency<
          PasswordServicesRepository,
          SecondPasswordCubit
        >(r, () => SecondPasswordCubit());
    await c.fetchCatalog();
    await readyToSubmit(c);
    final task = c.submitCurrentStep();
    expect(c.state.isEditable, isFalse);
    expect(c.state.canContinue, isFalse);
    expect(r.requests.length, 1);
    expect(c.state.password, '829164');
    expect(c.state.submissionStatus, RequestStatus.loading);
    expect(r.requests.single.toString(), isNot(contains('829164')));
    r.submitting!.complete(
      const Success(
        PasswordRequestRecord(
          status: PasswordRequestStatus.pending,
          trackingCode: '98649466583',
          isMock: true,
        ),
      ),
    );
    await task;
    expect(c.state.password, '');
    expect(c.state.confirmation, '');
    expect(c.state.nationalCardSerial, '');
    expect(c.state.submissionStatus, RequestStatus.success);
    await c.close();
  });
  test('submission retry keeps the same key and entered data', () async {
    final r = ControlledPasswordRepository()
      ..submitFailure = const DataFailure('network');
    final c =
        withRegisteredDependency<
          PasswordServicesRepository,
          SecondPasswordCubit
        >(r, () => SecondPasswordCubit());
    await c.fetchCatalog();
    await readyToSubmit(c);
    await c.submitCurrentStep();
    expect(c.state.password, '829164');
    expect(c.state.catalogStatus, RequestStatus.success);
    expect(c.state.submissionStatus, RequestStatus.failure);
    r.submitFailure = null;
    await c.submitCurrentStep();
    expect(r.requests[0].idempotencyKey, r.requests[1].idempotencyKey);
    await c.close();
  });
  test(
    'existing-request failure preserves selection and retries independently',
    () async {
      final repository = ControlledPasswordRepository()
        ..statusFailure = const DataFailure('offline');
      final cubit =
          withRegisteredDependency<
            PasswordServicesRepository,
            SecondPasswordCubit
          >(
            repository,
            () => SecondPasswordCubit(initialCardNumber: '۵۰۴۱ ۷۲۱۴ ۵۶۷۸ ۳۴۰۷'),
          );
      addTearDown(cubit.close);
      await cubit.fetchCatalog();
      expect(cubit.state.card?.id, 'password-card-1');
      cubit.selectPasswordType(PasswordType.second);
      await cubit.submitCurrentStep();
      expect(cubit.state.catalogStatus, RequestStatus.success);
      expect(cubit.state.failure?.code, 'offline');
      expect(cubit.state.submissionStatus, RequestStatus.initial);
      expect(cubit.state.canContinue, isTrue);
      repository.statusFailure = null;
      await cubit.submitCurrentStep();
      expect(cubit.state.step, SecondPasswordStep.password);
      expect(cubit.state.failure, isNull);
    },
  );

  test('confirmation errors and visibility reset on reentry while values survive Back', () async {
    final cubit =
        withRegisteredDependency<
          PasswordServicesRepository,
          SecondPasswordCubit
        >(ControlledPasswordRepository(), () => SecondPasswordCubit());
    addTearDown(cubit.close);
    await cubit.fetchCatalog();
    select(cubit);
    await cubit.submitCurrentStep();
    cubit.updatePassword('829164');
    cubit.updateConfirmation('829163');
    cubit.validateConfirmation();
    expect(cubit.state.isConfirmationError, isTrue);
    cubit.updateConfirmation('829164');
    expect(cubit.state.isConfirmationError, isFalse);
    cubit.updateTermsAcceptance(true);
    cubit.togglePasswordVisibility();
    await cubit.submitCurrentStep();
    cubit.requestBack();
    expect(cubit.state.password, '829164');
    expect(cubit.state.isPasswordVisible, isFalse);
    expect(cubit.state.canContinue, isTrue);
    cubit.requestBack();
    cubit.requestBack();
    expect(cubit.state.effect, isA<PasswordExitConfirmationRequested>());
    cubit.applyExitConfirmation(null);
    expect(cubit.state.effect, isNull);
    expect(cubit.state.card?.id, 'password-card-1');
    expect(cubit.state.password, '829164');
  });

  test('empty, duplicate IDs and failed reads are distinct', () async {
    final r = ControlledPasswordRepository()
      ..catalog = PasswordCatalog(cards: []);
    final c =
        withRegisteredDependency<
          PasswordServicesRepository,
          SecondPasswordCubit
        >(r, () => SecondPasswordCubit());
    await c.fetchCatalog();
    expect(c.state.catalogStatus, RequestStatus.success);
    expect(c.state.catalog!.cards, isEmpty);
    r.catalog = PasswordCatalog(
      cards: [
        PasswordCard(id: 'x', number: '1'),
        PasswordCard(id: 'x', number: '2'),
      ],
    );
    await c.fetchCatalog();
    expect(c.state.catalogStatus, RequestStatus.failure);
    r.catalog = MockPasswordServicesRepository.sampleCatalog;
    r.loadFailure = const DataFailure('network');
    await c.fetchCatalog();
    expect(c.state.failure!.code, 'network');
    r.loadFailure = null;
    await c.fetchCatalog();
    expect(c.state.catalogStatus, RequestStatus.success);
    await c.close();
  });
  test('changed request data gets a new retry identity', () async {
    final r = ControlledPasswordRepository()
      ..submitFailure = const DataFailure('network');
    final c =
        withRegisteredDependency<
          PasswordServicesRepository,
          SecondPasswordCubit
        >(r, () => SecondPasswordCubit());
    await c.fetchCatalog();
    await readyToSubmit(c);
    await c.submitCurrentStep();
    c.requestBack();
    c.requestBack();
    c.requestBack();
    c.updatePassword('927164');
    c.updateConfirmation('927164');
    c.updateTermsAcceptance(true);
    await c.submitCurrentStep();
    await c.submitCurrentStep();
    await c.submitCurrentStep();
    c.confirmMockRecording();
    await c.submitCurrentStep();
    expect(r.requests.length, 2);
    expect(r.requests[0].idempotencyKey, isNot(r.requests[1].idempotencyKey));
    await c.close();
  });
  test(
    'mock status persists across routes without retaining credentials',
    () async {
      final r = MockPasswordServicesRepository();
      final c =
          withRegisteredDependency<
            PasswordServicesRepository,
            SecondPasswordCubit
          >(r, () => SecondPasswordCubit());
      await c.fetchCatalog();
      await readyToSubmit(c);
      await c.submitCurrentStep();
      await c.close();
      final next =
          withRegisteredDependency<
            PasswordServicesRepository,
            SecondPasswordCubit
          >(r, () => SecondPasswordCubit());
      await next.fetchCatalog();
      select(next);
      await next.submitCurrentStep();
      expect(next.state.record!.status, PasswordRequestStatus.pending);
      expect(next.state.password, '');
      await next.close();
    },
  );
}
