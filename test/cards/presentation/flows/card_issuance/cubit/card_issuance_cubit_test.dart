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
    cubit.selectDeposit('deposit-1');
    cubit.selectIssuanceType(IssuanceType.newNumber);
  }

  void confirm(CardIssuanceCubit cubit) {
    select(cubit);
    cubit.advanceStep();
    cubit.selectAddress('home');
    cubit.advanceStep();
    cubit.updateTermsAcceptance(true);
  }

  test(
    'both selections remain required with no physical card enabled',
    () async {
      final c = await ready();
      c.updatePhysicalCardOmission(true);
      c.advanceStep();
      expect(c.state.step, IssuanceStep.selection);
      expect(c.state.canContinue, false);
      c.selectDeposit('deposit-1');
      expect(c.state.canContinue, false);
      c.selectIssuanceType(IssuanceType.newNumber);
      expect(c.state.canContinue, true);
      c.advanceStep();
      expect(c.state.step, IssuanceStep.confirmation);
      expect(c.state.request!.address, isNull);
      expect(c.state.totalRial, 600000);
      expect(
        c.state.fees.any((f) => f.kind == IssuanceFeeKind.delivery),
        false,
      );
      c.requestBack();
      expect(c.state.step, IssuanceStep.selection);
    },
  );
  test('physical path requires address and explicit terms; fee total follows items', () async {
    final c = await ready();
    select(c);
    c.advanceStep();
    expect(c.state.step, IssuanceStep.delivery);
    expect(c.state.canContinue, false);
    c.selectAddress('home');
    c.advanceStep();
    expect(c.state.step, IssuanceStep.confirmation);
    expect(c.state.totalRial, 1600000);
    expect(c.state.canContinue, false);
    c.updateTermsAcceptance(true);
    expect(c.state.canContinue, true);
    c.requestBack();
    c.selectAddress('home');
    expect(c.state.draft.termsAccepted, false);
  });
  test(
    'recipient and agent requirements are conditional and normalize digits',
    () async {
      final c = await ready();
      select(c);
      c.advanceStep();
      c.selectAddress('home');
      c.updateOtherRecipient(true);
      expect(c.state.canContinue, false);
      c.updateRecipientName('گیرنده');
      c.updateRecipientNationalId('۱۲۳۴۵۶۷۸۹۱');
      c.updateRecipientMobile('۰۹۱۲۱۲۳۴۵۶۷');
      expect(c.state.draft.recipient.nationalId, '1234567891');
      expect(c.state.canContinue, true);
      c.updateAgentInclusion(true);
      expect(c.state.canContinue, false);
      c.updateAgentName('کارشناس');
      c.updateAgentCode('۱۲۳');
      expect(c.state.canContinue, true);
      c.advanceStep();
      expect(c.state.request!.recipient, isNotNull);
      expect(c.state.request!.agent!.code, '123');
    },
  );
  test('hidden physical data is excluded from nonphysical request', () async {
    final c = await ready();
    confirm(c);
    c.requestBack();
    c.updateOtherRecipient(true);
    c.updateAgentInclusion(true);
    c.requestBack();
    c.updatePhysicalCardOmission(true);
    c.advanceStep();
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
    c.selectIssuanceType(null);
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
      expect(c.state.status, RequestStatus.failure);
      repository.catalogResult = Success(
        IssuanceCatalog(
          deposits: [],
          addresses: [],
          fees: [],
          walletBalanceRial: 0,
        ),
      );
      await c.fetchIssuanceCatalog();
      expect(c.state.status, RequestStatus.success);
      expect(c.state.catalog!.deposits, isEmpty);
      repository.catalogResult = Success(
        MockCardIssuanceRepository.sampleCatalog,
      );
      await c.fetchIssuanceCatalog();
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
    expect(c.state.canContinue, false);
    await c.submitCardIssuance();
    expect(c.state.status, RequestStatus.success);
  });
  test('submission captures selection once, locks editing, and reports mock receipt', () async {
    final repository = ControlledIssuanceRepository()..submitting = Completer();
    final c = await ready(repository: repository);
    confirm(c);
    final pending = c.submitCardIssuance();
    await c.submitCardIssuance();
    c.selectDeposit('deposit-2');
    expect(repository.calls, 1);
    expect(c.state.submissionStatus, RequestStatus.loading);
    expect(c.state.deposit!.id, 'deposit-1');
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
  test(
    'unexpected catalog and submission exceptions become retryable failures',
    () async {
      final repository = ControlledIssuanceRepository()..throwOnLoad = true;
      final c = await ready(repository: repository);
      expect(c.state.status, RequestStatus.failure);
      expect(c.state.failure, const UnexpectedFailure());

      repository.throwOnLoad = false;
      await c.fetchIssuanceCatalog();
      confirm(c);
      repository.throwOnSubmit = true;
      await c.submitCardIssuance();
      expect(c.state.submissionStatus, RequestStatus.failure);
      expect(c.state.failure, const UnexpectedFailure());
      expect(c.state.editable, isTrue);
      expect(c.state.canContinue, isTrue);

      repository.throwOnSubmit = false;
      await c.submitCardIssuance();
      expect(c.state.submissionStatus, RequestStatus.success);
      expect(c.state.failure, isNull);
    },
  );
  test(
    'pending and successful submission lock all edits and catalog reset',
    () async {
      final repository = ControlledIssuanceRepository()
        ..submitting = Completer();
      final c = await ready(repository: repository);
      confirm(c);
      final pending = c.submitCardIssuance();
      final lockedState = c.state;

      c.updateRecipientName('late edit');
      c.updateRecipientNationalId('1234567891');
      c.updateRecipientMobile('09121234567');
      c.updateAgentName('late agent');
      c.updateAgentCode('9');
      c.updateOtherRecipient(true);
      c.updateAgentInclusion(true);
      c.updatePhysicalCardOmission(true);
      c.updateTermsAcceptance(false);
      c.selectIssuanceType(IssuanceType.existingNumber);
      c.selectDeposit('deposit-2');
      c.selectAddress('home');
      c.removeAddress('home');
      expect(
        c.addAddress(title: 'new', detail: 'new', postalCode: '1234567890'),
        isFalse,
      );
      c.updateInvoiceExpansion(false);
      c.updateSummaryExpansion(false);
      c.advanceStep();
      c.requestBack();
      c.requestHome();
      await c.fetchIssuanceCatalog();
      await c.continueFlow();
      expect(c.state, lockedState);
      expect(repository.calls, 1);

      repository.submitting!.complete(repository.submitResult);
      await pending;
      final completedState = c.state;
      await c.fetchIssuanceCatalog();
      await c.submitCardIssuance();
      c.updateRecipientName('after success');
      expect(c.state, completedState);
      expect(repository.calls, 1);
    },
  );
  test(
    'each recipient and agent edit publishes fresh eligibility and request',
    () async {
      final c = await ready();
      confirm(c);
      c.updateOtherRecipient(true);
      expect(c.state.draft.termsAccepted, isFalse);
      expect(c.state.deliveryComplete, isFalse);
      expect(c.state.request, isNull);
      c.updateRecipientName('گیرنده');
      c.updateRecipientNationalId('۱۲۳۴۵۶۷۸۹۱');
      c.updateRecipientMobile('۰۹۱۲۱۲۳۴۵۶۷');
      expect(c.state.deliveryComplete, isTrue);
      expect(c.state.request!.recipient, c.state.draft.recipient);
      c.updateTermsAcceptance(true);
      expect(c.state.canContinue, isTrue);

      c.updateAgentInclusion(true);
      expect(c.state.canContinue, isFalse);
      expect(c.state.request, isNull);
      c.updateAgentName('کارشناس');
      c.updateAgentCode('۱۲۳');
      expect(c.state.request!.agent!.code, '123');
      c.updateTermsAcceptance(true);
      expect(c.state.canContinue, isTrue);
      c.updateRecipientMobile('۰۹');
      expect(c.state.deliveryComplete, isFalse);
      expect(c.state.request, isNull);
      expect(c.state.canContinue, isFalse);
      expect(c.state.draft.termsAccepted, isFalse);
    },
  );
  test(
    'catalog and submission completions after close preserve the last state',
    () async {
      final repository = ControlledIssuanceRepository()..loading = Completer();
      final catalogCubit =
          withRegisteredDependency<CardIssuanceRepository, CardIssuanceCubit>(
            repository,
            () => CardIssuanceCubit(),
          );
      final fetching = catalogCubit.fetchIssuanceCatalog();
      await catalogCubit.close();
      final closedCatalogState = catalogCubit.state;
      repository.loading!.complete(repository.catalogResult);
      await fetching;
      expect(catalogCubit.state, closedCatalogState);

      final submittingRepository = ControlledIssuanceRepository()
        ..submitting = Completer();
      final submittingCubit =
          withRegisteredDependency<CardIssuanceRepository, CardIssuanceCubit>(
            submittingRepository,
            () => CardIssuanceCubit(),
          );
      await submittingCubit.fetchIssuanceCatalog();
      confirm(submittingCubit);
      final submitting = submittingCubit.submitCardIssuance();
      await submittingCubit.close();
      final closedSubmissionState = submittingCubit.state;
      submittingRepository.submitting!.complete(
        submittingRepository.submitResult,
      );
      await submitting;
      expect(submittingCubit.state, closedSubmissionState);
    },
  );
  test('overlapping fetches ignore the older catalog result', () async {
    final repository = ControlledIssuanceRepository()..loading = Completer();
    final c =
        withRegisteredDependency<CardIssuanceRepository, CardIssuanceCubit>(
          repository,
          () => CardIssuanceCubit(),
        );
    addTearDown(c.close);
    final firstResponse = repository.loading!;
    final loading = c.fetchIssuanceCatalog();
    repository.loading = null;
    await c.fetchIssuanceCatalog();
    firstResponse.complete(const Err(DataFailure('stale')));
    await loading;
    expect(c.state.status, RequestStatus.success);
  });
  test('initial account matches normalized display number', () async {
    final c =
        withRegisteredDependency<CardIssuanceRepository, CardIssuanceCubit>(
          MockCardIssuanceRepository(),
          () => CardIssuanceCubit(initialDepositNumber: '10.1234567.1'),
        );
    addTearDown(c.close);
    await c.fetchIssuanceCatalog();
    expect(c.state.deposit!.id, 'deposit-1');
    expect(c.state.draft.type, isNull);
    c.requestBack();
    expect(c.state.navigation, FlowNavigation.back);
  });
}
