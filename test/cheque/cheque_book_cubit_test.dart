import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/cheque/domain/entities/cheque_book.dart';
import 'package:pishkhan_mobile/features/cheque/domain/repositories/cheque_book_repository.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/book_issuance/cubit/cheque_book_cubit.dart';

import 'cheque_book_test_support.dart';

void main() {
  tearDown(() => getIt.reset());
  ChequeBookCubit create(
    TestChequeBookRepository repository, {
    String? depositNumber,
  }) {
    getIt.registerSingleton<ChequeBookRepository>(repository);
    final cubit = ChequeBookCubit(initialDepositNumber: depositNumber);
    addTearDown(cubit.close);
    return cubit;
  }

  Future<void> selectBook(ChequeBookCubit cubit) async {
    await cubit.fetchCatalog();
    cubit.selectDeposit(cubit.state.catalog!.deposits.first);
    cubit.selectLeafCount(50);
    await cubit.continueFlow();
  }

  test('constructor stays initial; entry number and per-deposit leaf eligibility resolve on fetch', () async {
    final cubit = create(
      TestChequeBookRepository(),
      depositNumber: '۱۰.۱۲۳۴۵۶۷.۱',
    );
    expect(cubit.state, const ChequeBookState.initial());
    await cubit.fetchCatalog();
    expect(cubit.state.deposit!.id, 'deposit-1');
    cubit.selectLeafCount(50);
    expect(cubit.state.canContinue, isTrue);
    cubit.selectDeposit(cubit.state.catalog!.deposits.last);
    expect(cubit.state.leafCount, isNull);
    expect(cubit.state.leafCounts, [10, 25]);
    expect(cubit.state.canContinue, isFalse);
  });

  test('individual delivery requires address; recipient validation only when other recipient is enabled', () async {
    final repository = TestChequeBookRepository();
    final cubit = create(repository);
    await selectBook(cubit);
    expect(cubit.state.step, ChequeBookStep.delivery);
    expect(cubit.state.canContinue, isFalse);
    cubit.selectAddress(cubit.state.deliveryAddresses.first);
    expect(cubit.state.canContinue, isTrue);
    cubit.updateOtherRecipient(true);
    expect(cubit.state.canContinue, isFalse);
    cubit.updateRecipientName('آرمان پارسی');
    cubit.updateRecipientNationalId('۰۰۸');
    expect(cubit.state.isRecipientNationalIdError, isTrue);
    expect(cubit.state.isRecipientNameValid, isTrue);
    cubit.updateRecipientNationalId('۰۰۸۱۲۳۴۵۶۲');
    expect(cubit.state.isRecipientNationalIdError, isFalse);
    expect(cubit.state.canContinue, isTrue);
    cubit.updateOtherRecipient(false);
    cubit.updateAgentInclusion(true);
    cubit.updateAgentIdentifier('۰۹۱۲۱۲۳۴۵۶۷');
    await cubit.continueFlow();
    expect(cubit.state.stepNumber, 4);
    expect(repository.drafts.single.recipientName, isNull);
    expect(repository.drafts.single.recipientNationalId, isNull);
    expect(repository.drafts.single.agentIdentifier, '09121234567');
    expect(cubit.state.totalRial, 1300000);
    expect(cubit.state.isWalletSufficient, isTrue);
  });

  test(
    'legal applicant uses verified address and must provide recipient identity',
    () async {
      final repository = TestChequeBookRepository(
        applicant: ChequeBookApplicant.legal,
      );
      final cubit = create(repository);
      await selectBook(cubit);
      expect(cubit.state.address, isNotNull);
      expect(cubit.state.isRecipientRequired, isTrue);
      expect(cubit.state.canContinue, isFalse);
      cubit.updateRecipientName('آرمان پارسی');
      cubit.updateRecipientNationalId('0081234562');
      expect(cubit.state.canContinue, isTrue);
      await cubit.continueFlow();
      expect(repository.drafts.single.recipientNationalId, '0081234562');
      await cubit.continueFlow();
      expect(cubit.state.submissionStatus, RequestStatus.success);
      expect(cubit.state.effect, ChequeBookEffect.receipt);
      cubit.applyReceiptDismissal();
      expect(cubit.state.effect, ChequeBookEffect.home);
    },
  );

  test(
    'one unregistered home is a blocking notice whose acknowledge exits',
    () async {
      final cubit = create(TestChequeBookRepository(registered: [false]));
      await selectBook(cubit);
      expect(cubit.state.step, ChequeBookStep.residency);
      expect(cubit.state.stepNumber, 2);
      expect(cubit.state.isAddressDeletionAvailable, isFalse);
      expect(cubit.state.primaryAction, ChequeBookAction.understood);
      await cubit.continueFlow();
      expect(cubit.state.effect, ChequeBookEffect.home);
    },
  );

  test('mixed addresses allow deleting the invalid one and continuing with the verified address', () async {
    final cubit = create(TestChequeBookRepository(registered: [false, true]));
    await selectBook(cubit);
    expect(cubit.state.step, ChequeBookStep.residency);
    expect(cubit.state.canContinue, isTrue);
    final invalid = cubit.state.residency!.residences.first.address;
    cubit.requestDeleteAddress(invalid);
    expect(cubit.state.pendingAddress, invalid);
    await cubit.deleteAddress(invalid);
    expect(cubit.state.step, ChequeBookStep.delivery);
    expect(cubit.state.deliveryAddresses, hasLength(1));
    expect(cubit.state.residency!.residences.single.isRegistered, isTrue);
  });

  test('multiple invalid addresses block next; removing one leaves the single-address warning', () async {
    final cubit = create(TestChequeBookRepository(registered: [false, false]));
    await selectBook(cubit);
    expect(cubit.state.canContinue, isFalse);
    expect(cubit.state.isAddressDeletionAvailable, isTrue);
    await cubit.deleteAddress(cubit.state.residency!.residences.first.address);
    expect(cubit.state.step, ChequeBookStep.residency);
    expect(cubit.state.isAddressDeletionAvailable, isFalse);
    expect(cubit.state.canContinue, isTrue);
    await cubit.continueFlow();
    expect(cubit.state.effect, ChequeBookEffect.home);
  });

  test('deletion failure preserves addresses and can be retried', () async {
    final repository = TestChequeBookRepository(registered: [false, true])
      ..failsDeletion = true;
    final cubit = create(repository);
    await selectBook(cubit);
    final address = cubit.state.residency!.residences.first.address;
    await cubit.deleteAddress(address);
    expect(cubit.state.residency!.residences, hasLength(2));
    expect(cubit.state.addressDeletionStatus, RequestStatus.failure);
    repository.failsDeletion = false;
    await cubit.deleteAddress(address);
    expect(cubit.state.step, ChequeBookStep.delivery);
  });

  test('add-address cancellation changes nothing; save selects the server-returned address', () async {
    final cubit = create(TestChequeBookRepository());
    await selectBook(cubit);
    final before = cubit.state;
    await cubit.applyAddressResult(null);
    expect(cubit.state, before);
    await cubit.applyAddressResult(
      const DeliveryAddress(
        id: 'local',
        title: 'محل کار',
        detail: 'نشانی جدید',
        postalCode: '1234567890',
      ),
    );
    expect(cubit.state.address!.id, 'saved-address');
    expect(cubit.state.canContinue, isTrue);
    await cubit.deleteAddress(cubit.state.address!);
    expect(cubit.state.address, isNull);
    expect(cubit.state.canContinue, isFalse);
    expect(cubit.state.residency!.residences, hasLength(1));
  });

  test('quote failures retain delivery; failed submission retries exact confirmed payload and key', () async {
    final repository = TestChequeBookRepository()..failsQuote = true;
    final cubit = create(repository);
    await selectBook(cubit);
    cubit.selectAddress(cubit.state.deliveryAddresses.first);
    await cubit.continueFlow();
    expect(cubit.state.step, ChequeBookStep.delivery);
    expect(cubit.state.quoteStatus, RequestStatus.failure);
    repository.failsQuote = false;
    await cubit.continueFlow();
    repository.failsSubmission = true;
    await cubit.continueFlow();
    expect(cubit.state.submissionStatus, RequestStatus.failure);
    repository.failsSubmission = false;
    await cubit.continueFlow();
    expect(repository.requests[0], repository.requests[1]);
    expect(cubit.state.canContinue, isFalse);
  });

  for (final succeeds in [true, false]) {
    for (final selectsLeafCount in [false, true]) {
      test(
        'late address save ($succeeds) preserves new selection eligibility ($selectsLeafCount)',
        () async {
          final pending = Completer<Result<DeliveryAddress>>();
          final repository = TestChequeBookRepository()
            ..pendingAddressSave = pending;
          final cubit = create(repository);
          await selectBook(cubit);
          final address = cubit.state.deliveryAddresses.first;
          final saving = cubit.applyAddressResult(address);
          cubit.requestBack();
          cubit.selectDeposit(cubit.state.catalog!.deposits.last);
          if (selectsLeafCount) {
            cubit.selectLeafCount(25);
          }
          final before = cubit.state;
          pending.complete(
            succeeds ? Success(address) : const Err(DataFailure('save.failed')),
          );
          await saving;
          expect(cubit.state.step, before.step);
          expect(cubit.state.deposit, before.deposit);
          expect(cubit.state.leafCount, before.leafCount);
          expect(cubit.state.canContinue, selectsLeafCount);
          expect(cubit.state.isEditable, before.isEditable);
          expect(cubit.state.address, before.address);
          expect(
            cubit.state.addressSaveStatus,
            succeeds ? RequestStatus.success : RequestStatus.failure,
          );
        },
      );
    }
  }

  test('insufficient wallet disables final submission', () async {
    final cubit = create(TestChequeBookRepository()..walletBalanceRial = 100);
    await selectBook(cubit);
    cubit.selectAddress(cubit.state.deliveryAddresses.first);
    await cubit.continueFlow();
    expect(cubit.state.step, ChequeBookStep.confirmation);
    expect(cubit.state.isWalletSufficient, isFalse);
    expect(cubit.state.canContinue, isFalse);
  });

  test(
    'back invalidates an older residency check and permits a new selection',
    () async {
      final pending = Completer<Result<ChequeBookResidency>>();
      final repository = TestChequeBookRepository()..pendingResidency = pending;
      final cubit = create(repository);
      await cubit.fetchCatalog();
      cubit.selectDeposit(cubit.state.catalog!.deposits.first);
      cubit.selectLeafCount(10);
      final old = cubit.continueFlow();
      cubit.requestBack();
      cubit.selectDeposit(cubit.state.catalog!.deposits.last);
      cubit.selectLeafCount(25);
      repository.pendingResidency = null;
      await cubit.continueFlow();
      final current = cubit.state;
      pending.complete(
        Success(
          ChequeBookResidency(
            token: 'old',
            residences: bookResidences([false]),
          ),
        ),
      );
      await old;
      expect(cubit.state, current);
      expect(cubit.state.residency!.token, 'residency-deposit-2');
    },
  );

  test(
    'back invalidates pending quote; later response cannot reopen confirmation',
    () async {
      final pending = Completer<Result<ChequeBookQuote>>();
      final cubit = create(TestChequeBookRepository()..pendingQuote = pending);
      await selectBook(cubit);
      cubit.selectAddress(cubit.state.deliveryAddresses.first);
      final quote = cubit.continueFlow();
      cubit.requestBack();
      expect(cubit.state.step, ChequeBookStep.selection);
      pending.complete(
        Success(
          ChequeBookQuote(
            token: 'old',
            issueFeeRial: 1,
            deliveryFeeRial: 1,
            walletBalanceRial: 10,
            expiresAt: DateTime.now().toUtc(),
          ),
        ),
      );
      await quote;
      expect(cubit.state.step, ChequeBookStep.selection);
    },
  );

  test(
    'catalog exceptions map to existing typed failure and recover',
    () async {
      final repository = TestChequeBookRepository()..throwsCatalog = true;
      final cubit = create(repository);
      await cubit.fetchCatalog();
      expect(cubit.state.catalogFailure, const UnexpectedFailure());
      repository.throwsCatalog = false;
      await cubit.fetchCatalog();
      expect(cubit.state.catalogStatus, RequestStatus.success);
    },
  );

  test('first-step exit confirmation and repeated unavailable effects remain reliable', () async {
    final cubit = create(TestChequeBookRepository());
    await cubit.fetchCatalog();
    cubit.selectDeposit(cubit.state.catalog!.deposits.first);
    cubit.requestBack();
    expect(cubit.state.effect, ChequeBookEffect.confirmExit);
    cubit.applyExitConfirmation(null);
    expect(cubit.state.effect, isNull);
    cubit.requestAssistant();
    cubit.applyExitConfirmation(true);
    expect(cubit.state.effect, ChequeBookEffect.assistant);
    cubit.requestUnavailableContent();
    final effectId = cubit.state.effectId;
    cubit.requestUnavailableContent();
    expect(cubit.state.effectId, effectId + 1);
  });
}
