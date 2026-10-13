import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/features/deposits/deposits.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/average_balance/cubit/average_balance_cubit.dart';

class CertificateTestRepository implements DepositCertificatesRepository {
  CertificateTestRepository({CertificateCatalog? catalog})
    : catalog = catalog ?? MockDepositCertificatesRepository.examples;
  final CertificateCatalog catalog;
  final requests = <AverageBalanceRequest>[];
  Future<Result<CertificateReceipt>> Function(AverageBalanceRequest)? submit;
  Future<Result<CertificateCatalog>> Function()? loader;
  @override
  Future<Result<CertificateCatalog>> load() async =>
      loader == null ? Success(catalog) : loader!();
  @override
  Future<Result<CertificateReceipt>> submitAverageBalance(
    AverageBalanceRequest request,
  ) async {
    requests.add(request);
    return submit == null
        ? const Success(CertificateReceipt(reference: 'DEMO', isMock: true))
        : submit!(request);
  }
}

Future<void> readyAverage(AverageBalanceCubit cubit) async {
  await cubit.load();
  cubit.selectDeposit('certificate-deposit-1');
  cubit.selectLanguage(CertificateLanguage.english);
  cubit.selectTurnover(StatementTurnover.depositsAndWithdrawals);
}

void main() {
  test('dates are optional; selection resets dependent conditions; back retains fields', () async {
    final cubit = AverageBalanceCubit(repository: CertificateTestRepository());
    await readyAverage(cubit);
    expect(cubit.state.fromDate, isNull);
    expect(cubit.state.toDate, isNull);
    expect(cubit.state.canContinue, isTrue);
    cubit.next();
    expect(cubit.state.step, AverageBalanceStep.delivery);
    expect(cubit.state.canContinue, isFalse);
    cubit.selectAddress('home');
    cubit.next();
    expect(cubit.state.step, AverageBalanceStep.confirmation);
    expect(cubit.back(), isTrue);
    expect(cubit.state.address!.id, 'home');
    cubit.back();
    cubit.selectDeposit('certificate-deposit-2');
    expect(cubit.state.language, isNull);
    expect(cubit.state.canContinue, isFalse);
    await cubit.close();
  });
  test(
    'recipient is conditional; optional agent and hidden fields are omitted',
    () async {
      final repository = CertificateTestRepository();
      final cubit = AverageBalanceCubit(repository: repository);
      await readyAverage(cubit);
      cubit.next();
      cubit.selectAddress('home');
      cubit.setOtherRecipient(true);
      expect(cubit.state.canContinue, isFalse);
      cubit.recipientChanged('گیرنده', '۰۰۸۱۲۳۴۵۶۷');
      expect(cubit.state.canContinue, isTrue);
      cubit.setIncludeAgent(true);
      expect(cubit.state.canContinue, isTrue);
      cubit.agentChanged('۰۹۱۲۱۲۳۴۵۶۷');
      cubit.setOtherRecipient(false);
      cubit.setIncludeAgent(false);
      cubit.next();
      await cubit.submit();
      expect(repository.requests.single.recipientName, isNull);
      expect(repository.requests.single.agentIdentifier, isNull);
      await cubit.close();
    },
  );
  test(
    'submission locks edits and duplicate requests; unchanged retry keeps key',
    () async {
      final repository = CertificateTestRepository();
      final pending = Completer<Result<CertificateReceipt>>();
      repository.submit = (_) => pending.future;
      final cubit = AverageBalanceCubit(repository: repository);
      await readyAverage(cubit);
      cubit.next();
      cubit.selectAddress('home');
      cubit.next();
      final first = cubit.submit();
      await cubit.submit();
      cubit.selectDeposit('certificate-deposit-2');
      cubit.recipientChanged('changed', '1');
      expect(cubit.state.deposit!.id, 'certificate-deposit-1');
      expect(repository.requests, hasLength(1));
      pending.complete(const Err(UnexpectedFailure()));
      await first;
      final key = repository.requests.single.idempotencyKey;
      repository.submit = (_) async =>
          const Success(CertificateReceipt(reference: 'OK'));
      await cubit.submit();
      expect(repository.requests.last.idempotencyKey, key);
      expect(cubit.state.submissionStatus, RequestStatus.success);
      await cubit.close();
    },
  );
  test(
    'wallet gates final submit; invalid catalog and stale loads are safe',
    () async {
      final poor = CertificateCatalog(
        deposits: MockDepositCertificatesRepository.examples.deposits,
        addresses: MockDepositCertificatesRepository.examples.addresses,
        walletBalanceRial: 0,
      );
      final cubit = AverageBalanceCubit(
        repository: CertificateTestRepository(catalog: poor),
      );
      await readyAverage(cubit);
      cubit.next();
      cubit.selectAddress('home');
      cubit.next();
      expect(cubit.state.canContinue, isFalse);
      await cubit.submit();
      await cubit.close();
      final repo = CertificateTestRepository();
      final old = Completer<Result<CertificateCatalog>>();
      repo.loader = () => old.future;
      final guarded = AverageBalanceCubit(repository: repo);
      final first = guarded.load();
      repo.loader = () async => Success(repo.catalog);
      await guarded.load();
      await guarded.close();
      old.complete(const Err(UnexpectedFailure()));
      await first;
    },
  );
}
