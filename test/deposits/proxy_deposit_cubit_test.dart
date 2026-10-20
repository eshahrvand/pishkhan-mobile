import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/deposits/data/repositories/mock_proxy_deposits_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/proxy_deposit.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/proxy_deposits_repository.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/proxy_deposit/cubit/proxy_deposit_cubit.dart';

class ControlledProxyRepository extends MockProxyDepositsRepository {
  bool throwsCatalog = false;
  bool loseFirstResponse = false;
  Completer<Result<ProxyDepositReceipt>>? pending;
  final requests = <ProxyDepositRequest>[];
  @override
  Future<Result<ProxyDepositCatalog>> fetchCatalog() {
    if (throwsCatalog) throw StateError('unavailable');
    return super.fetchCatalog();
  }

  @override
  Future<Result<ProxyDepositReceipt>> submitProxyDeposit(
    ProxyDepositRequest request,
  ) async {
    requests.add(request);
    if (pending != null && requests.length == 1) {
      return pending!.future;
    }
    final result = await super.submitProxyDeposit(request);
    if (loseFirstResponse && requests.length == 1) {
      throw StateError('response lost');
    }
    return result;
  }
}

void main() {
  setUp(
    () => getIt.registerSingleton<ProxyDepositsRepository>(
      MockProxyDepositsRepository(),
    ),
  );
  tearDown(() => getIt.reset());
  ProxyDepositCubit createCubit({String? number}) {
    final cubit = ProxyDepositCubit(initialDepositNumber: number);
    addTearDown(cubit.close);
    return cubit;
  }

  test('catalog fetch resolves localized deposit entry; all three selections and consent are required', () async {
    final cubit = createCubit(number: '۱۰.۱۲۳۴۵۶۷.۲');
    expect(cubit.state, const ProxyDepositState.initial());
    await cubit.fetchCatalog();
    expect(cubit.state.deposit!.id, 'proxy-2');
    expect(cubit.state.subject, isNull);
    cubit.updateTermsAcceptance(true);
    expect(cubit.state.canSubmit, isFalse);
    cubit.selectCompany(cubit.state.catalog!.companies.first);
    expect(cubit.state.subjects.length, 1);
    cubit.selectSubject(cubit.state.subjects.first);
    expect(cubit.state.amountToman, 500000000);
    expect(cubit.state.subject!.brokerName, 'سازمان حمایت از مصرف کننده');
    expect(cubit.state.deposit!.id, 'proxy-2');
    expect(cubit.state.canSubmit, isFalse);
    cubit.updateTermsAcceptance(true);
    expect(cubit.state.canSubmit, isTrue);
    expect(
      () => cubit.state.catalog!.companies.clear(),
      throwsUnsupportedError,
    );
  });

  test('subject-first choice resolves company and clears a deposit outside the new eligible set', () async {
    final cubit = createCubit(number: '10.1234567.3');
    await cubit.fetchCatalog();
    cubit.selectSubject(cubit.state.subjects.first);
    expect(cubit.state.company!.id, 'autonovin');
    expect(cubit.state.deposit, isNull);
    expect(cubit.state.deposits.map((d) => d.id), ['proxy-1', 'proxy-2']);
    cubit.selectDeposit(cubit.state.deposits.first);
    cubit.updateTermsAcceptance(true);
    final key = cubit.state.idempotencyKey;
    cubit.selectCompany(cubit.state.catalog!.companies.last);
    expect(cubit.state.subject, isNull);
    expect(cubit.state.amountToman, isNull);
    expect(cubit.state.termsAccepted, isFalse);
    expect(cubit.state.canSubmit, isFalse);
    expect(cubit.state.idempotencyKey, isNot(key));
    cubit.selectSubject(cubit.state.subjects.single);
    expect(cubit.state.deposit, isNull);
    expect(cubit.state.subject!.brokerName, 'کارگزار آزمایشی');
    expect(cubit.state.amountToman, 100000000);
  });

  test('catalog error recovers and pending submit preserves independent statuses and Back', () async {
    final repository = ControlledProxyRepository()..throwsCatalog = true;
    getIt.unregister<ProxyDepositsRepository>();
    getIt.registerSingleton<ProxyDepositsRepository>(repository);
    final cubit = createCubit();
    await cubit.fetchCatalog();
    expect(cubit.state.catalogFailure, const UnexpectedFailure());
    repository.throwsCatalog = false;
    await cubit.fetchCatalog();
    cubit.selectSubject(cubit.state.subjects.first);
    cubit.selectDeposit(cubit.state.deposits.first);
    cubit.updateTermsAcceptance(true);
    repository.pending = Completer();
    final submission = cubit.submitProxyDeposit();
    expect(cubit.state.submissionStatus, RequestStatus.loading);
    expect(cubit.state.catalogStatus, RequestStatus.success);
    expect(cubit.state.isEditable, isFalse);
    cubit.requestBack();
    expect(cubit.state.effect, ProxyDepositEffect.confirmExit);
    cubit.applyExitConfirmation(null);
    repository.pending!.complete(const Err(DataFailure('unavailable')));
    await submission;
    expect(cubit.state.isEditable, isTrue);
    expect(cubit.state.submissionStatus, RequestStatus.failure);
    await cubit.submitProxyDeposit();
    expect(repository.requests.first, repository.requests.last);
    expect(cubit.state.submissionStatus, RequestStatus.success);
    expect(cubit.state.canSubmit, isFalse);
  });

  test('lost response reuses the same request identity and returns the original mock receipt', () async {
    final repository = ControlledProxyRepository()..loseFirstResponse = true;
    getIt.unregister<ProxyDepositsRepository>();
    getIt.registerSingleton<ProxyDepositsRepository>(repository);
    final cubit = createCubit(number: '10.1234567.2');
    await cubit.fetchCatalog();
    cubit.selectSubject(cubit.state.subjects.first);
    cubit.updateTermsAcceptance(true);
    await cubit.submitProxyDeposit();
    expect(cubit.state.submissionFailure, const UnexpectedFailure());
    await cubit.submitProxyDeposit();
    expect(repository.requests.first, repository.requests.last);
    expect(cubit.state.receipt!.reference, 'DEMO-PROXY-1');
    expect(cubit.state.receipt!.isMock, isTrue);
  });

  test('mock service rejects altered selections, key conflicts and duplicate mandate requests', () async {
    final repository = MockProxyDepositsRepository();
    final catalog = MockProxyDepositsRepository.catalog;
    ProxyDepositRequest request({
      String company = 'autonovin',
      String deposit = 'proxy-2',
      String key = 'test',
      String? token,
    }) => ProxyDepositRequest(
      companyId: company,
      subjectId: 'imported-cars',
      depositId: deposit,
      catalogToken: token ?? catalog.token,
      idempotencyKey: key,
    );
    for (final invalid in [
      request(company: 'demo'),
      request(deposit: 'proxy-3'),
      request(token: 'unknown'),
    ]) {
      expect(
        await repository.submitProxyDeposit(invalid),
        isA<Err<ProxyDepositReceipt>>(),
      );
    }
    final result = await repository.submitProxyDeposit(
      request(),
    ) as Success<ProxyDepositReceipt>;
    final retried = await repository.submitProxyDeposit(
      request(),
    ) as Success<ProxyDepositReceipt>;
    expect(result.data, retried.data);
    expect(
      await repository.submitProxyDeposit(request(deposit: 'proxy-1')),
      isA<Err<ProxyDepositReceipt>>(),
    );
    expect(
      await repository.submitProxyDeposit(request(key: 'duplicate')),
      isA<Err<ProxyDepositReceipt>>(),
    );
  });

  test('repeated terms effects and exit confirmation stay in Cubit', () {
    final cubit = createCubit();
    cubit.requestTerms();
    final id = cubit.state.effectId;
    cubit.requestTerms();
    expect(cubit.state.effectId, id + 1);
    cubit.requestBack();
    expect(cubit.state.effect, ProxyDepositEffect.back);
    cubit.updateTermsAcceptance(true);
    cubit.requestAssistant();
    cubit.applyExitConfirmation(false);
    expect(cubit.state.effect, isNull);
    cubit.requestAssistant();
    cubit.applyExitConfirmation(true);
    expect(cubit.state.effect, ProxyDepositEffect.assistant);
    cubit.applyReceiptDismissal();
    expect(cubit.state.effect, ProxyDepositEffect.home);
  });
}
