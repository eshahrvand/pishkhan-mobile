import '../../../../../support/registered_dependency.dart';

import 'package:pishkhan_mobile/core/enums/request_status.dart';

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/cards/presentation/virtual_card_request/virtual_card_request.dart';
import 'package:pishkhan_mobile/features/cards/presentation/virtual_card_request/cubit/virtual_card_cubit.dart';

class TestVirtualRepository implements VirtualCardRepository {
  VirtualCardCatalog catalog = MockVirtualCardRepository.catalog;
  final pendingQuotes = <Completer<Result<VirtualCardQuote>>>[];
  bool holdQuotes = false, throwLoad = false, mockReceipt = true;
  Failure? failure, submitFailure;
  Completer<Result<VirtualCardReceipt>>? submitting;
  final requests = <VirtualCardRequest>[];
  int wallet = 2000000;
  @override
  Future<Result<VirtualCardCatalog>> load() async {
    if (throwLoad) throw StateError('transport');
    return Success(catalog);
  }

  VirtualCardQuote value(String id, int count) => VirtualCardQuote(
    id: '$id:$count',
    depositId: id,
    count: count,
    perCardFeeRial: 300000,
    totalRial: count == 4 ? 1300000 : count * 300000,
    walletBalanceRial: wallet,
  );
  @override
  Future<Result<VirtualCardQuote>> quote(String id, int count) async {
    if (holdQuotes) {
      final pending = Completer<Result<VirtualCardQuote>>();
      pendingQuotes.add(pending);
      return pending.future;
    }
    return failure == null ? Success(value(id, count)) : Err(failure!);
  }

  @override
  Future<Result<VirtualCardReceipt>> submit(VirtualCardRequest request) async {
    requests.add(request);
    return submitting != null
        ? submitting!.future
        : submitFailure != null
        ? Err(submitFailure!)
        : Success(
            VirtualCardReceipt(
              reference: 'VC-98649466583',
              isMock: mockReceipt,
            ),
          );
  }
}

Future<void> fillVirtual(VirtualCardCubit c) async {
  await c.selectDeposit(
    c.state.catalog!.deposits.firstWhere(
      (deposit) => deposit.id == 'virtual-deposit-1',
    ),
  );
  await c.updateCount('۴');
  c.updateTermsAcceptance(true);
}

void main() {
  test(
    'quote, positive bounded count, wallet and consent gate submission',
    () async {
      final r = TestVirtualRepository();
      final c =
          withRegisteredDependency<VirtualCardRepository, VirtualCardCubit>(
            r,
            () => VirtualCardCubit(),
          );
      await c.fetchCatalog();
      await c.selectDeposit(
        c.state.catalog!.deposits.firstWhere(
          (deposit) => deposit.id == 'virtual-deposit-1',
        ),
      );
      for (final value in ['', '0', '1000', '4.5', '-1', 'abc']) {
        await c.updateCount(value);
        expect(c.state.canSubmit, false);
      }
      await c.updateCount('٤');
      expect(c.state.count, 4);
      expect(c.state.quote!.totalRial, 1300000);
      expect(c.state.canSubmit, false);
      c.updateTermsAcceptance(true);
      expect(c.state.canSubmit, true);
      await c.updateCount('5');
      expect(c.state.termsAccepted, false);
      expect(c.state.quote!.count, 5);
      r.wallet = 0;
      await c.fetchQuote();
      c.updateTermsAcceptance(true);
      expect(c.state.canSubmit, false);
      expect(r.requests, isEmpty);
      await c.close();
    },
  );
  test(
    'entering count before choosing a deposit starts quoting on selection',
    () async {
      final cubit =
          withRegisteredDependency<VirtualCardRepository, VirtualCardCubit>(
            TestVirtualRepository(),
            () => VirtualCardCubit(),
          );
      addTearDown(cubit.close);
      await cubit.fetchCatalog();
      await cubit.updateCount('۴');
      expect(cubit.state.isCountValid, isTrue);
      expect(cubit.state.quote, isNull);
      await cubit.selectDeposit(cubit.state.catalog!.deposits.first);
      expect(cubit.state.quote?.count, 4);
      expect(cubit.state.quoteStatus, RequestStatus.success);
      cubit.updateTermsAcceptance(true);
      expect(cubit.state.canSubmit, isTrue);
    },
  );

  for (final fails in [false, true]) {
    test(
      'invalid count discards an in-flight quote (failure: $fails)',
      () async {
        final repository = TestVirtualRepository()..holdQuotes = true;
        final cubit =
            withRegisteredDependency<VirtualCardRepository, VirtualCardCubit>(
              repository,
              () => VirtualCardCubit(),
            );
        addTearDown(cubit.close);
        await cubit.fetchCatalog();
        await cubit.updateCount('۴');
        expect(repository.pendingQuotes, isEmpty);

        final pending = cubit.selectDeposit(
          cubit.state.catalog!.deposits.first,
        );
        expect(repository.pendingQuotes, hasLength(1));
        expect(cubit.state.quoteStatus, RequestStatus.loading);

        await cubit.updateCount('');
        expect(repository.pendingQuotes, hasLength(1));
        expect(cubit.state.quoteStatus, RequestStatus.initial);
        repository.pendingQuotes.single.complete(
          fails
              ? const Err(DataFailure('old-quote'))
              : Success(repository.value(cubit.state.deposit!.id, 4)),
        );
        await pending;

        expect(cubit.state.quoteStatus, RequestStatus.initial);
        expect(cubit.state.quote, isNull);
        expect(cubit.state.failure, isNull);
        expect(cubit.state.message, isNull);
        expect(cubit.state.canRetry, isFalse);
        expect(cubit.state.canSubmit, isFalse);
      },
    );
  }

  test('late quotes cannot replace current selection; invalid quote bindings are rejected', () async {
    final r = TestVirtualRepository()..holdQuotes = true;
    final c = withRegisteredDependency<VirtualCardRepository, VirtualCardCubit>(
      r,
      () => VirtualCardCubit(),
    );
    await c.fetchCatalog();
    await c.selectDeposit(
      c.state.catalog!.deposits.firstWhere(
        (deposit) => deposit.id == 'virtual-deposit-1',
      ),
    );
    final old = c.updateCount('3');
    final latest = c.updateCount('4');
    r.pendingQuotes[1].complete(Success(r.value('virtual-deposit-1', 4)));
    await latest;
    r.pendingQuotes[0].complete(Success(r.value('virtual-deposit-1', 3)));
    await old;
    expect(c.state.quote!.count, 4);
    expect(c.state.quoteStatus, RequestStatus.success);
    final bad = c.selectDeposit(
      c.state.catalog!.deposits.firstWhere(
        (deposit) => deposit.id == 'virtual-deposit-2',
      ),
    );
    r.pendingQuotes[2].complete(Success(r.value('virtual-deposit-1', 4)));
    await bad;
    expect(c.state.quote, isNull);
    expect(c.state.failure!.code, 'virtual.quote.invalid');
    expect(c.state.quoteStatus, RequestStatus.failure);
    expect(c.state.catalogStatus, RequestStatus.success);
    await c.close();
  });
  test(
    'submission disables editing and retry keeps key until request changes',
    () async {
      final r = TestVirtualRepository()
        ..submitFailure = const DataFailure('network');
      final c =
          withRegisteredDependency<VirtualCardRepository, VirtualCardCubit>(
            r,
            () => VirtualCardCubit(),
          );
      await c.fetchCatalog();
      await fillVirtual(c);
      await c.submitVirtualCards();
      await c.submitVirtualCards();
      expect(r.requests[0].idempotencyKey, r.requests[1].idempotencyKey);
      await c.selectDeposit(c.state.deposit!);
      c.updateTermsAcceptance(true);
      await c.submitVirtualCards();
      expect(r.requests.last, r.requests.first);
      await c.updateCount('٤');
      c.updateTermsAcceptance(true);
      await c.submitVirtualCards();
      expect(r.requests.last, r.requests.first);
      await c.updateCount('2');
      c.updateTermsAcceptance(true);
      r.submitFailure = null;
      r.submitting = Completer();
      final task = c.submitVirtualCards();
      expect(c.state.submissionStatus, RequestStatus.loading);
      expect(c.state.quoteStatus, RequestStatus.success);
      expect(c.state.isEditable, isFalse);
      expect(c.state.canSubmit, isFalse);
      expect(r.requests.length, 5);
      expect(c.state.count, 2);
      expect(
        r.requests.last.idempotencyKey,
        isNot(r.requests.first.idempotencyKey),
      );
      r.submitting!.complete(
        const Success(VirtualCardReceipt(reference: 'ok', isMock: true)),
      );
      await task;
      expect(c.state.submissionStatus, RequestStatus.success);
      await c.close();
    },
  );
  test('empty/invalid catalogs, transport failures and quote retry are recoverable', () async {
    final r = TestVirtualRepository()
      ..catalog = VirtualCardCatalog(deposits: [], indicativePerCardFeeRial: 0);
    final c = withRegisteredDependency<VirtualCardRepository, VirtualCardCubit>(
      r,
      () => VirtualCardCubit(),
    );
    await c.fetchCatalog();
    expect(c.state.catalogStatus, RequestStatus.success);
    expect(c.state.catalog!.deposits, isEmpty);
    r.catalog = VirtualCardCatalog(
      deposits: const [
        VirtualCardDeposit(id: 'x', number: '1'),
        VirtualCardDeposit(id: 'x', number: '2'),
      ],
      indicativePerCardFeeRial: 0,
    );
    await c.fetchCatalog();
    expect(c.state.catalogStatus, RequestStatus.failure);
    r.catalog = MockVirtualCardRepository.catalog;
    r.throwLoad = true;
    await c.fetchCatalog();
    expect(c.state.catalogStatus, RequestStatus.failure);
    r.throwLoad = false;
    await c.fetchCatalog();
    r.failure = const DataFailure('network');
    await fillVirtual(c);
    expect(c.state.canSubmit, false);
    expect(c.state.failure, isNotNull);
    r.failure = null;
    await c.fetchQuote();
    expect(c.state.quote, isNotNull);
    expect(c.state.termsAccepted, false);
    await c.close();
  });
  test(
    'initial deposit normalization and construction preserve a clean entry',
    () async {
      final repository = TestVirtualRepository();
      const initialState = VirtualCardState.initial(isInvoiceExpanded: false);
      final cubit =
          withRegisteredDependency<VirtualCardRepository, VirtualCardCubit>(
            repository,
            () => VirtualCardCubit(
              initialState: initialState,
              initialDepositNumber: '۱۰.۱۲۳۴۵۶۷.۱',
            ),
          );
      addTearDown(cubit.close);
      expect(cubit.state, same(initialState));
      await cubit.fetchCatalog();
      expect(cubit.state.deposit?.id, 'virtual-deposit-1');
      cubit.requestBack();
      expect(cubit.state.navigation, FlowNavigation.back);
      await cubit.updateCount('4');
      cubit.requestBack();
      expect(cubit.state.navigation, FlowNavigation.confirmExit);
      cubit.applyExitConfirmation(null);
      expect(cubit.state.navigation, isNull);
      expect(cubit.state.countText, '4');
    },
  );

  test(
    'invalid count invalidates a pending quote before its response arrives',
    () async {
      final repository = TestVirtualRepository()..holdQuotes = true;
      final cubit =
          withRegisteredDependency<VirtualCardRepository, VirtualCardCubit>(
            repository,
            () => VirtualCardCubit(),
          );
      addTearDown(cubit.close);
      await cubit.fetchCatalog();
      await cubit.selectDeposit(cubit.state.catalog!.deposits.first);
      final pending = cubit.updateCount('4');
      await cubit.updateCount('0');
      repository.pendingQuotes.single.complete(
        Success(repository.value(cubit.state.deposit!.id, 4)),
      );
      await pending;
      expect(cubit.state.isCountValid, isFalse);
      expect(cubit.state.isCountError, isTrue);
      expect(cubit.state.quote, isNull);
      expect(cubit.state.quoteStatus, RequestStatus.initial);
      expect(cubit.state.canSubmit, isFalse);
    },
  );

  test(
    'quote and submission failures retain independent retry contracts',
    () async {
      final repository = TestVirtualRepository()
        ..failure = const DataFailure('quote-offline');
      final cubit =
          withRegisteredDependency<VirtualCardRepository, VirtualCardCubit>(
            repository,
            () => VirtualCardCubit(),
          );
      addTearDown(cubit.close);
      await cubit.fetchCatalog();
      await fillVirtual(cubit);
      expect(cubit.state.failure?.code, 'quote-offline');
      expect(cubit.state.catalogStatus, RequestStatus.success);
      expect(cubit.state.submissionStatus, RequestStatus.initial);
      expect(cubit.state.retryAction, VirtualCardRetryAction.quote);
      repository.failure = null;
      await cubit.submitRetry();
      expect(cubit.state.failure, isNull);
      cubit.updateTermsAcceptance(true);
      repository.submitFailure = const DataFailure('submit-offline');
      await cubit.submitVirtualCards();
      expect(cubit.state.failure?.code, 'submit-offline');
      expect(cubit.state.quoteStatus, RequestStatus.success);
      expect(cubit.state.retryAction, VirtualCardRetryAction.submission);
      cubit.updateTermsAcceptance(false);
      expect(cubit.state.canRetry, isFalse);
      cubit.updateTermsAcceptance(true);
      expect(cubit.state.canRetry, isTrue);
      repository.submitFailure = null;
      await cubit.submitRetry();
      expect(
        repository.requests.first.idempotencyKey,
        repository.requests.last.idempotencyKey,
      );
      expect(cubit.state.navigation, FlowNavigation.home);
    },
  );

  test(
    'mock submit accepts only issued sufficient quotes and is idempotent',
    () async {
      final r = MockVirtualCardRepository();
      final quote = (await r.quote(
        'virtual-deposit-1',
        4,
      ) as Success<VirtualCardQuote>).data;
      final request = VirtualCardRequest(quote: quote, idempotencyKey: 'one');
      final first = await r.submit(request);
      final second = await r.submit(request);
      expect(
        (first as Success<VirtualCardReceipt>).data,
        (second as Success<VirtualCardReceipt>).data,
      );
      final insufficient = (await r.quote(
        'virtual-deposit-1',
        10,
      ) as Success<VirtualCardQuote>).data;
      expect(
        await r.submit(
          VirtualCardRequest(quote: insufficient, idempotencyKey: 'two'),
        ),
        isA<Err<VirtualCardReceipt>>(),
      );
    },
  );
}
