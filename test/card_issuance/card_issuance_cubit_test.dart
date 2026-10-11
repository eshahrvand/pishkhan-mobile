import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/features/card_issuance/presentation/cubit/issuance_rules.dart';

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/features/card_issuance/domain/entities/issuance_data.dart';
import 'package:pishkhan_mobile/features/card_issuance/domain/repositories/card_issuance_repository.dart';
import 'package:pishkhan_mobile/features/card_issuance/data/mock/mock_card_issuance_repository.dart';
import 'package:pishkhan_mobile/features/card_issuance/presentation/cubit/card_issuance_cubit.dart';

class ControlledIssuanceRepository implements CardIssuanceRepository {
  Result<IssuanceCatalog> catalogResult = Success(
    MockCardIssuanceRepository.sampleCatalog,
  );
  Result<IssuanceReceipt> submitResult = const Success(
    IssuanceReceipt(reference: 'test', isMock: true),
  );
  Completer<Result<IssuanceCatalog>>? loading;
  Completer<Result<IssuanceReceipt>>? submitting;
  int calls = 0;
  IssuanceRequest? captured;
  @override
  Future<Result<IssuanceCatalog>> load() async =>
      loading == null ? catalogResult : loading!.future;
  @override
  Future<Result<IssuanceReceipt>> submit(IssuanceRequest request) async {
    calls++;
    captured = request;
    return submitting == null ? submitResult : submitting!.future;
  }
}

void main() {
  Future<CardIssuanceCubit> ready({CardIssuanceRepository? repository}) async {
    final cubit = CardIssuanceCubit(
      repository: repository ?? MockCardIssuanceRepository(),
    );
    addTearDown(cubit.close);
    await cubit.load();
    return cubit;
  }

  void select(CardIssuanceCubit cubit) {
    cubit.selectDeposit('deposit-1');
    cubit.selectType(IssuanceType.newNumber);
  }

  void confirm(CardIssuanceCubit cubit) {
    select(cubit);
    cubit.next();
    cubit.selectAddress('home');
    cubit.next();
    cubit.acceptTerms(true);
  }

  test(
    'both selections remain required with no physical card enabled',
    () async {
      final c = await ready();
      c.setNoPhysicalCard(true);
      c.next();
      expect(c.state.step, IssuanceStep.selection);
      expect(issuanceCanContinue(c.state), false);
      c.selectDeposit('deposit-1');
      expect(issuanceCanContinue(c.state), false);
      c.selectType(IssuanceType.newNumber);
      expect(issuanceCanContinue(c.state), true);
      c.next();
      expect(c.state.step, IssuanceStep.confirmation);
      expect(issuanceRequest(c.state)!.address, isNull);
      expect(issuanceTotalRial(c.state), 600000);
      expect(
        issuanceFees(c.state).any((f) => f.kind == IssuanceFeeKind.delivery),
        false,
      );
      c.back();
      expect(c.state.step, IssuanceStep.selection);
    },
  );
  test('physical path requires address and explicit terms; fee total follows items', () async {
    final c = await ready();
    select(c);
    c.next();
    expect(c.state.step, IssuanceStep.delivery);
    expect(issuanceCanContinue(c.state), false);
    c.selectAddress('home');
    c.next();
    expect(c.state.step, IssuanceStep.confirmation);
    expect(issuanceTotalRial(c.state), 1600000);
    expect(issuanceCanContinue(c.state), false);
    c.acceptTerms(true);
    expect(issuanceCanContinue(c.state), true);
    c.back();
    c.selectAddress('home');
    expect(c.state.draft.termsAccepted, false);
  });
  test(
    'recipient and agent requirements are conditional and normalize digits',
    () async {
      final c = await ready();
      select(c);
      c.next();
      c.selectAddress('home');
      c.setOtherRecipient(true);
      expect(issuanceCanContinue(c.state), false);
      c.setRecipient(
        const DeliveryPerson(
          name: 'گیرنده',
          nationalId: '۱۲۳۴۵۶۷۸۹۰',
          mobile: '۰۹۱۲۱۲۳۴۵۶۷',
        ),
      );
      expect(c.state.draft.recipient.nationalId, '1234567890');
      expect(issuanceCanContinue(c.state), true);
      c.setIncludeAgent(true);
      expect(issuanceCanContinue(c.state), false);
      c.setAgent(const BankAgent(name: 'کارشناس', code: '۱۲۳'));
      expect(issuanceCanContinue(c.state), true);
      c.next();
      expect(issuanceRequest(c.state)!.recipient, isNotNull);
      expect(issuanceRequest(c.state)!.agent!.code, '123');
    },
  );
  test('hidden physical data is excluded from nonphysical request', () async {
    final c = await ready();
    confirm(c);
    c.back();
    c.setOtherRecipient(true);
    c.setIncludeAgent(true);
    c.back();
    c.setNoPhysicalCard(true);
    c.next();
    expect(issuanceRequest(c.state)!.address, isNull);
    expect(issuanceRequest(c.state)!.recipient, isNull);
    expect(issuanceRequest(c.state)!.agent, isNull);
  });
  test('adding validates postal code, selects address, and deletion clears selection', () async {
    final c = await ready();
    expect(
      c.addAddress(title: 'خانه', detail: 'تهران', postalCode: '۱۲۳'),
      false,
    );
    expect(
      c.addAddress(
        title: 'خانه دوم',
        detail: 'تهران',
        postalCode: '۱۲۳۴۵۶۷۸۹۰',
      ),
      true,
    );
    final id = issuanceAddress(c.state)!.id;
    expect(issuanceAddress(c.state)!.postalCode, '1234567890');
    c.removeAddress(id);
    expect(issuanceAddress(c.state), isNull);
    expect(c.state.draft.addressId, isNull);
    expect(c.state.catalog!.addresses.length, 1);
  });
  test('unknown selections are ignored', () async {
    final c = await ready();
    c.selectDeposit('unknown');
    c.selectAddress('unknown');
    expect(issuanceDeposit(c.state), isNull);
    expect(issuanceAddress(c.state), isNull);
    expect(issuanceSelectionComplete(c.state), false);
  });
  test(
    'empty and failed catalogs are represented explicitly and can retry',
    () async {
      final repository = ControlledIssuanceRepository()
        ..catalogResult = const Err(DataFailure('offline'));
      final c = await ready(repository: repository);
      expect(c.state.status, RequestStatus.failure);
      repository.catalogResult = Success(
        IssuanceCatalog(
          deposits: [],
          addresses: [],
          fees: [],
          walletBalanceRial: 0,
        ),
      );
      await c.load();
      expect(c.state.status, RequestStatus.success);
      expect(c.state.catalog!.deposits, isEmpty);
      repository.catalogResult = Success(
        MockCardIssuanceRepository.sampleCatalog,
      );
      await c.load();
      expect(c.state.status, RequestStatus.success);
    },
  );
  test('wallet insufficiency prevents submission', () async {
    final base = MockCardIssuanceRepository.sampleCatalog;
    final c = await ready(
      repository: MockCardIssuanceRepository(
        catalog: IssuanceCatalog(
          deposits: base.deposits,
          addresses: base.addresses,
          fees: base.fees,
          walletBalanceRial: 1,
        ),
      ),
    );
    confirm(c);
    expect(issuanceCanContinue(c.state), false);
    await c.submit();
    expect(c.state.status, RequestStatus.success);
  });
  test('submission captures selection once, locks editing, and reports mock receipt', () async {
    final repository = ControlledIssuanceRepository()..submitting = Completer();
    final c = await ready(repository: repository);
    confirm(c);
    final pending = c.submit();
    await c.submit();
    c.selectDeposit('deposit-2');
    expect(repository.calls, 1);
    expect(c.state.submissionStatus, RequestStatus.loading);
    expect(issuanceDeposit(c.state)!.id, 'deposit-1');
    expect(repository.captured!.address!.id, 'home');
    repository.submitting!.complete(repository.submitResult);
    await pending;
    expect(c.state.submissionStatus, RequestStatus.success);
    expect(c.state.receipt!.isMock, true);
  });
  test('submission error preserves draft and allows retry', () async {
    final repository = ControlledIssuanceRepository()
      ..submitResult = const Err(DataFailure('rejected'));
    final c = await ready(repository: repository);
    confirm(c);
    await c.submit();
    expect(c.state.failure!.code, 'rejected');
    expect(issuanceCanContinue(c.state), true);
    repository.submitResult = const Success(
      IssuanceReceipt(reference: 'retry', isMock: true),
    );
    await c.submit();
    expect(c.state.receipt!.reference, 'retry');
    expect(c.state.failure, isNull);
  });
  test('repository replacement ignores stale loads', () async {
    final old = ControlledIssuanceRepository()..loading = Completer();
    final c = CardIssuanceCubit(repository: old);
    addTearDown(c.close);
    final loading = c.load();
    await c.changeRepository(MockCardIssuanceRepository());
    old.loading!.complete(const Err(DataFailure('stale')));
    await loading;
    expect(c.state.status, RequestStatus.success);
  });
  test('initial account matches normalized display number', () async {
    final c = CardIssuanceCubit(
      repository: MockCardIssuanceRepository(),
      initialDepositNumber: '10.1234567.1',
    );
    addTearDown(c.close);
    await c.load();
    expect(issuanceDeposit(c.state)!.id, 'deposit-1');
    expect(c.state.draft.type, isNull);
  });
}
