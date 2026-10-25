import '../support/registered_dependency.dart';

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/validators/passport_validator.dart';
import 'package:pishkhan_mobile/features/deposits/data/repositories/mock_deposit_certificates_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/certificate_data.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/financial_certificate_data.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/financial_certificate_repository.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/financial_certificate/cubit/financial_certificate_cubit.dart';

class FinancialTestRepository implements FinancialCertificateRepository {
  FinancialTestRepository({CertificateCatalog? catalog})
    : catalog = catalog ?? MockDepositCertificatesRepository.examples;
  final CertificateCatalog catalog;
  final requests = <FinancialCertificateRequest>[];
  Future<Result<CertificateReceipt>> Function(FinancialCertificateRequest)?
  submit;
  Future<Result<CertificateCatalog>> Function()? loader;
  @override
  Future<Result<CertificateCatalog>> load() async =>
      loader == null ? Success(catalog) : loader!();
  @override
  Future<Result<CertificateReceipt>> submitFinancialCertificate(
    FinancialCertificateRequest request,
  ) async {
    requests.add(request);
    return submit == null
        ? const Success(CertificateReceipt(reference: 'DEMO', isMock: true))
        : submit!(request);
  }
}

void fillLatin(FinancialCertificateCubit cubit) {
  cubit.updateLatinName('Ali');
  cubit.updateLatinSurname('Raad');
  cubit.updateLatinFatherName('Arash');
  cubit.updatePassportNumber('۱۲۳۴۵۶۷۸۹۰');
  cubit.updatePassportExpiry('۲۰۲۶/۰۸/۱۲');
  cubit.updateLatinAddress('Unit 1, No 12, Tehran, Iran, 1234567890');
}

Future<void> readyFinancial(FinancialCertificateCubit cubit) async {
  await cubit.fetchCatalog();
  cubit.selectDeposit(cubit.state.catalog!.deposits.first);
  cubit.toggleCondition(FinancialCertificateCondition.homeAddress);
  await cubit.continueFlow();
  cubit.selectRecipient(FinancialCertificateRecipient.embassy);
  cubit.selectEmbassy(cubit.state.catalog!.embassies.first);
  cubit.selectCurrency(CertificateCurrency.usd);
  await cubit.continueFlow();
  fillLatin(cubit);
  await cubit.continueFlow();
  cubit.selectAddress(cubit.state.addresses.first);
  await cubit.continueFlow();
}

void main() {
  test(
    'conditions gate next; changing deposit clears selected conditions',
    () async {
      final cubit =
          withRegisteredDependency<
            FinancialCertificateRepository,
            FinancialCertificateCubit
          >(FinancialTestRepository(), () => FinancialCertificateCubit());
      await cubit.fetchCatalog();
      cubit.selectDeposit(cubit.state.catalog!.deposits.first);
      expect(cubit.state.canContinue, isFalse);
      expect(cubit.state.step, FinancialCertificateStep.conditions);
      cubit.toggleCondition(FinancialCertificateCondition.homeAddress);
      expect(cubit.state.canContinue, isTrue);
      cubit.toggleCondition(FinancialCertificateCondition.homeAddress);
      expect(cubit.state.canContinue, isFalse);
      cubit.toggleCondition(FinancialCertificateCondition.exchangeRate);
      cubit.selectDeposit(cubit.state.catalog!.deposits[1]);
      expect(cubit.state.conditions, isEmpty);
      expect(cubit.state.canContinue, isFalse);
      await cubit.close();
    },
  );
  test(
    'recipient branches require their own fields and discard hidden values',
    () async {
      final repo = FinancialTestRepository();
      final cubit =
          withRegisteredDependency<
            FinancialCertificateRepository,
            FinancialCertificateCubit
          >(repo, () => FinancialCertificateCubit());
      await readyFinancial(cubit);
      cubit.requestBack();
      cubit.requestBack();
      cubit.requestBack();
      cubit.selectRecipient(FinancialCertificateRecipient.otherAuthority);
      expect(cubit.state.embassy, isNull);
      expect(cubit.state.currency, isNull);
      cubit.updateAuthorityName('  ');
      cubit.selectCurrency(CertificateCurrency.eur);
      expect(cubit.state.canContinue, isFalse);
      cubit.updateAuthorityName('  University  ');
      await cubit.continueFlow();
      await cubit.continueFlow();
      await cubit.continueFlow();
      await cubit.submitCertificate();
      expect(repo.requests.single.embassyId, isNull);
      expect(repo.requests.single.authorityName, 'University');
      expect(repo.requests.single.currency, CertificateCurrency.eur);
      expect(repo.requests.single.identity.passportNumber, '1234567890');
      expect(
        repo.requests.single.identity.passportExpiry,
        DateTime.utc(2026, 8, 12),
      );
      expect(repo.requests.single.deliveryRecipientName, isNull);
      await cubit.close();
    },
  );
  test(
    'Latin validation accepts real Gregorian dates and multiline addresses',
    () {
      expect(PassportValidator.expiry('2026/02/30'), isNull);
      expect(PassportValidator.expiry('2028/02/29'), DateTime.utc(2028, 2, 29));
      expect(PassportValidator.expiry('2026/13/01'), isNull);
      expect(PassportValidator.latinName('علی'), isFalse);
      expect(PassportValidator.latinName("Jean-Pierre O'Neil"), isTrue);
      expect(PassportValidator.latinAddress('Unit 1\nTehran, Iran'), isTrue);
      expect(PassportValidator.latinAddress('تهران'), isFalse);
    },
  );
  test(
    'Latin edits disable progression until all required values are valid',
    () async {
      final cubit =
          withRegisteredDependency<
            FinancialCertificateRepository,
            FinancialCertificateCubit
          >(FinancialTestRepository(), () => FinancialCertificateCubit());
      await readyFinancial(cubit);
      cubit.requestBack();
      cubit.requestBack();
      cubit.updateLatinName('علی');
      expect(cubit.state.canContinue, isFalse);
      cubit.updateLatinName('Ali');
      cubit.updatePassportExpiry('2026/02/30');
      expect(cubit.state.canContinue, isFalse);
      cubit.updatePassportExpiry('2026/08/12');
      expect(cubit.state.canContinue, isTrue);
      await cubit.close();
    },
  );
  test('wallet and alternate delivery recipient gate submit; optional agent is omitted', () async {
    final repo = FinancialTestRepository();
    final cubit =
        withRegisteredDependency<
          FinancialCertificateRepository,
          FinancialCertificateCubit
        >(repo, () => FinancialCertificateCubit());
    await readyFinancial(cubit);
    cubit.requestBack();
    cubit.updateOtherRecipient(true);
    expect(cubit.state.canContinue, isFalse);
    cubit.updateRecipientName('گیرنده');
    cubit.updateRecipientNationalId('۰۰۸۱۲۳۴۵۶۲');
    expect(cubit.state.canContinue, isTrue);
    cubit.updateIncludeAgent(true);
    await cubit.continueFlow();
    await cubit.submitCertificate();
    expect(repo.requests.single.deliveryRecipientNationalId, '0081234562');
    expect(repo.requests.single.agentIdentifier, isNull);
    await cubit.close();
    final poor =
        withRegisteredDependency<
          FinancialCertificateRepository,
          FinancialCertificateCubit
        >(
          FinancialTestRepository(
            catalog: CertificateCatalog(
              deposits: repo.catalog.deposits,
              addresses: repo.catalog.addresses,
              walletBalanceRial: 0,
            ),
          ),
          () => FinancialCertificateCubit(),
        );
    await readyFinancial(poor);
    expect(poor.state.canContinue, isFalse);
    expect(poor.state.receipt, isNull);
    await poor.close();
  });
  test(
    'unchanged retry keeps the request key and success disables continuation',
    () async {
      final repo = FinancialTestRepository();
      final pending = Completer<Result<CertificateReceipt>>();
      repo.submit = (_) => pending.future;
      final cubit =
          withRegisteredDependency<
            FinancialCertificateRepository,
            FinancialCertificateCubit
          >(repo, () => FinancialCertificateCubit());
      await readyFinancial(cubit);
      final first = cubit.submitCertificate();
      expect(cubit.state.submissionStatus, RequestStatus.loading);
      expect(repo.requests, hasLength(1));
      pending.complete(const Err(UnexpectedFailure()));
      await first;
      final key = repo.requests.single.idempotencyKey;
      repo.submit = (_) async =>
          const Success(CertificateReceipt(reference: 'OK'));
      await cubit.submitCertificate();
      expect(repo.requests, hasLength(2));
      expect(repo.requests.last.idempotencyKey, key);
      expect(cubit.state.submissionStatus, RequestStatus.success);
      await cubit.close();
    },
  );
  test(
    'catalog errors are retryable and independent of submission errors',
    () async {
      final repo = FinancialTestRepository();
      repo.loader = () async => const Err(UnexpectedFailure());
      final cubit =
          withRegisteredDependency<
            FinancialCertificateRepository,
            FinancialCertificateCubit
          >(repo, () => FinancialCertificateCubit());
      await cubit.fetchCatalog();
      expect(cubit.state.catalogStatus, RequestStatus.failure);
      expect(cubit.state.failure, isA<UnexpectedFailure>());
      repo.loader = () async => Success(repo.catalog);
      await cubit.fetchCatalog();
      expect(cubit.state.catalogStatus, RequestStatus.success);
      expect(cubit.state.failure, isNull);
      await cubit.close();
    },
  );
  test(
    'editing a failed payload refreshes its key; unchanged retry preserves it',
    () async {
      final repository = FinancialTestRepository()
        ..submit = (_) async => const Err(UnexpectedFailure());
      final cubit =
          withRegisteredDependency<
            FinancialCertificateRepository,
            FinancialCertificateCubit
          >(repository, () => FinancialCertificateCubit());
      await readyFinancial(cubit);
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
