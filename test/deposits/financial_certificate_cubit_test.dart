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

void fillLatin(FinancialCertificateCubit cubit) => cubit.latinChanged(
  name: 'Ali',
  surname: 'Raad',
  fatherName: 'Arash',
  passportNumber: '۱۲۳۴۵۶۷۸۹۰',
  expiry: '۲۰۲۶/۰۸/۱۲',
  address: 'Unit 1, No 12, Tehran, Iran, 1234567890',
);

Future<void> readyFinancial(FinancialCertificateCubit cubit) async {
  await cubit.load();
  cubit.selectDeposit('certificate-deposit-1');
  cubit.toggleCondition(FinancialCertificateCondition.homeAddress, true);
  cubit.next();
  cubit.selectRecipient(FinancialCertificateRecipient.embassy);
  cubit.selectEmbassy('demo-embassy');
  cubit.selectCurrency(CertificateCurrency.usd);
  cubit.next();
  fillLatin(cubit);
  cubit.next();
  cubit.selectAddress('home');
  cubit.next();
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
      await cubit.load();
      cubit.selectDeposit('certificate-deposit-1');
      cubit.next();
      expect(cubit.state.step, FinancialCertificateStep.conditions);
      cubit.toggleCondition(FinancialCertificateCondition.homeAddress, true);
      expect(cubit.state.canContinue, isTrue);
      cubit.toggleCondition(FinancialCertificateCondition.homeAddress, false);
      expect(cubit.state.canContinue, isFalse);
      cubit.toggleCondition(FinancialCertificateCondition.exchangeRate, true);
      cubit.selectDeposit('certificate-deposit-2');
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
      cubit.back();
      cubit.back();
      cubit.back();
      cubit.selectRecipient(FinancialCertificateRecipient.otherAuthority);
      expect(cubit.state.embassyId, isNull);
      expect(cubit.state.currency, isNull);
      cubit.authorityChanged('  ');
      cubit.selectCurrency(CertificateCurrency.eur);
      expect(cubit.state.canContinue, isFalse);
      cubit.authorityChanged('  University  ');
      cubit.next();
      cubit.next();
      cubit.next();
      await cubit.submit();
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
      cubit.back();
      cubit.back();
      cubit.latinChanged(name: 'علی');
      expect(cubit.state.canContinue, isFalse);
      cubit.latinChanged(name: 'Ali', expiry: '2026/02/30');
      expect(cubit.state.canContinue, isFalse);
      cubit.latinChanged(expiry: '2026/08/12');
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
    cubit.back();
    cubit.setOtherRecipient(true);
    expect(cubit.state.canContinue, isFalse);
    cubit.deliveryRecipientChanged('گیرنده', '۰۰۸۱۲۳۴۵۶۷');
    expect(cubit.state.canContinue, isTrue);
    cubit.setIncludeAgent(true);
    cubit.next();
    await cubit.submit();
    expect(repo.requests.single.deliveryRecipientNationalId, '0081234567');
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
    await poor.submit();
    expect(poor.state.receipt, isNull);
    await poor.close();
  });
  test('duplicate submission and edits are locked; retry keeps the same request key', () async {
    final repo = FinancialTestRepository();
    final pending = Completer<Result<CertificateReceipt>>();
    repo.submit = (_) => pending.future;
    final cubit =
        withRegisteredDependency<
          FinancialCertificateRepository,
          FinancialCertificateCubit
        >(repo, () => FinancialCertificateCubit());
    await readyFinancial(cubit);
    final first = cubit.submit();
    await cubit.submit();
    cubit.latinChanged(name: 'Changed');
    cubit.selectRecipient(FinancialCertificateRecipient.otherAuthority);
    expect(cubit.state.name, 'Ali');
    expect(cubit.state.recipient, FinancialCertificateRecipient.embassy);
    expect(repo.requests, hasLength(1));
    pending.complete(const Err(UnexpectedFailure()));
    await first;
    final key = repo.requests.single.idempotencyKey;
    repo.submit = (_) async =>
        const Success(CertificateReceipt(reference: 'OK'));
    await cubit.submit();
    await cubit.submit();
    expect(repo.requests, hasLength(2));
    expect(repo.requests.last.idempotencyKey, key);
    expect(cubit.state.submissionStatus, RequestStatus.success);
    await cubit.close();
  });
  test('stale loads and disposed submissions cannot emit', () async {
    final repo = FinancialTestRepository();
    final old = Completer<Result<CertificateCatalog>>();
    repo.loader = () => old.future;
    final cubit =
        withRegisteredDependency<
          FinancialCertificateRepository,
          FinancialCertificateCubit
        >(repo, () => FinancialCertificateCubit());
    final first = cubit.load();
    repo.loader = () async => Success(repo.catalog);
    await cubit.load();
    old.complete(const Err(UnexpectedFailure()));
    await first;
    expect(cubit.state.status, RequestStatus.success);
    await readyFinancial(cubit);
    final pending = Completer<Result<CertificateReceipt>>();
    repo.submit = (_) => pending.future;
    final sending = cubit.submit();
    await cubit.close();
    pending.complete(const Success(CertificateReceipt(reference: 'late')));
    await sending;
  });
}
