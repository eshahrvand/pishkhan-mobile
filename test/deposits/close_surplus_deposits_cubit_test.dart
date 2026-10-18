import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/deposits/data/repositories/mock_surplus_deposits_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/listed_deposit.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/surplus_deposit_closure.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/surplus_deposits_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/usecases/close_surplus_deposits.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/close_surplus_deposits/cubit/close_surplus_deposits_cubit.dart';

class ControlledSurplusRepository extends MockSurplusDepositsRepository {
  final pending = Completer<Result<SurplusDepositClosureReceipt>>();
  final requests = <CloseSurplusDepositsRequest>[];
  bool throwsCatalog = false;
  bool throwsReview = false;
  bool throwsSubmission = false;
  @override
  Future<Result<List<ListedDeposit>>> fetchPrimaryDeposits() {
    if (throwsCatalog) throw StateError('unavailable');
    return super.fetchPrimaryDeposits();
  }

  @override
  Future<Result<SurplusDepositReview>> fetchSurplusDeposits(
    ListedDeposit primaryDeposit,
  ) {
    if (throwsReview) throw StateError('unavailable');
    return super.fetchSurplusDeposits(primaryDeposit);
  }

  @override
  Future<Result<SurplusDepositClosureReceipt>> closeSurplusDeposits(
    CloseSurplusDepositsRequest request,
  ) {
    requests.add(request);
    if (throwsSubmission) throw StateError('unavailable');
    return requests.length == 1
        ? pending.future
        : super.closeSurplusDeposits(request);
  }
}

void main() {
  setUp(
    () => getIt.registerSingleton<SurplusDepositsRepository>(
      MockSurplusDepositsRepository(),
    ),
  );
  tearDown(() => getIt.reset());

  CloseSurplusDepositsCubit createCubit({String? number}) {
    final cubit = CloseSurplusDepositsCubit(initialDepositNumber: number);
    addTearDown(cubit.close);
    return cubit;
  }

  test(
    'constructor stays initial; catalog resolves localized entry number',
    () async {
      final cubit = createCubit(number: '۱۰.۱۲۳۴۵۶۷.۲');
      expect(cubit.state, const CloseSurplusDepositsState.initial());
      await cubit.fetchPrimaryDeposits();
      expect(cubit.state.deposit?.id, 'primary-2');
      expect(cubit.state.canContinue, isFalse);
      cubit.updateTermsAcceptance(true);
      expect(cubit.state.canContinue, isTrue);
      await cubit.continueFlow();
      expect(cubit.state.step, CloseSurplusDepositsStep.review);
      expect(cubit.state.review!.deposits, isEmpty);
      expect(cubit.state.canContinue, isFalse);
      cubit.requestBack();
      expect(cubit.state.step, CloseSurplusDepositsStep.primaryDeposit);
      expect(cubit.state.canContinue, isTrue);
      cubit.selectPrimaryDeposit(cubit.state.deposits.first);
      expect(cubit.state.termsAccepted, isFalse);
      expect(cubit.state.review, isNull);
    },
  );

  test(
    'positive review excludes retained primary and completes a mock closure',
    () async {
      final cubit = createCubit();
      await cubit.fetchPrimaryDeposits();
      cubit.selectPrimaryDeposit(cubit.state.deposits.first);
      cubit.updateTermsAcceptance(true);
      await cubit.continueFlow();
      expect(cubit.state.review!.deposits.length, 2);
      expect(
        cubit.state.review!.deposits.any(
          (deposit) => deposit.id == cubit.state.deposit!.id,
        ),
        isFalse,
      );
      await cubit.continueFlow();
      expect(cubit.state.submissionStatus, RequestStatus.success);
      expect(cubit.state.receipt!.isMock, isTrue);
      expect(cubit.state.canContinue, isFalse);
      final review = await getIt<SurplusDepositsRepository>()
          .fetchSurplusDeposits(cubit.state.deposit!);
      expect((review as Success<SurplusDepositReview>).data.deposits, isEmpty);
    },
  );

  test(
    'independent errors recover; retry keeps the reviewed request and key',
    () async {
      final repository = ControlledSurplusRepository()..throwsCatalog = true;
      getIt.unregister<SurplusDepositsRepository>();
      getIt.registerSingleton<SurplusDepositsRepository>(repository);
      final cubit = createCubit();
      await cubit.fetchPrimaryDeposits();
      expect(cubit.state.depositsFailure, const UnexpectedFailure());
      repository.throwsCatalog = false;
      await cubit.fetchPrimaryDeposits();
      cubit.selectPrimaryDeposit(cubit.state.deposits.first);
      cubit.updateTermsAcceptance(true);
      repository.throwsReview = true;
      await cubit.continueFlow();
      expect(cubit.state.reviewStatus, RequestStatus.failure);
      expect(cubit.state.depositsStatus, RequestStatus.success);
      repository.throwsReview = false;
      await cubit.continueFlow();
      final submission = cubit.continueFlow();
      expect(cubit.state.submissionStatus, RequestStatus.loading);
      expect(cubit.state.isEditable, isFalse);
      repository.pending.complete(const Err(DataFailure('timeout')));
      await submission;
      expect(cubit.state.submissionStatus, RequestStatus.failure);
      expect(cubit.state.reviewStatus, RequestStatus.success);
      await cubit.continueFlow();
      expect(repository.requests[0], repository.requests[1]);
      expect(cubit.state.submissionStatus, RequestStatus.success);
    },
  );

  test(
    'submission exceptions become typed failures at the application boundary',
    () async {
      final repository = ControlledSurplusRepository()..throwsSubmission = true;
      final primary = MockSurplusDepositsRepository.primaryDeposits.first;
      final review = (await repository.fetchSurplusDeposits(
        primary,
      ) as Success<SurplusDepositReview>).data;
      final result = await SubmitCloseSurplusDeposits(repository)(
        CloseSurplusDepositsRequest(
          primaryDepositId: primary.id,
          reviewToken: review.token,
          depositIds: review.deposits.map((d) => d.id),
          idempotencyKey: 'exception',
        ),
      );
      expect(
        result,
        const Err<SurplusDepositClosureReceipt>(UnexpectedFailure()),
      );
    },
  );

  test(
    'exit modal results and repeated terms effects are interpreted by Cubit',
    () async {
      final cubit = createCubit();
      cubit.requestBack();
      expect(cubit.state.effect, CloseSurplusDepositsEffect.back);
      cubit.updateTermsAcceptance(true);
      cubit.requestAssistant();
      expect(cubit.state.effect, CloseSurplusDepositsEffect.confirmExit);
      cubit.applyExitConfirmation(null);
      expect(cubit.state.effect, isNull);
      cubit.requestAssistant();
      cubit.applyExitConfirmation(true);
      expect(cubit.state.effect, CloseSurplusDepositsEffect.assistant);
      cubit.requestTerms();
      final id = cubit.state.effectId;
      cubit.requestTerms();
      expect(cubit.state.effectId, id + 1);
    },
  );

  test(
    'repository enforces primary/review binding and idempotent outcomes',
    () async {
      final repository = MockSurplusDepositsRepository();
      final primary = MockSurplusDepositsRepository.primaryDeposits.first;
      final review = (await repository.fetchSurplusDeposits(
        primary,
      ) as Success<SurplusDepositReview>).data;
      final request = CloseSurplusDepositsRequest(
        primaryDepositId: primary.id,
        reviewToken: review.token,
        depositIds: review.deposits.map((d) => d.id),
        idempotencyKey: 'retry',
      );
      final result = await repository.closeSurplusDeposits(request);
      expect(result, isA<Success<SurplusDepositClosureReceipt>>());
      final retried = await repository.closeSurplusDeposits(
        request,
      ) as Success<SurplusDepositClosureReceipt>;
      expect(
        retried.data,
        (result as Success<SurplusDepositClosureReceipt>).data,
      );
      for (final invalid in [
        CloseSurplusDepositsRequest(
          primaryDepositId: 'primary-3',
          reviewToken: review.token,
          depositIds: request.depositIds,
          idempotencyKey: 'changed-primary',
        ),
        CloseSurplusDepositsRequest(
          primaryDepositId: primary.id,
          reviewToken: review.token,
          depositIds: [primary.id],
          idempotencyKey: 'primary-in-list',
        ),
        CloseSurplusDepositsRequest(
          primaryDepositId: primary.id,
          reviewToken: review.token,
          depositIds: [],
          idempotencyKey: 'retry',
        ),
        CloseSurplusDepositsRequest(
          primaryDepositId: primary.id,
          reviewToken: 'unknown',
          depositIds: request.depositIds,
          idempotencyKey: 'unknown',
        ),
        CloseSurplusDepositsRequest(
          primaryDepositId: primary.id,
          reviewToken: review.token,
          depositIds: request.depositIds,
          idempotencyKey: 'already-closed',
        ),
      ]) {
        expect(
          await repository.closeSurplusDeposits(invalid),
          isA<Err<SurplusDepositClosureReceipt>>(),
        );
      }
    },
  );
}
