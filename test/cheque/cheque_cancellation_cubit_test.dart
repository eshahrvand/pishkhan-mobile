import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/cheque/domain/entities/cheque_cancellation.dart';
import 'package:pishkhan_mobile/features/cheque/domain/repositories/cheque_cancellation_repository.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/cancellation/cubit/cheque_cancellation_cubit.dart';

import 'cheque_cancellation_test_support.dart';

void main() {
  late TestChequeCancellationRepository repository;
  late ChequeCancellationCubit cubit;
  setUp(() {
    repository = TestChequeCancellationRepository();
    getIt.registerSingleton<ChequeCancellationRepository>(repository);
    cubit = ChequeCancellationCubit();
  });
  tearDown(() async {
    await cubit.close();
    await getIt.reset();
  });
  Future<void> select({
    CancellationChequeType type = CancellationChequeType.paper,
    int deposit = 0,
  }) async {
    await cubit.fetchCatalog();
    cubit.selectDeposit(cubit.state.catalog!.deposits[deposit]);
    cubit.selectType(type);
    await cubit.continueFlow();
  }

  Future<void> reasons() async {
    await select();
    cubit.toggleCheque(cubit.state.cheques.first);
    cubit.toggleCheque(cubit.state.cheques[1]);
    await cubit.continueFlow();
    cubit.applyReviewDismissal(true);
  }

  test('constructor preserves state, boundary converts exceptions and retries catalog', () async {
    expect(cubit.state, const ChequeCancellationState.initial());
    repository.throwCatalog = true;
    await cubit.fetchCatalog();
    expect(cubit.state.catalogFailure, const UnexpectedFailure());
    repository.throwCatalog = false;
    await cubit.fetchCatalog();
    cubit.selectType(CancellationChequeType.paper);
    expect(cubit.state.canContinue, isFalse);
    cubit.selectDeposit(cubit.state.catalog!.deposits.first);
    expect(cubit.state.canContinue, isTrue);
  });

  test(
    'Persian, Arabic and Latin search retains selections outside results',
    () async {
      await select();
      cubit.toggleCheque(cubit.state.cheques.first);
      cubit.updateSearchQuery('۱۳۷/۴۸۷۵۶۸');
      expect(cubit.state.visibleCheques.single.cheque, cubit.state.cheques[1]);
      cubit.toggleCheque(cubit.state.visibleCheques.single.cheque);
      expect(cubit.state.selectedEntries, hasLength(2));
      cubit.updateSearchQuery('٢٨٥٤٦٧٨٣٩٨٧٦٥٤٩٠');
      expect(cubit.state.visibleCheques.single.isSelected, isTrue);
      cubit.updateSearchQuery('not-found');
      expect(cubit.state.visibleCheques, isEmpty);
      expect(cubit.state.canContinue, isTrue);
      cubit.updateSearchQuery('');
      cubit.toggleAllCheques(true);
      expect(cubit.state.selectedEntries, hasLength(10));
      expect(cubit.state.isAllSelected, isTrue);
      cubit.toggleAllCheques(false);
      expect(cubit.state.selectedEntries, isEmpty);
      expect(cubit.state.canContinue, isFalse);
    },
  );

  test('review precedes reasons; dismissing review does not advance', () async {
    await select();
    cubit.toggleCheque(cubit.state.cheques.first);
    await cubit.continueFlow();
    expect(cubit.state.effect, ChequeCancellationEffect.review);
    expect(cubit.state.step, ChequeCancellationStep.cheques);
    cubit.applyReviewDismissal(null);
    expect(cubit.state.step, ChequeCancellationStep.cheques);
    await cubit.continueFlow();
    cubit.applyReviewDismissal(true);
    expect(cubit.state.step, ChequeCancellationStep.reasons);
    expect(cubit.state.canContinue, isFalse);
  });

  test('reason drafts commit explicitly, common reason can be overridden individually', () async {
    await reasons();
    cubit.requestReason(cubit.state.selectedEntries.first);
    cubit.selectReasonDraft(ChequeCancellationReason.judicialOrder);
    expect(cubit.state.selectedEntries.first.reason, isNull);
    cubit.requestReason(cubit.state.selectedEntries.first);
    expect(cubit.state.reasonDraft, isNull);
    cubit.requestReasonForAll();
    cubit.selectReasonDraft(ChequeCancellationReason.damagedUnused);
    cubit.applyReason();
    expect(cubit.state.canContinue, isTrue);
    cubit.requestReason(cubit.state.selectedEntries.last);
    cubit.selectReasonDraft(ChequeCancellationReason.judicialOrder);
    cubit.applyReason();
    expect(
      cubit.state.selectedEntries.first.reason,
      ChequeCancellationReason.damagedUnused,
    );
    expect(
      cubit.state.selectedEntries.last.reason,
      ChequeCancellationReason.judicialOrder,
    );
    cubit.requestBack();
    cubit.toggleAllCheques(true);
    expect(
      cubit.state.selectedEntries.first.reason,
      ChequeCancellationReason.damagedUnused,
    );
    expect(cubit.state.selectedEntries.last.reason, isNull);
  });

  test(
    'removing last cheque returns to selection list and disables next',
    () async {
      await reasons();
      cubit.removeCheque(cubit.state.selectedEntries.last.cheque);
      final cheque = cubit.state.selectedEntries.single.cheque;
      cubit.requestChequeRemoval(cheque);
      expect(cubit.state.selectedEntries, hasLength(1));
      cubit.removeCheque(cheque);
      expect(cubit.state.step, ChequeCancellationStep.cheques);
      expect(cubit.state.canContinue, isFalse);
      expect(
        cubit.state.visibleCheques.every((choice) => !choice.isSelected),
        isTrue,
      );
    },
  );

  test(
    'request snapshot survives retry and unchanged back navigation',
    () async {
      await reasons();
      cubit.requestReasonForAll();
      cubit.selectReasonDraft(ChequeCancellationReason.damagedUnused);
      cubit.applyReason();
      await cubit.continueFlow();
      final snapshot = cubit.state.confirmedRequest!;
      expect(cubit.state.canContinue, isFalse);
      cubit.updateTermsAcceptance(true);
      repository.submissionResult = const Err(DataFailure('offline'));
      await cubit.continueFlow();
      expect(cubit.state.isEditable, isTrue);
      expect(cubit.state.confirmedRequest, snapshot);
      cubit.requestBack();
      await cubit.continueFlow();
      expect(cubit.state.confirmedRequest, snapshot);
      cubit.updateTermsAcceptance(true);
      repository.submissionResult = null;
      await cubit.continueFlow();
      expect(repository.requests, [snapshot, snapshot]);
      expect(cubit.state.submissionStatus, RequestStatus.success);
      expect(cubit.state.canContinue, isFalse);
      expect(cubit.state.effect, ChequeCancellationEffect.receipt);
      cubit.applyReceiptDismissal();
      expect(cubit.state.effect, ChequeCancellationEffect.home);
    },
  );

  test(
    'back during list fetch keeps new selections safe from old responses',
    () async {
      repository.controlLists = true;
      await cubit.fetchCatalog();
      cubit.selectDeposit(cubit.state.catalog!.deposits.first);
      cubit.selectType(CancellationChequeType.paper);
      final old = cubit.continueFlow();
      cubit.requestBack();
      expect(cubit.state.chequesStatus, RequestStatus.initial);
      cubit.selectType(CancellationChequeType.digital);
      final fresh = cubit.continueFlow();
      repository.listRequests.last.complete(const Success([]));
      await fresh;
      repository.listRequests.first.complete(
        const Success([
          CancellableCheque(id: 'old', number: 'old', sayadId: 'old'),
        ]),
      );
      await old;
      expect(cubit.state.cheques, isEmpty);
      expect(cubit.state.type, CancellationChequeType.digital);
    },
  );

  test('empty digital catalog stays disabled; changing deposit clears old selection', () async {
    await select(type: CancellationChequeType.digital, deposit: 1);
    expect(cubit.state.cheques, isEmpty);
    expect(cubit.state.canContinue, isFalse);
    cubit.requestBack();
    cubit.selectDeposit(cubit.state.catalog!.deposits.first);
    await cubit.continueFlow();
    cubit.toggleAllCheques(true);
    cubit.requestBack();
    cubit.selectDeposit(cubit.state.catalog!.deposits.last);
    expect(cubit.state.selectedEntries, isEmpty);
    expect(cubit.state.isAllSelected, isFalse);
  });

  test('exit and assistant require confirmation after entering data', () async {
    cubit.requestBack();
    expect(cubit.state.effect, ChequeCancellationEffect.back);
    await cubit.fetchCatalog();
    cubit.selectType(CancellationChequeType.paper);
    cubit.requestAssistant();
    expect(cubit.state.effect, ChequeCancellationEffect.confirmExit);
    cubit.applyExitConfirmation(false);
    expect(cubit.state.effect, isNull);
    cubit.requestAssistant();
    cubit.applyExitConfirmation(true);
    expect(cubit.state.effect, ChequeCancellationEffect.assistant);
  });
}
