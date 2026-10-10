import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/validators/second_password_validator.dart';
import 'package:pishkhan_mobile/features/password_services/password_services.dart';
import 'package:pishkhan_mobile/features/password_services/presentation/cubit/second_password_cubit.dart';

class ControlledPasswordRepository implements PasswordServicesRepository {
  PasswordCatalog catalog = MockPasswordServicesRepository.sampleCatalog;
  Failure? loadFailure, statusFailure, submitFailure;
  PasswordRequestRecord current = const PasswordRequestRecord(
    status: PasswordRequestStatus.none,
  );
  Completer<Result<PasswordCatalog>>? loading;
  Completer<Result<PasswordRequestRecord>>? checking, submitting;
  final requests = <SetSecondPasswordRequest>[];
  @override
  Future<Result<PasswordCatalog>> load() async => loading != null
      ? loading!.future
      : loadFailure != null
      ? Err(loadFailure!)
      : Success(catalog);
  @override
  Future<Result<PasswordRequestRecord>> status(String id) async =>
      checking != null
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
        : const Success(
            PasswordRequestRecord(
              status: PasswordRequestStatus.pending,
              trackingCode: '98649466583',
              isMock: true,
            ),
          );
  }
}

void select(SecondPasswordCubit c) {
  c.selectKind(PasswordCardKind.resalat);
  c.selectCard('password-card-1');
  c.selectSecondPassword();
}

Future<void> readyToSubmit(SecondPasswordCubit c) async {
  select(c);
  await c.next();
  c.passwordChanged('829164');
  c.confirmationChanged('829164');
  c.acceptTerms(true);
  await c.next();
  c.serialChanged('3R12345678');
  await c.next();
  await c.next();
  c.confirmMockRecording();
}

void main() {
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
    final c = SecondPasswordCubit(repository: ControlledPasswordRepository());
    await c.load();
    c.selectSecondPassword();
    expect(c.state.canContinue, false);
    select(c);
    expect(c.state.canContinue, true);
    await c.next();
    c.passwordChanged('۸۲۹۱۶۴');
    c.confirmationChanged('٨٢٩١٦٤');
    expect(c.state.password, '829164');
    expect(c.state.canContinue, false);
    c.acceptTerms(true);
    expect(c.state.canContinue, true);
    c.confirmationChanged('829163');
    expect(c.state.terms, false);
    c.confirmationChanged('829164');
    c.acceptTerms(true);
    await c.next();
    expect(c.state.canContinue, false);
    c.serialChanged('۳r۱۲۳۴۵۶۷۸');
    expect(c.state.serial, '3R12345678');
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
      final c = SecondPasswordCubit(repository: r);
      await c.load();
      select(c);
      await c.next();
      expect(c.state.step, SecondPasswordStep.selection);
      expect(c.state.record!.status, status);
      c.dismissRecord();
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
    final c = SecondPasswordCubit(repository: r);
    await c.load();
    select(c);
    await c.next();
    expect(c.state.step, SecondPasswordStep.selection);
    expect(c.state.failure, isNotNull);
    await c.close();
    r.catalog = PasswordCatalog(
      cards: MockPasswordServicesRepository.sampleCatalog.cards,
      walletBalanceRial: 0,
    );
    final poor = SecondPasswordCubit(repository: r);
    await poor.load();
    select(poor);
    await poor.next();
    expect(poor.state.step, SecondPasswordStep.selection);
    expect(poor.state.failure, isNotNull);
    await poor.close();
  });
  test(
    'submission locks editing and duplicate sends; result clears credentials',
    () async {
      final r = ControlledPasswordRepository()..submitting = Completer();
      final c = SecondPasswordCubit(repository: r);
      await c.load();
      await readyToSubmit(c);
      final task = c.submit();
      c.passwordChanged('4567');
      c.back();
      await c.submit();
      expect(r.requests.length, 1);
      expect(c.state.password, '829164');
      expect(c.state.status, SecondPasswordStatus.submitting);
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
      expect(c.state.serial, '');
      expect(c.state.status, SecondPasswordStatus.submitted);
      await c.close();
    },
  );
  test('submission retry keeps the same key and entered data', () async {
    final r = ControlledPasswordRepository()
      ..submitFailure = const DataFailure('network');
    final c = SecondPasswordCubit(repository: r);
    await c.load();
    await readyToSubmit(c);
    await c.submit();
    expect(c.state.password, '829164');
    expect(c.state.status, SecondPasswordStatus.ready);
    r.submitFailure = null;
    await c.submit();
    expect(r.requests[0].idempotencyKey, r.requests[1].idempotencyKey);
    await c.close();
  });
  test(
    'latest load wins; disposal suppresses status and submit completions',
    () async {
      final r = ControlledPasswordRepository()..loading = Completer();
      final c = SecondPasswordCubit(repository: r);
      final old = c.load();
      final pending = r.loading!;
      r.loading = null;
      await c.load();
      pending.complete(const Err(DataFailure('old')));
      await old;
      expect(c.state.status, SecondPasswordStatus.ready);
      select(c);
      r.checking = Completer();
      final check = c.next();
      await c.close();
      r.checking!.complete(
        const Success(
          PasswordRequestRecord(status: PasswordRequestStatus.none),
        ),
      );
      await check;
      expect(c.isClosed, true);
    },
  );
  test('empty, duplicate IDs and failed reads are distinct', () async {
    final r = ControlledPasswordRepository()
      ..catalog = PasswordCatalog(cards: []);
    final c = SecondPasswordCubit(repository: r);
    await c.load();
    expect(c.state.status, SecondPasswordStatus.empty);
    r.catalog = PasswordCatalog(
      cards: [
        PasswordCard(id: 'x', number: '1'),
        PasswordCard(id: 'x', number: '2'),
      ],
    );
    await c.load();
    expect(c.state.status, SecondPasswordStatus.failed);
    r.catalog = MockPasswordServicesRepository.sampleCatalog;
    r.loadFailure = const DataFailure('network');
    await c.load();
    expect(c.state.failure!.code, 'network');
    r.loadFailure = null;
    await c.load();
    expect(c.state.status, SecondPasswordStatus.ready);
    await c.close();
  });
  test('changed request data gets a new retry identity', () async {
    final r = ControlledPasswordRepository()
      ..submitFailure = const DataFailure('network');
    final c = SecondPasswordCubit(repository: r);
    await c.load();
    await readyToSubmit(c);
    await c.submit();
    c.passwordChanged('927164');
    c.confirmationChanged('927164');
    c.acceptTerms(true);
    c.confirmMockRecording();
    await c.submit();
    expect(r.requests.length, 2);
    expect(r.requests[0].idempotencyKey, isNot(r.requests[1].idempotencyKey));
    await c.close();
  });
  test('disposing during submission ignores a late receipt', () async {
    final r = ControlledPasswordRepository()..submitting = Completer();
    final c = SecondPasswordCubit(repository: r);
    await c.load();
    await readyToSubmit(c);
    final task = c.submit();
    await c.close();
    r.submitting!.complete(
      const Success(
        PasswordRequestRecord(status: PasswordRequestStatus.pending),
      ),
    );
    await task;
    expect(c.state.status, SecondPasswordStatus.submitting);
    expect(c.isClosed, true);
  });
  test(
    'mock status persists across routes without retaining credentials',
    () async {
      final r = MockPasswordServicesRepository();
      final c = SecondPasswordCubit(repository: r);
      await c.load();
      await readyToSubmit(c);
      await c.submit();
      await c.close();
      final next = SecondPasswordCubit(repository: r);
      await next.load();
      select(next);
      await next.next();
      expect(next.state.record!.status, PasswordRequestStatus.pending);
      expect(next.state.password, '');
      await next.close();
    },
  );
}
