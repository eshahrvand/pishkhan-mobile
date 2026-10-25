import '../../../../../support/registered_dependency.dart';

import 'package:pishkhan_mobile/core/enums/request_status.dart';

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/features/cards/domain/entities/issuance_data.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/card_issuance_repository.dart';
import 'package:pishkhan_mobile/features/cards/data/repositories/mock_card_issuance_repository.dart';
import 'package:pishkhan_mobile/features/cards/presentation/card_issuance/cubit/card_issuance_cubit.dart';

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
  bool throwOnLoad = false;
  bool throwOnSubmit = false;
  IssuanceRequest? captured;
  @override
  Future<Result<IssuanceCatalog>> load() async {
    if (throwOnLoad) throw StateError('catalog transport failure');
    return loading == null ? catalogResult : loading!.future;
  }

  @override
  Future<Result<IssuanceReceipt>> submit(IssuanceRequest request) async {
    calls++;
    captured = request;
    if (throwOnSubmit) throw StateError('submission transport failure');
    return submitting == null ? submitResult : submitting!.future;
  }
}

void main() {
  Future<CardIssuanceCubit> ready({CardIssuanceRepository? repository}) async {
    final cubit =
        withRegisteredDependency<CardIssuanceRepository, CardIssuanceCubit>(
          repository ?? MockCardIssuanceRepository(),
          () => CardIssuanceCubit(),
        );
    addTearDown(cubit.close);
    await cubit.fetchIssuanceCatalog();
    return cubit;
  }

  void select(CardIssuanceCubit cubit) {
    cubit.selectDeposit(cubit.state.catalog!.deposits.first);
    cubit.selectIssuanceType(IssuanceType.newNumber);
  }

  void confirm(CardIssuanceCubit cubit) {
    select(cubit);
    cubit.selectNextStep();
    cubit.selectAddress(cubit.state.catalog!.addresses.first);
    cubit.selectNextStep();
    cubit.updateTermsAcceptance(true);
  }

  test(
    'both selections remain required with no physical card enabled',
    () async {
      final c = await ready();
      c.updatePhysicalCardOmission(true);
      expect(c.state.step, IssuanceStep.selection);
      expect(c.state.canContinue, false);
      c.selectDeposit(c.state.catalog!.deposits.first);
      expect(c.state.canContinue, false);
      c.selectIssuanceType(IssuanceType.newNumber);
      expect(c.state.canContinue, true);
      c.selectNextStep();
      expect(c.state.step, IssuanceStep.confirmation);
      expect(c.state.totalRial, 600000);
      expect(
        c.state.fees.any((f) => f.kind == IssuanceFeeKind.delivery),
        false,
      );
      c.requestBack();
      expect(c.state.step, IssuanceStep.selection);
      c.selectNextStep();
      c.updateTermsAcceptance(true);
      await c.submitCardIssuance();
      expect(c.state.confirmedRequest!.address, isNull);
    },
  );
  test('physical path requires address and explicit terms; fee total follows items', () async {
    final c = await ready();
    select(c);
    c.selectNextStep();
    expect(c.state.step, IssuanceStep.delivery);
    expect(c.state.canContinue, false);
    c.selectAddress(c.state.catalog!.addresses.first);
    c.selectNextStep();
    expect(c.state.step, IssuanceStep.confirmation);
    expect(c.state.totalRial, 1600000);
    expect(c.state.canContinue, false);
    c.updateTermsAcceptance(true);
    expect(c.state.canContinue, true);
    c.requestBack();
    c.selectAddress(c.state.catalog!.addresses.first);
    expect(c.state.draft.termsAccepted, false);
  });
  test('recipient and agent requirements use stored field validity', () async {
    final c = await ready();
    select(c);
    c.selectNextStep();
    c.selectAddress(c.state.catalog!.addresses.first);
    c.updateOtherRecipient(true);
    expect(c.state.canContinue, false);
    c.updateRecipientName('گیرنده');
    c.updateRecipientNationalId('1234567891');
    c.updateRecipientMobile('09121234567');
    expect(c.state.draft.recipient.nationalId, '1234567891');
    expect(c.state.canContinue, true);
    c.updateAgentInclusion(true);
    expect(c.state.canContinue, false);
    c.updateAgentName('کارشناس');
    c.updateAgentCode('123');
    expect(c.state.canContinue, true);
    c.selectNextStep();
    c.updateTermsAcceptance(true);
    await c.submitCardIssuance();
    expect(c.state.confirmedRequest!.recipient, isNotNull);
    expect(c.state.draft.agent.code, '123');
  });
  test('hidden physical data is excluded from nonphysical request', () async {
    final c = await ready();
    confirm(c);
    c.requestBack();
    c.updateOtherRecipient(true);
    c.updateAgentInclusion(true);
    c.requestBack();
    c.updatePhysicalCardOmission(true);
    c.selectNextStep();
    c.updateTermsAcceptance(true);
    await c.submitCardIssuance();
    expect(c.state.confirmedRequest!.address, isNull);
    expect(c.state.confirmedRequest!.recipient, isNull);
    expect(c.state.confirmedRequest!.agent, isNull);
  });
  test(
    'address fields validate once and saving selects the new address',
    () async {
      final c = await ready();
      c.requestAddAddress();
      c.updateAddressTitle('خانه');
      c.updateAddressDetail('تهران');
      c.updateAddressPostalCode('123');
      c.submitAddress();
      expect(c.state.isAddressFormError, isTrue);
      expect(c.state.draft.address, isNull);
      c.updateAddressTitle('خانه دوم');
      c.updateAddressPostalCode(' 1234567890 ');
      c.submitAddress();
      expect(c.state.isAddressFormError, isFalse);
      final id = c.state.draft.address!.id;
      expect(c.state.draft.address!.postalCode, '1234567890');
      c.removeAddress(id);
      expect(c.state.draft.address, isNull);
      expect(c.state.catalog!.addresses.length, 1);
    },
  );
  test(
    'empty and failed catalogs are represented explicitly and can retry',
    () async {
      final repository = ControlledIssuanceRepository()
        ..catalogResult = const Err(DataFailure('offline'));
      final c = await ready(repository: repository);
      expect(c.state.catalogStatus, RequestStatus.failure);
      repository.catalogResult = Success(
        IssuanceCatalog(
          deposits: [],
          addresses: [],
          fees: [],
          walletBalanceRial: 0,
        ),
      );
      await c.fetchIssuanceCatalog();
      expect(c.state.catalogStatus, RequestStatus.success);
      expect(c.state.catalog!.deposits, isEmpty);
      repository.catalogResult = Success(
        MockCardIssuanceRepository.sampleCatalog,
      );
      await c.fetchIssuanceCatalog();
      expect(c.state.catalogStatus, RequestStatus.success);
    },
  );
  test('wallet insufficiency disables the submission action', () async {
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
    expect(c.state.catalogStatus, RequestStatus.success);
  });
  test('submission publishes the loading state used to disable UI and reports receipt', () async {
    final repository = ControlledIssuanceRepository()..submitting = Completer();
    final c = await ready(repository: repository);
    confirm(c);
    final pending = c.submitCardIssuance();
    expect(c.state.canContinue, isFalse);
    expect(c.state.isEditable, isFalse);
    expect(repository.calls, 1);
    expect(c.state.submissionStatus, RequestStatus.loading);
    expect(c.state.draft.deposit!.id, 'deposit-1');
    expect(repository.captured!.address!.id, 'home');
    repository.submitting!.complete(repository.submitResult);
    await pending;
    expect(c.state.submissionStatus, RequestStatus.success);
    expect(c.state.receipt!.isMock, true);
    c.requestBack();
    expect(c.state.navigation, FlowNavigation.back);
  });
  test('submission error preserves draft and allows retry', () async {
    final repository = ControlledIssuanceRepository()
      ..submitResult = const Err(DataFailure('rejected'));
    final c = await ready(repository: repository);
    confirm(c);
    await c.submitCardIssuance();
    final confirmedRequest = repository.captured;
    expect(c.state.failure!.code, 'rejected');
    expect(c.state.canContinue, true);
    repository.submitResult = const Success(
      IssuanceReceipt(reference: 'retry', isMock: true),
    );
    await c.submitCardIssuance();
    expect(identical(repository.captured, confirmedRequest), isTrue);
    expect(c.state.receipt!.reference, 'retry');
    expect(c.state.failure, isNull);
  });
  test('editing a failed request invalidates its confirmed snapshot', () async {
    final repository = ControlledIssuanceRepository()
      ..submitResult = const Err(DataFailure('rejected'));
    final c = await ready(repository: repository);
    confirm(c);
    await c.submitCardIssuance();
    final previousRequest = c.state.confirmedRequest!;
    c.requestBack();
    c.requestBack();
    c.updatePhysicalCardOmission(true);
    expect(c.state.confirmedRequest, isNull);
    c.selectNextStep();
    c.updateTermsAcceptance(true);
    repository.submitResult = const Success(
      IssuanceReceipt(reference: 'changed', isMock: true),
    );
    await c.submitCardIssuance();
    expect(repository.captured, isNot(same(previousRequest)));
    expect(repository.captured!.noPhysicalCard, isTrue);
    expect(repository.captured!.address, isNull);
    c.requestHome();
    expect(c.state.navigation, FlowNavigation.home);
  });

  test(
    'unexpected catalog and submission exceptions become retryable failures',
    () async {
      final repository = ControlledIssuanceRepository()..throwOnLoad = true;
      final c = await ready(repository: repository);
      expect(c.state.catalogStatus, RequestStatus.failure);
      expect(c.state.failure, const UnexpectedFailure());

      repository.throwOnLoad = false;
      await c.fetchIssuanceCatalog();
      confirm(c);
      repository.throwOnSubmit = true;
      await c.submitCardIssuance();
      expect(c.state.submissionStatus, RequestStatus.failure);
      expect(c.state.failure, const UnexpectedFailure());
      expect(c.state.isEditable, isTrue);
      expect(c.state.canContinue, isTrue);

      repository.throwOnSubmit = false;
      await c.submitCardIssuance();
      expect(c.state.submissionStatus, RequestStatus.success);
      expect(c.state.failure, isNull);
    },
  );
  test('each recipient and agent edit publishes fresh eligibility', () async {
    final c = await ready();
    confirm(c);
    c.updateOtherRecipient(true);
    expect(c.state.draft.termsAccepted, isFalse);
    expect(c.state.isDeliveryComplete, isFalse);
    expect(c.state.confirmedRequest, isNull);
    c.updateRecipientName('گیرنده');
    c.updateRecipientNationalId('1234567891');
    c.updateRecipientMobile('09121234567');
    expect(c.state.isDeliveryComplete, isTrue);
    expect(c.state.isRecipientValid, isTrue);
    c.updateTermsAcceptance(true);
    expect(c.state.canContinue, isTrue);

    c.updateAgentInclusion(true);
    expect(c.state.canContinue, isFalse);
    expect(c.state.confirmedRequest, isNull);
    c.updateAgentName('کارشناس');
    c.updateAgentCode('123');
    expect(c.state.draft.agent.code, '123');
    c.updateTermsAcceptance(true);
    expect(c.state.canContinue, isTrue);
    c.updateRecipientMobile('09');
    expect(c.state.isDeliveryComplete, isFalse);
    expect(c.state.confirmedRequest, isNull);
    expect(c.state.canContinue, isFalse);
    expect(c.state.draft.termsAccepted, isFalse);
  });
  test('initial account matches normalized display number', () async {
    final c =
        withRegisteredDependency<CardIssuanceRepository, CardIssuanceCubit>(
          MockCardIssuanceRepository(),
          () => CardIssuanceCubit(initialDepositNumber: '10.1234567.1'),
        );
    addTearDown(c.close);
    await c.fetchIssuanceCatalog();
    expect(c.state.draft.deposit!.id, 'deposit-1');
    expect(c.state.draft.type, isNull);
    c.requestBack();
    expect(c.state.navigation, FlowNavigation.back);
  });
}
