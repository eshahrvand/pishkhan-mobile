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
      expect(c.state.canContinue, false);
      c.selectDeposit('deposit-1');
      expect(c.state.canContinue, false);
      c.selectType(IssuanceType.newNumber);
      expect(c.state.canContinue, true);
      c.next();
      expect(c.state.step, IssuanceStep.confirmation);
      expect(c.state.request!.address, isNull);
      expect(c.state.totalRial, 600000);
      expect(
        c.state.fees.any((f) => f.kind == IssuanceFeeKind.delivery),
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
    expect(c.state.canContinue, false);
    c.selectAddress('home');
    c.next();
    expect(c.state.step, IssuanceStep.confirmation);
    expect(c.state.totalRial, 1600000);
    expect(c.state.canContinue, false);
    c.acceptTerms(true);
    expect(c.state.canContinue, true);
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
      expect(c.state.canContinue, false);
      c.setRecipient(
        const DeliveryPerson(
          name: 'گیرنده',
          nationalId: '۱۲۳۴۵۶۷۸۹۰',
          mobile: '۰۹۱۲۱۲۳۴۵۶۷',
        ),
      );
      expect(c.state.draft.recipient.nationalId, '1234567890');
      expect(c.state.canContinue, true);
      c.setIncludeAgent(true);
      expect(c.state.canContinue, false);
      c.setAgent(const BankAgent(name: 'کارشناس', code: '۱۲۳'));
      expect(c.state.canContinue, true);
      c.next();
      expect(c.state.request!.recipient, isNotNull);
      expect(c.state.request!.agent!.code, '123');
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
    expect(c.state.request!.address, isNull);
    expect(c.state.request!.recipient, isNull);
    expect(c.state.request!.agent, isNull);
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
    final id = c.state.address!.id;
    expect(c.state.address!.postalCode, '1234567890');
    c.removeAddress(id);
    expect(c.state.address, isNull);
    expect(c.state.draft.addressId, isNull);
    expect(c.state.catalog!.addresses.length, 1);
  });
  test('unknown selections are ignored', () async {
    final c = await ready();
    c.selectDeposit('unknown');
    c.selectAddress('unknown');
    expect(c.state.deposit, isNull);
    expect(c.state.address, isNull);
    expect(c.state.selectionComplete, false);
  });
  test(
    'empty and failed catalogs are represented explicitly and can retry',
    () async {
      final repository = ControlledIssuanceRepository()
        ..catalogResult = const Err(DataFailure('offline'));
      final c = await ready(repository: repository);
      expect(c.state.status, IssuanceStatus.error);
      repository.catalogResult = Success(
        IssuanceCatalog(
          deposits: [],
          addresses: [],
          fees: [],
          walletBalanceRial: 0,
        ),
      );
      await c.load();
      expect(c.state.status, IssuanceStatus.empty);
      repository.catalogResult = Success(
        MockCardIssuanceRepository.sampleCatalog,
      );
      await c.load();
      expect(c.state.status, IssuanceStatus.loaded);
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
    expect(c.state.canContinue, false);
    await c.submit();
    expect(c.state.status, IssuanceStatus.loaded);
  });
  test('submission captures selection once, locks editing, and reports mock receipt', () async {
    final repository = ControlledIssuanceRepository()..submitting = Completer();
    final c = await ready(repository: repository);
    confirm(c);
    final pending = c.submit();
    await c.submit();
    c.selectDeposit('deposit-2');
    expect(repository.calls, 1);
    expect(c.state.status, IssuanceStatus.submitting);
    expect(c.state.deposit!.id, 'deposit-1');
    expect(repository.captured!.address!.id, 'home');
    repository.submitting!.complete(repository.submitResult);
    await pending;
    expect(c.state.status, IssuanceStatus.submitted);
    expect(c.state.receipt!.isMock, true);
  });
  test('submission error preserves draft and allows retry', () async {
    final repository = ControlledIssuanceRepository()
      ..submitResult = const Err(DataFailure('rejected'));
    final c = await ready(repository: repository);
    confirm(c);
    await c.submit();
    expect(c.state.failure!.code, 'rejected');
    expect(c.state.canContinue, true);
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
    expect(c.state.status, IssuanceStatus.loaded);
  });
  test('initial account matches normalized display number', () async {
    final c = CardIssuanceCubit(
      repository: MockCardIssuanceRepository(),
      initialDepositNumber: '10.1234567.1',
    );
    addTearDown(c.close);
    await c.load();
    expect(c.state.deposit!.id, 'deposit-1');
    expect(c.state.draft.type, isNull);
  });
}
