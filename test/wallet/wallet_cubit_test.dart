import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/features/wallet/data/repositories/mock_wallet_repository.dart';
import 'package:pishkhan_mobile/features/wallet/domain/entities/wallet.dart';
import 'package:pishkhan_mobile/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:pishkhan_mobile/features/wallet/domain/usecases/wallet_usecase.dart';
import 'package:pishkhan_mobile/features/wallet/domain/wallet_rules.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/charge/cubit/charge_cubit.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/withdraw/cubit/withdraw_cubit.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/transfer/cubit/transfer_cubit.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/linked_deposit/cubit/linked_deposit_cubit.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/transactions/cubit/transactions_cubit.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/overview/cubit/overview_cubit.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:flutter/widgets.dart';

class ControlledWalletRepository extends MockWalletRepository {
  bool loseChargeResponse = false;
  bool throwCatalog = false;
  bool controlledInquiry = false;
  int chargeCalls = 0;
  final payments = <WalletPaymentRequest>[];
  final inquiries = <Completer<Result<WalletRecipient>>>[];
  @override
  Future<Result<WalletCatalog>> fetchCatalog() {
    if (throwCatalog) throw StateError('offline');
    return super.fetchCatalog();
  }

  @override
  Future<Result<WalletReceipt>> charge(WalletPaymentRequest request) async {
    chargeCalls++;
    payments.add(request);
    final result = await super.charge(request);
    if (loseChargeResponse && chargeCalls == 1) {
      throw StateError('response lost');
    }
    return result;
  }

  @override
  Future<Result<WalletRecipient>> inquireRecipient(String destination) {
    if (!controlledInquiry) return super.inquireRecipient(destination);
    final pending = Completer<Result<WalletRecipient>>();
    inquiries.add(pending);
    return pending.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => S.load(const Locale('fa')));
  late ControlledWalletRepository repository;
  setUp(() async {
    configureDependencies();
    await getIt.unregister<WalletRepository>();
    repository = ControlledWalletRepository();
    getIt.registerSingleton<WalletRepository>(repository);
  });
  tearDown(() => getIt.reset());
  test('charge share failures repeat independently of payment and success retains failure text', () async {
    final cubit = WalletChargeCubit();
    addTearDown(cubit.close);
    for (var attempt = 0; attempt < 2; attempt++) {
      cubit.requestShare();
      expect(cubit.state.shareStatus, RequestStatus.loading);
      cubit.consumeInteraction();
      cubit.applyShareResult(
        const Err(DataFailure('platform.share.unavailable')),
      );
      expect(cubit.state.shareStatus, RequestStatus.failure);
      expect(cubit.state.failure?.code, 'platform.share.unavailable');
      expect(cubit.state.message, 'اشتراک‌گذاری در این دستگاه در دسترس نیست.');
      expect(cubit.state.submissionStatus, RequestStatus.initial);
    }
    final message = cubit.state.message;
    cubit.requestShare();
    cubit.consumeInteraction();
    cubit.applyShareResult(const Success(null));
    expect(cubit.state.shareStatus, RequestStatus.success);
    expect(cubit.state.message, message);
    expect(cubit.state.effect, isNull);
  });
  test('withdraw share failures repeat independently of payment and success retains failure text', () async {
    final cubit = WalletWithdrawCubit();
    addTearDown(cubit.close);
    for (var attempt = 0; attempt < 2; attempt++) {
      cubit.requestShare();
      expect(cubit.state.shareStatus, RequestStatus.loading);
      cubit.consumeInteraction();
      cubit.applyShareResult(
        const Err(DataFailure('platform.share.unavailable')),
      );
      expect(cubit.state.shareStatus, RequestStatus.failure);
      expect(cubit.state.failure?.code, 'platform.share.unavailable');
      expect(cubit.state.message, 'اشتراک‌گذاری در این دستگاه در دسترس نیست.');
      expect(cubit.state.submissionStatus, RequestStatus.initial);
    }
    final message = cubit.state.message;
    cubit.requestShare();
    cubit.consumeInteraction();
    cubit.applyShareResult(const Success(null));
    expect(cubit.state.shareStatus, RequestStatus.success);
    expect(cubit.state.message, message);
    expect(cubit.state.effect, isNull);
  });
  test('transfer share failures repeat independently of payment and success retains failure text', () async {
    final cubit = WalletTransferCubit();
    addTearDown(cubit.close);
    for (var attempt = 0; attempt < 2; attempt++) {
      cubit.requestShare();
      expect(cubit.state.shareStatus, RequestStatus.loading);
      cubit.consumeInteraction();
      cubit.applyShareResult(
        const Err(DataFailure('platform.share.unavailable')),
      );
      expect(cubit.state.shareStatus, RequestStatus.failure);
      expect(cubit.state.failure?.code, 'platform.share.unavailable');
      expect(cubit.state.message, 'اشتراک‌گذاری در این دستگاه در دسترس نیست.');
      expect(cubit.state.submissionStatus, RequestStatus.initial);
    }
    final message = cubit.state.message;
    cubit.requestShare();
    cubit.consumeInteraction();
    cubit.applyShareResult(const Success(null));
    expect(cubit.state.shareStatus, RequestStatus.success);
    expect(cubit.state.message, message);
    expect(cubit.state.effect, isNull);
  });
  test('amount parsing accepts localized integer rial without accepting negatives or decimals', () {
    expect(WalletRules.amount('۱,۰۰۰,۰۰۰'), 1000000);
    expect(WalletRules.amount('١٠٠٠'), 1000);
    for (final value in ['', '-1', '12.5', '1a', '1000000000000000']) {
      expect(WalletRules.amount(value), isNull);
    }
    expect(WalletRules.validAmount(0), false);
  });
  test('charge requires valid amount and an active amount-bound OTP', () async {
    final cubit = WalletChargeCubit();
    addTearDown(cubit.close);
    await cubit.fetchWallet();
    expect(cubit.state.canSubmit, false);
    cubit.updateAmount('۱۰۰۰۰۰۰');
    expect(cubit.state.amountToman, 100000);
    expect(cubit.state.canRequestOtp, true);
    await cubit.requestOtp();
    cubit.updateOtp('۲۳۴۵');
    expect(cubit.state.canSubmit, true);
    cubit.updateAmount('200000');
    expect(cubit.state.challenge, isNull);
    expect(cubit.state.otp, isEmpty);
    expect(cubit.state.canSubmit, false);
    expect(cubit.state.canRequestOtp, true);
  });
  test('repeated same OTP failure emits independent transitions and success preserves recorded failure', () async {
    final cubit = WalletChargeCubit();
    addTearDown(cubit.close);
    await cubit.fetchWallet();
    cubit.updateAmount('100000');
    await cubit.requestOtp();
    cubit.updateOtp('1111');
    final statuses = <RequestStatus>[];
    final sub = cubit.stream.listen((s) => statuses.add(s.submissionStatus));
    addTearDown(sub.cancel);
    await cubit.submitPayment();
    final message = cubit.state.message;
    await cubit.submitPayment();
    cubit.updateOtp('2345');
    await cubit.submitPayment();
    await Future<void>.delayed(Duration.zero);
    expect(
      statuses.where((s) => s == RequestStatus.failure).length,
      greaterThanOrEqualTo(2),
    );
    expect(cubit.state.submissionStatus, RequestStatus.success);
    expect(cubit.state.message, message);
    expect(cubit.state.receipt!.balanceRial, 700000);
    expect(cubit.state.shareText, contains(cubit.state.receipt!.trackingId));
    expect(cubit.state.canSubmit, false);
    cubit.requestShare();
    expect(cubit.state.effect, isNotNull);
    cubit.consumeInteraction();
    cubit.requestShare();
    expect(cubit.state.effect, isNotNull);
  });
  test('lost charge response retries with the same identity and credits exactly once', () async {
    repository.loseChargeResponse = true;
    final cubit = WalletChargeCubit();
    addTearDown(cubit.close);
    await cubit.fetchWallet();
    cubit.updateAmount('100000');
    await cubit.requestOtp();
    cubit.updateOtp('2345');
    await cubit.submitPayment();
    expect(cubit.state.submissionStatus, RequestStatus.failure);
    await cubit.submitPayment();
    expect(cubit.state.receipt!.balanceRial, 700000);
    expect(
      repository.payments.first.idempotencyKey,
      repository.payments.last.idempotencyKey,
    );
  });
  test('countdown expiry disables payment and enables resend', () async {
    final cubit = WalletChargeCubit(
      initialState: WalletChargeState.initial(
        isAmountValid: true,
        isOtpValid: true,
        canSubmit: true,
        challenge: WalletOtpChallenge(
          id: 'expired',
          codeLength: 4,
          expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
        ),
      ),
    );
    addTearDown(cubit.close);
    cubit.updateCountdown();
    expect(cubit.state.remainingSeconds, 0);
    expect(cubit.state.canSubmit, false);
    expect(cubit.state.canRequestOtp, true);
  });
  test(
    'withdraw respects balance and debits only the linked deposit destination',
    () async {
      final cubit = WalletWithdrawCubit();
      addTearDown(cubit.close);
      await cubit.fetchWallet();
      cubit.updateAmount('700000');
      expect(cubit.state.isAmountError, true);
      expect(cubit.state.canRequestOtp, false);
      cubit.updateAmount('100000');
      await cubit.requestOtp();
      cubit.updateOtp('2345');
      await cubit.submitPayment();
      expect(cubit.state.receipt!.balanceRial, 500000);
      expect(
        cubit.state.receipt!.destination,
        cubit.state.wallet!.linkedDeposit.number,
      );
    },
  );
  test(
    'recipient response loses to a later edit before the debounce fires',
    () async {
      repository.controlledInquiry = true;
      final cubit = WalletTransferCubit();
      addTearDown(cubit.close);
      await cubit.fetchWallet();
      cubit.updateDestination('09126024179');
      final pending = cubit.inquireRecipient();
      cubit.updateDestination('09');
      repository.inquiries.first.complete(
        const Success(WalletRecipient(id: 'old', name: 'old owner')),
      );
      await pending;
      expect(cubit.state.recipient, isNull);
      expect(cubit.state.canSubmit, false);
    },
  );
  test('transfer resolves an actual demo owner and updates ledger', () async {
    final cubit = WalletTransferCubit();
    addTearDown(cubit.close);
    await cubit.fetchWallet();
    cubit.updateDestination('09126024179');
    await cubit.inquireRecipient();
    cubit.updateAmount('200000');
    expect(cubit.state.canSubmit, true);
    await cubit.submitTransfer();
    expect(cubit.state.receipt!.balanceRial, 400000);
    expect(cubit.state.receipt!.destination, '09126024179');
    expect(cubit.state.canSubmit, false);
  });
  test('unknown and self recipients never acquire an owner', () async {
    final cubit = WalletTransferCubit();
    addTearDown(cubit.close);
    await cubit.fetchWallet();
    cubit.updateDestination('09121234567');
    await cubit.inquireRecipient();
    expect(cubit.state.recipient, isNull);
    expect(cubit.state.recipientStatus, RequestStatus.failure);
    cubit.updateDestination('09129999999');
    await cubit.inquireRecipient();
    expect(cubit.state.recipient, isNull);
  });
  test(
    'linked deposit excludes the current one and requires acceptance',
    () async {
      final cubit = WalletLinkedDepositCubit();
      addTearDown(cubit.close);
      await cubit.fetchCatalog();
      expect(
        cubit.state.destinations,
        isNot(contains(cubit.state.catalog!.wallet.linkedDeposit)),
      );
      cubit.selectDeposit(cubit.state.destinations.first);
      expect(cubit.state.canSubmit, false);
      cubit.updateTermsAcceptance(true);
      expect(cubit.state.canSubmit, true);
      await cubit.submitChange();
      final overview = WalletOverviewCubit();
      addTearDown(overview.close);
      await overview.fetchWallet();
      expect(overview.state.wallet!.linkedDeposit, cubit.state.deposit);
    },
  );
  test(
    'transaction defaults select nothing and dismissal discards draft',
    () async {
      final cubit = WalletTransactionsCubit();
      addTearDown(cubit.close);
      await cubit.fetchTransactions();
      final count = cubit.state.transactions.length;
      expect(cubit.state.filter.types, isEmpty);
      expect(cubit.state.filter.period, isNull);
      expect(cubit.state.filter.minRial, isNull);
      cubit.openFilter(WalletFilterKind.types);
      expect(cubit.state.draftTypes, isEmpty);
      cubit.toggleType(WalletTransactionType.charge);
      cubit.applyFilterDismissal(null);
      expect(cubit.state.filter.types, isEmpty);
      expect(cubit.state.transactions.length, count);
      cubit.openFilter(WalletFilterKind.types);
      expect(cubit.state.draftTypes, isEmpty);
    },
  );
  test(
    'type, date and amount filters compose and clear independently',
    () async {
      final cubit = WalletTransactionsCubit();
      addTearDown(cubit.close);
      await cubit.fetchTransactions();
      cubit.openFilter(WalletFilterKind.types);
      cubit.toggleType(WalletTransactionType.charge);
      await cubit.applyFilter();
      expect(
        cubit.state.transactions.every(
          (t) => t.type == WalletTransactionType.charge,
        ),
        true,
      );
      cubit.openFilter(WalletFilterKind.amount);
      cubit.updateMin('100000');
      cubit.updateMax('500000');
      await cubit.applyFilter();
      expect(
        cubit.state.transactions.every((t) => t.amountRial <= 500000),
        true,
      );
      cubit.openFilter(WalletFilterKind.date);
      cubit.selectPeriod(WalletDatePeriod.today);
      await cubit.applyFilter();
      expect(cubit.state.transactions.length, 1);
      await cubit.clearDate();
      expect(cubit.state.filter.minRial, 100000);
      expect(cubit.state.filter.types, {WalletTransactionType.charge});
    },
  );
  test('custom date and amount ranges reject inverted intervals', () async {
    final cubit = WalletTransactionsCubit();
    addTearDown(cubit.close);
    cubit.openFilter(WalletFilterKind.date);
    cubit.selectPeriod(WalletDatePeriod.custom);
    expect(cubit.state.canApply, false);
    cubit.selectFromDate(DateTime(2026, 11, 8));
    cubit.selectToDate(DateTime(2026, 11, 1));
    expect(cubit.state.canApply, false);
    cubit.selectToDate(DateTime(2026, 11, 9));
    expect(cubit.state.canApply, true);
    cubit.cancelFilter();
    cubit.openFilter(WalletFilterKind.amount);
    cubit.updateMin('200000');
    cubit.updateMax('100000');
    expect(cubit.state.canApply, false);
    cubit.updateMax('300000');
    expect(cubit.state.canApply, true);
  });
  test('resending invalidates the earlier demo challenge', () async {
    final first = (await repository.requestOtp(
      WalletTransactionType.charge,
      100000,
    ) as Success<WalletOtpChallenge>).data;
    await repository.requestOtp(WalletTransactionType.charge, 100000);
    final result = await repository.charge(
      WalletPaymentRequest(
        amountRial: 100000,
        challengeId: first.id,
        otp: '2345',
        idempotencyKey: 'old-challenge',
      ),
    );
    expect(result, isA<Err<WalletReceipt>>());
  });
  test('repository binds OTP to both operation and amount', () async {
    final challenge = (await repository.requestOtp(
      WalletTransactionType.charge,
      100000,
    ) as Success<WalletOtpChallenge>).data;
    final request = WalletPaymentRequest(
      amountRial: 100000,
      challengeId: challenge.id,
      otp: '2345',
      idempotencyKey: 'bound',
    );
    expect(await repository.withdraw(request), isA<Err<WalletReceipt>>());
    expect(
      await repository.charge(
        WalletPaymentRequest(
          amountRial: 200000,
          challengeId: challenge.id,
          otp: '2345',
          idempotencyKey: 'other',
        ),
      ),
      isA<Err<WalletReceipt>>(),
    );
  });
  test(
    'UseCase maps thrown exceptions into a failure and fetching can retry',
    () async {
      repository.throwCatalog = true;
      final cubit = WalletOverviewCubit();
      addTearDown(cubit.close);
      await cubit.fetchWallet();
      expect(cubit.state.failure, isA<UnexpectedFailure>());
      repository.throwCatalog = false;
      await cubit.fetchWallet();
      expect(cubit.state.walletStatus, RequestStatus.success);
      expect(cubit.state.message, isNotNull);
      expect(
        getIt<FetchWalletCatalogUseCase>(),
        isA<FetchWalletCatalogUseCase>(),
      );
    },
  );
  test(
    'Jalali date input validates leap days and normalizes calendar bounds',
    () async {
      final cubit = WalletTransactionsCubit();
      addTearDown(cubit.close);
      cubit.openFilter(WalletFilterKind.date);
      cubit.selectPeriod(WalletDatePeriod.custom);
      cubit.openFromDatePicker();
      cubit.updateDatePickerInput('1403/12/30');
      expect(cubit.state.canConfirmDate, true);
      cubit.applyDatePickerResult(cubit.state.datePickerInput);
      expect(cubit.state.draftFrom, DateTime(2025, 3, 20));
      expect(cubit.state.draftFrom!.hour, 0);
      cubit.openToDatePicker();
      cubit.updateDatePickerInput('1404/12/30');
      expect(cubit.state.canConfirmDate, false);
      cubit.applyDatePickerResult(null);
      expect(cubit.state.draftTo, isNull);
      expect(cubit.state.draftFrom, DateTime(2025, 3, 20));
    },
  );
}
