import '../support/registered_dependency.dart';

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/features/deposits/data/repositories/mock_deposit_certificates_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/certificate_data.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/deposit_certificates_repository.dart';
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
  await cubit.fetchCatalog();
  cubit.selectDeposit(cubit.state.catalog!.deposits.first);
  cubit.selectLanguage(CertificateLanguage.english);
  cubit.selectTurnover(StatementTurnover.depositsAndWithdrawals);
}

void main() {
  test('dates are optional; selection resets dependent conditions; back retains fields', () async {
    final cubit =
        withRegisteredDependency<
          DepositCertificatesRepository,
          AverageBalanceCubit
        >(CertificateTestRepository(), () => AverageBalanceCubit());
    await readyAverage(cubit);
    expect(cubit.state.fromDate, isNull);
    expect(cubit.state.toDate, isNull);
    expect(cubit.state.canContinue, isTrue);
    await cubit.continueFlow();
    expect(cubit.state.step, AverageBalanceStep.delivery);
    expect(cubit.state.canContinue, isFalse);
    cubit.selectAddress(cubit.state.addresses.first);
    await cubit.continueFlow();
    expect(cubit.state.step, AverageBalanceStep.confirmation);
    cubit.requestBack();
    expect(cubit.state.address!.id, 'home');
    cubit.requestBack();
    cubit.selectDeposit(cubit.state.catalog!.deposits[1]);
    expect(cubit.state.language, isNull);
    expect(cubit.state.canContinue, isFalse);
    await cubit.close();
  });
  test(
    'recipient is conditional; optional agent and hidden fields are omitted',
    () async {
      final repository = CertificateTestRepository();
      final cubit =
          withRegisteredDependency<
            DepositCertificatesRepository,
            AverageBalanceCubit
          >(repository, () => AverageBalanceCubit());
      await readyAverage(cubit);
      await cubit.continueFlow();
      cubit.selectAddress(cubit.state.addresses.first);
      cubit.updateOtherRecipient(true);
      expect(cubit.state.canContinue, isFalse);
      cubit.updateRecipientName('گیرنده');
      cubit.updateRecipientNationalId('۰۰۸۱۲۳۴۵۶۲');
      expect(cubit.state.canContinue, isTrue);
      cubit.updateIncludeAgent(true);
      expect(cubit.state.canContinue, isTrue);
      cubit.updateAgentIdentifier('۰۹۱۲۱۲۳۴۵۶۷');
      cubit.updateOtherRecipient(false);
      cubit.updateIncludeAgent(false);
      await cubit.continueFlow();
      await cubit.submitCertificate();
      expect(repository.requests.single.recipientName, isNull);
      expect(repository.requests.single.agentIdentifier, isNull);
      await cubit.close();
    },
  );
  test(
    'unchanged retry keeps key and successful submission disables continuation',
    () async {
      final repository = CertificateTestRepository();
      final pending = Completer<Result<CertificateReceipt>>();
      repository.submit = (_) => pending.future;
      final cubit =
          withRegisteredDependency<
            DepositCertificatesRepository,
            AverageBalanceCubit
          >(repository, () => AverageBalanceCubit());
      await readyAverage(cubit);
      await cubit.continueFlow();
      cubit.selectAddress(cubit.state.addresses.first);
      await cubit.continueFlow();
      final first = cubit.submitCertificate();
      expect(cubit.state.submissionStatus, RequestStatus.loading);
      expect(repository.requests, hasLength(1));
      pending.complete(const Err(UnexpectedFailure()));
      await first;
      final key = repository.requests.single.idempotencyKey;
      repository.submit = (_) async =>
          const Success(CertificateReceipt(reference: 'OK'));
      await cubit.submitCertificate();
      expect(repository.requests.last.idempotencyKey, key);
      expect(cubit.state.submissionStatus, RequestStatus.success);
      await cubit.close();
    },
  );
  test(
    'wallet gates final action and catalog failure can be retried',
    () async {
      final poor = CertificateCatalog(
        deposits: MockDepositCertificatesRepository.examples.deposits,
        addresses: MockDepositCertificatesRepository.examples.addresses,
        walletBalanceRial: 0,
      );
      final cubit =
          withRegisteredDependency<
            DepositCertificatesRepository,
            AverageBalanceCubit
          >(
            CertificateTestRepository(catalog: poor),
            () => AverageBalanceCubit(),
          );
      await readyAverage(cubit);
      await cubit.continueFlow();
      cubit.selectAddress(cubit.state.addresses.first);
      await cubit.continueFlow();
      expect(cubit.state.canContinue, isFalse);
      await cubit.close();
      final repo = CertificateTestRepository();
      repo.loader = () async => const Err(UnexpectedFailure());
      final retry =
          withRegisteredDependency<
            DepositCertificatesRepository,
            AverageBalanceCubit
          >(repo, () => AverageBalanceCubit());
      await retry.fetchCatalog();
      expect(retry.state.catalogStatus, RequestStatus.failure);
      repo.loader = () async => Success(repo.catalog);
      await retry.fetchCatalog();
      expect(retry.state.catalogStatus, RequestStatus.success);
      expect(retry.state.catalogFailure, isNull);
      await retry.close();
    },
  );
  test(
    'editing a failed payload refreshes its key; unchanged retry preserves it',
    () async {
      final repository = CertificateTestRepository()
        ..submit = (_) async => const Err(UnexpectedFailure());
      final cubit =
          withRegisteredDependency<
            DepositCertificatesRepository,
            AverageBalanceCubit
          >(repository, () => AverageBalanceCubit());
      await readyAverage(cubit);
      await cubit.continueFlow();
      cubit.selectAddress(cubit.state.addresses.first);
      await cubit.continueFlow();
      await cubit.submitCertificate();
      final firstKey = repository.requests.single.idempotencyKey;
      cubit.requestBack();
      cubit.updateIncludeAgent(true);
      await cubit.continueFlow();
      await cubit.submitCertificate();
      expect(repository.requests.last.agentIdentifier, isNull);
      expect(repository.requests.last.idempotencyKey, firstKey);
      cubit.requestBack();
      cubit.updateAgentIdentifier('   ');
      cubit.updateRecipientName('Hidden recipient');
      cubit.updateRecipientNationalId('0081234562');
      await cubit.continueFlow();
      await cubit.submitCertificate();
      expect(repository.requests.last.idempotencyKey, firstKey);
      cubit.requestBack();
      cubit.updateAgentIdentifier('123');
      await cubit.continueFlow();
      await cubit.submitCertificate();
      final changedKey = repository.requests.last.idempotencyKey;
      expect(changedKey, isNot(firstKey));
      expect(repository.requests.last.agentIdentifier, '123');
      await cubit.submitCertificate();
      expect(repository.requests.last.idempotencyKey, changedKey);
      await cubit.close();
    },
  );
}
