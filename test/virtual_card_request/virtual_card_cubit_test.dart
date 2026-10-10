import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/virtual_card_request/virtual_card_request.dart';
import 'package:pishkhan_mobile/features/virtual_card_request/presentation/cubit/virtual_card_cubit.dart';

class TestVirtualRepository implements VirtualCardRepository {
  VirtualCardCatalog catalog = MockVirtualCardRepository.catalog;
  Completer<Result<VirtualCardCatalog>>? loading;
  final pendingQuotes = <Completer<Result<VirtualCardQuote>>>[];
  bool holdQuotes = false, throwLoad = false, mockReceipt = true;
  Failure? quoteFailure, submitFailure;
  Completer<Result<VirtualCardReceipt>>? submitting;
  final requests = <VirtualCardRequest>[];
  int wallet = 2000000;
  @override
  Future<Result<VirtualCardCatalog>> load() async {
    if (throwLoad) throw StateError('transport');
    return loading == null ? Success(catalog) : loading!.future;
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
    return quoteFailure == null
        ? Success(value(id, count))
        : Err(quoteFailure!);
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
  await c.selectDeposit('virtual-deposit-1');
  await c.countChanged('۴');
  c.acceptTerms(true);
}

void main() {
  test(
    'quote, positive bounded count, wallet and consent gate submission',
    () async {
      final r = TestVirtualRepository();
      final c = VirtualCardCubit(repository: r);
      await c.load();
      await c.selectDeposit('virtual-deposit-1');
      for (final value in ['', '0', '1000', '4.5', '-1', 'abc']) {
        await c.countChanged(value);
        expect(c.state.canSubmit, false);
      }
      await c.countChanged('٤');
      expect(c.state.count, 4);
      expect(c.state.quote!.totalRial, 1300000);
      expect(c.state.canSubmit, false);
      c.acceptTerms(true);
      expect(c.state.canSubmit, true);
      await c.countChanged('5');
      expect(c.state.terms, false);
      expect(c.state.quote!.count, 5);
      r.wallet = 0;
      await c.refreshQuote();
      c.acceptTerms(true);
      expect(c.state.canSubmit, false);
      await c.submit();
      expect(r.requests, isEmpty);
      await c.close();
    },
  );
  test('late quotes cannot replace current selection; invalid quote bindings are rejected', () async {
    final r = TestVirtualRepository()..holdQuotes = true;
    final c = VirtualCardCubit(repository: r);
    await c.load();
    await c.selectDeposit('virtual-deposit-1');
    final old = c.countChanged('3');
    final latest = c.countChanged('4');
    r.pendingQuotes[1].complete(Success(r.value('virtual-deposit-1', 4)));
    await latest;
    r.pendingQuotes[0].complete(Success(r.value('virtual-deposit-1', 3)));
    await old;
    expect(c.state.quote!.count, 4);
    final bad = c.selectDeposit('virtual-deposit-2');
    r.pendingQuotes[2].complete(Success(r.value('virtual-deposit-1', 4)));
    await bad;
    expect(c.state.quote, isNull);
    expect(c.state.failure!.code, 'virtual.quote.invalid');
    await c.close();
  });
  test(
    'duplicate sends and edits lock; retry keeps key until request changes',
    () async {
      final r = TestVirtualRepository()
        ..submitFailure = const DataFailure('network');
      final c = VirtualCardCubit(repository: r);
      await c.load();
      await fillVirtual(c);
      await c.submit();
      await c.submit();
      expect(r.requests[0].idempotencyKey, r.requests[1].idempotencyKey);
      await c.countChanged('2');
      c.acceptTerms(true);
      r.submitFailure = null;
      r.submitting = Completer();
      final task = c.submit();
      await c.submit();
      await c.countChanged('3');
      await c.selectDeposit('virtual-deposit-2');
      expect(r.requests.length, 3);
      expect(c.state.count, 2);
      expect(
        r.requests.last.idempotencyKey,
        isNot(r.requests.first.idempotencyKey),
      );
      r.submitting!.complete(
        const Success(VirtualCardReceipt(reference: 'ok', isMock: true)),
      );
      await task;
      expect(c.state.status, VirtualCardStatus.submitted);
      await c.close();
    },
  );
  test('empty/invalid catalogs, transport failures and quote retry are recoverable', () async {
    final r = TestVirtualRepository()
      ..catalog = VirtualCardCatalog(deposits: [], indicativePerCardFeeRial: 0);
    final c = VirtualCardCubit(repository: r);
    await c.load();
    expect(c.state.status, VirtualCardStatus.empty);
    r.catalog = VirtualCardCatalog(
      deposits: const [
        VirtualCardDeposit(id: 'x', number: '1'),
        VirtualCardDeposit(id: 'x', number: '2'),
      ],
      indicativePerCardFeeRial: 0,
    );
    await c.load();
    expect(c.state.status, VirtualCardStatus.failed);
    r.catalog = MockVirtualCardRepository.catalog;
    r.throwLoad = true;
    await c.load();
    expect(c.state.status, VirtualCardStatus.failed);
    r.throwLoad = false;
    await c.load();
    r.quoteFailure = const DataFailure('network');
    await fillVirtual(c);
    expect(c.state.canSubmit, false);
    expect(c.state.failure, isNotNull);
    r.quoteFailure = null;
    await c.refreshQuote();
    expect(c.state.quote, isNotNull);
    expect(c.state.terms, false);
    await c.close();
  });
  test(
    'initial deposit normalization, disposal and latest load guard',
    () async {
      final r = TestVirtualRepository();
      final c = VirtualCardCubit(
        repository: r,
        initialDepositNumber: '۱۰.۱۲۳۴۵۶۷.۱',
      );
      await c.load();
      expect(c.state.depositId, 'virtual-deposit-1');
      r.loading = Completer();
      final old = c.load();
      final pending = r.loading!;
      r.loading = null;
      await c.load();
      pending.complete(const Err(DataFailure('old')));
      await old;
      expect(c.state.status, VirtualCardStatus.ready);
      r.holdQuotes = true;
      final task = c.countChanged('4');
      await c.close();
      r.pendingQuotes.single.complete(Success(r.value('virtual-deposit-1', 4)));
      await task;
      expect(c.isClosed, true);
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
