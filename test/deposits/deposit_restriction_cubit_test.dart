import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/deposits/data/repositories/mock_deposit_restrictions_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/deposit_restriction.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/deposit_restrictions_repository.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/deposit_restriction/cubit/deposit_restriction_cubit.dart';

class ControlledRestrictionRepository
    extends MockDepositRestrictionsRepository {
  bool throwsCatalog = false;
  bool loseFirstResponse = false;
  Completer<Result<DepositRestrictionReceipt>>? pendingSubmission;
  final requests = <DepositRestrictionRequest>[];
  @override
  Future<Result<DepositRestrictionCatalog>> fetchCatalog(
    DepositRestrictionOperation operation,
  ) {
    if (throwsCatalog) throw StateError('unavailable');
    return super.fetchCatalog(operation);
  }

  @override
  Future<Result<DepositRestrictionReceipt>> submitRestriction(
    DepositRestrictionRequest request,
  ) async {
    requests.add(request);
    if (requests.length == 1 && pendingSubmission != null) {
      return pendingSubmission!.future;
    }
    final result = await super.submitRestriction(request);
    if (loseFirstResponse && requests.length == 1) {
      throw StateError('response lost after commit');
    }
    return result;
  }
}

void main() {
  setUp(
    () => getIt.registerSingleton<DepositRestrictionsRepository>(
      MockDepositRestrictionsRepository(),
    ),
  );
  tearDown(() => getIt.reset());

  DepositRestrictionCubit createCubit({
    DepositRestrictionOperation operation = DepositRestrictionOperation.block,
    String? number,
  }) {
    final cubit = DepositRestrictionCubit(
      operation: operation,
      initialDepositNumber: number,
    );
    addTearDown(cubit.close);
    return cubit;
  }

  test(
    'real catalog resolves localized entry and provides eligible deposits only',
    () async {
      final cubit = createCubit(number: '۱۰.۱۲۳۴۵۶۷.۱');
      expect(cubit.state, const DepositRestrictionState.initial());
      await cubit.fetchCatalog();
      expect(cubit.state.deposit!.deposit.id, 'restriction-1');
      expect(cubit.state.catalog!.deposits.length, 2);
      expect(cubit.state.canSubmit, isFalse);
      cubit.selectReason(DepositRestrictionReason.depositManagement);
      cubit.updateTermsAcceptance(true);
      expect(cubit.state.canSubmit, isTrue);
      cubit.updateDescription('   ');
      expect(
        cubit.state.canSubmit,
        isTrue,
        reason: 'description is optional in the supplied design',
      );
      cubit.selectDeposit(cubit.state.catalog!.deposits.last);
      expect(cubit.state.termsAccepted, isFalse);
      expect(cubit.state.canSubmit, isFalse);
      expect(
        () => cubit.state.catalog!.deposits.clear(),
        throwsUnsupportedError,
      );
    },
  );

  test(
    'unblocking loads the selected deposit actual restriction details',
    () async {
      final cubit = createCubit(
        operation: DepositRestrictionOperation.unblock,
        number: '10.1234567.2',
      );
      await cubit.fetchCatalog();
      expect(
        cubit.state.deposit!.blockDetails!.blockedAt,
        DateTime(2025, 12, 1),
      );
      expect(cubit.state.deposit!.blockDetails!.description, 'شخصی');
      cubit.selectReason(DepositRestrictionReason.depositManagement);
      cubit.updateTermsAcceptance(true);
      await cubit.submitRestriction();
      expect(cubit.state.receipt!.isMock, isTrue);
      expect(cubit.state.isEditable, isFalse);
      expect(cubit.state.canSubmit, isFalse);
      final repository = getIt<DepositRestrictionsRepository>();
      final blockCatalog = (await repository.fetchCatalog(
        DepositRestrictionOperation.block,
      ) as Success<DepositRestrictionCatalog>).data;
      expect(
        blockCatalog.deposits.any(
          (option) => option.deposit.id == 'restriction-2',
        ),
        isTrue,
      );
      expect(blockCatalog.walletBalanceRial, 700000);
    },
  );

  test('insufficient funds keep submission disabled and wrong entry stays unselected', () async {
    getIt.unregister<DepositRestrictionsRepository>();
    getIt.registerSingleton<DepositRestrictionsRepository>(
      MockDepositRestrictionsRepository(0),
    );
    final cubit = createCubit(number: '10.1234567.2');
    await cubit.fetchCatalog();
    expect(
      cubit.state.deposit,
      isNull,
      reason: 'blocked entry is not eligible for blocking',
    );
    cubit.selectDeposit(cubit.state.catalog!.deposits.first);
    cubit.selectReason(DepositRestrictionReason.depositManagement);
    cubit.updateTermsAcceptance(true);
    expect(cubit.state.isWalletSufficient, isFalse);
    expect(cubit.state.canSubmit, isFalse);
  });

  test('catalog failure retries; pending submission leaves independent catalog status intact', () async {
    final repository = ControlledRestrictionRepository()..throwsCatalog = true;
    getIt.unregister<DepositRestrictionsRepository>();
    getIt.registerSingleton<DepositRestrictionsRepository>(repository);
    final cubit = createCubit();
    await cubit.fetchCatalog();
    expect(cubit.state.catalogFailure, const UnexpectedFailure());
    repository.throwsCatalog = false;
    await cubit.fetchCatalog();
    cubit.selectDeposit(cubit.state.catalog!.deposits.first);
    cubit.selectReason(DepositRestrictionReason.depositManagement);
    cubit.updateTermsAcceptance(true);
    repository.pendingSubmission = Completer();
    final submission = cubit.submitRestriction();
    expect(cubit.state.submissionStatus, RequestStatus.loading);
    expect(cubit.state.catalogStatus, RequestStatus.success);
    expect(cubit.state.isEditable, isFalse);
    cubit.requestBack();
    expect(cubit.state.effect, DepositRestrictionEffect.confirmExit);
    cubit.applyExitConfirmation(false);
    repository.pendingSubmission!.complete(const Err(DataFailure('timeout')));
    await submission;
    expect(cubit.state.submissionStatus, RequestStatus.failure);
    expect(cubit.state.isEditable, isTrue);
    final key = cubit.state.idempotencyKey;
    cubit.updateDescription('updated');
    expect(cubit.state.idempotencyKey, isNot(key));
    expect(cubit.state.submissionFailure, isNull);
  });

  test(
    'response lost after bank simulation is retried without a second debit',
    () async {
      final repository = ControlledRestrictionRepository()
        ..loseFirstResponse = true;
      getIt.unregister<DepositRestrictionsRepository>();
      getIt.registerSingleton<DepositRestrictionsRepository>(repository);
      final cubit = createCubit(number: '10.1234567.1');
      await cubit.fetchCatalog();
      cubit.selectReason(DepositRestrictionReason.depositManagement);
      cubit.updateDescription(' شخصی ');
      cubit.updateTermsAcceptance(true);
      await cubit.submitRestriction();
      expect(cubit.state.submissionFailure, const UnexpectedFailure());
      final key = cubit.state.idempotencyKey;
      cubit.updateDescription('  شخصی  ');
      expect(cubit.state.idempotencyKey, key);
      await cubit.submitRestriction();
      expect(cubit.state.submissionStatus, RequestStatus.success);
      expect(repository.requests.first, repository.requests.last);
      expect(repository.requests.first.description, 'شخصی');
      final catalog = (await repository.fetchCatalog(
        DepositRestrictionOperation.unblock,
      ) as Success<DepositRestrictionCatalog>).data;
      expect(catalog.walletBalanceRial, 700000);
      expect(catalog.deposits.first.blockDetails!.description, 'شخصی');
    },
  );

  test(
    'mock boundary rejects tampering, opposite operation and stale candidates',
    () async {
      final repository = MockDepositRestrictionsRepository(5000000);
      final catalog = (await repository.fetchCatalog(
        DepositRestrictionOperation.block,
      ) as Success<DepositRestrictionCatalog>).data;
      DepositRestrictionRequest request({
        String key = 'valid',
        String id = 'restriction-1',
        DepositRestrictionOperation operation =
            DepositRestrictionOperation.block,
        String? token,
      }) => DepositRestrictionRequest(
        operation: operation,
        depositId: id,
        reason: DepositRestrictionReason.depositManagement,
        description: '',
        quoteToken: token ?? catalog.quoteToken,
        idempotencyKey: key,
      );
      for (final invalid in [
        request(token: 'unknown'),
        request(id: 'restriction-2'),
        request(operation: DepositRestrictionOperation.unblock),
      ]) {
        expect(
          await repository.submitRestriction(invalid),
          isA<Err<DepositRestrictionReceipt>>(),
        );
      }
      expect(
        await repository.submitRestriction(request()),
        isA<Success<DepositRestrictionReceipt>>(),
      );
      expect(
        await repository.submitRestriction(request(key: 'stale')),
        isA<Err<DepositRestrictionReceipt>>(),
      );
      expect(
        await repository.submitRestriction(request(id: 'restriction-3')),
        isA<Err<DepositRestrictionReceipt>>(),
      );
      final fresh = (await repository.fetchCatalog(
        DepositRestrictionOperation.block,
      ) as Success<DepositRestrictionCatalog>).data;
      expect(fresh.walletBalanceRial, 3700000);
    },
  );

  test(
    'terms and exit effects repeat and interpret raw dismissal/confirmation',
    () async {
      final cubit = createCubit();
      cubit.requestTerms();
      final id = cubit.state.effectId;
      cubit.requestTerms();
      expect(cubit.state.effectId, id + 1);
      cubit.requestBack();
      expect(cubit.state.effect, DepositRestrictionEffect.back);
      cubit.updateDescription('draft');
      cubit.requestAssistant();
      expect(cubit.state.effect, DepositRestrictionEffect.confirmExit);
      cubit.applyExitConfirmation(null);
      expect(cubit.state.effect, isNull);
      cubit.requestAssistant();
      cubit.applyExitConfirmation(true);
      expect(cubit.state.effect, DepositRestrictionEffect.assistant);
      cubit.applyReceiptDismissal();
      expect(cubit.state.effect, DepositRestrictionEffect.home);
    },
  );
}
