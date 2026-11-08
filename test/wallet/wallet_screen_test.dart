import 'package:pishkhan_mobile/core/enums/request_status.dart';

import '../support/snackbar_test_support.dart';

import 'package:pishkhan_mobile/features/wallet/presentation/withdraw/cubit/withdraw_cubit.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/withdraw/widgets/withdraw_form.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/transfer/cubit/transfer_cubit.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/transfer/widgets/transfer_form.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/linked_deposit/widgets/linked_deposit_form.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/linked_deposit/cubit/linked_deposit_cubit.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/transactions/widgets/wallet_jalali_date_picker.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/transactions/widgets/wallet_filter_date_field.dart';

import 'dart:async';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/flow/service_registry.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/wallet/data/repositories/mock_wallet_repository.dart';
import 'package:pishkhan_mobile/features/wallet/domain/entities/wallet.dart';
import 'package:pishkhan_mobile/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/charge/cubit/charge_cubit.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/charge/screens/charge_screen.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/charge/widgets/charge_form.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/withdraw/screens/withdraw_screen.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/transfer/screens/transfer_screen.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/linked_deposit/screens/linked_deposit_screen.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/overview/screens/overview_screen.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/transactions/screens/transactions_screen.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/transactions/widgets/transaction_filter_sheet.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/transactions/widgets/transaction_filters.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/transactions/cubit/transactions_cubit.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/shared/wallet_receipt_card.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/shared/wallet_otp_field.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import 'wallet_test_support.dart';

class PendingWalletRepository extends MockWalletRepository {
  final pending = Completer<Result<WalletReceipt>>();
  int submissions = 0;
  @override
  Future<Result<WalletReceipt>> charge(WalletPaymentRequest request) {
    submissions++;
    return pending.future;
  }
}

Finder button(String label) =>
    find.byWidgetPredicate((w) => w is AppButton && w.label == label);
void main() {
  setUpAll(loadWalletFonts);
  setUp(configureDependencies);
  tearDown(() => getIt.reset());
  testWidgets('overview reuses wallet card and opens each operation', (
    tester,
  ) async {
    await mountWallet(tester, const WalletOverviewScreen());
    await captureWallet(tester, 'overview');
    expect(find.text(S.current.walletOperations), findsOneWidget);
    await tester.tap(find.text(S.current.walletCharge));
    await tester.pumpAndSettle();
    expect(find.byType(WalletChargeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'charge empty, filled, OTP and receipt states share and block duplicate submission',
    (tester) async {
      final shares = <String>[];
      var failShare = false;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('pishkhan/platform_share'),
        (call) async {
          if (failShare) throw PlatformException(code: 'unavailable');
          shares.add(call.arguments as String);
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('pishkhan/platform_share'),
          null,
        ),
      );
      await mountWallet(tester, const WalletChargeScreen());
      await captureWallet(tester, 'charge_empty');
      final cubit = tester
          .element(find.byType(WalletChargeForm))
          .read<WalletChargeCubit>();
      expect(
        tester
            .widget<AppButton>(button(S.current.walletConfirmPayment))
            .isActive,
        false,
      );
      await tester.enterText(find.byType(TextField).first, '1000000');
      await tester.pump();
      await tester.tap(button(S.current.walletRequestOtp));
      await tester.pumpAndSettle();
      expect(cubit.state.challenge, isNotNull);
      await captureWallet(tester, 'charge_otp');
      await tester.enterText(find.byType(TextField).last, '2345');
      await tester.pump();
      await captureWallet(tester, 'charge_filled');
      await tester.tap(button(S.current.walletConfirmPayment));
      await tester.pumpAndSettle();
      expect(find.byType(WalletReceiptCard), findsOneWidget);
      expect(find.byType(WalletOtpField), findsNothing);
      await captureWallet(tester, 'charge_receipt');
      await tester.tap(button(S.current.walletShareReceipt));
      await tester.pumpAndSettle();
      await tester.tap(button(S.current.walletShareReceipt));
      await tester.pumpAndSettle();
      expect(shares.length, 2);
      expect(shares.first, contains(cubit.state.receipt!.trackingId));
      failShare = true;
      for (var attempt = 0; attempt < 2; attempt++) {
        await tester.tap(button(S.current.walletShareReceipt));
        await tester.pumpAndSettle();
        expect(cubit.state.shareStatus, RequestStatus.failure);
        expect(cubit.state.submissionStatus, RequestStatus.success);
        expect(
          find.text('اشتراک‌گذاری در این دستگاه در دسترس نیست.'),
          findsOneWidget,
        );
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
      }
      failShare = false;
      await tester.tap(button(S.current.walletShareReceipt));
      await tester.pumpAndSettle();
      expect(cubit.state.shareStatus, RequestStatus.success);
      expect(cubit.state.message, 'اشتراک‌گذاری در این دستگاه در دسترس نیست.');
      expect(find.byType(AvpSnackBar), findsNothing);
      expect(shares, hasLength(3));

      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'linked-deposit success remains visible after returning to the entry route',
    (tester) async {
      await mountWallet(
        tester,
        Builder(
          builder: (context) => AppButton(
            label: 'open',
            onPressed: () =>
                ServiceRegistry.openCardService(context, 'wallet-deposit'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final cubit = tester
          .element(find.byType(WalletLinkedDepositForm))
          .read<WalletLinkedDepositCubit>();
      cubit.selectDeposit(cubit.state.destinations.first);
      cubit.updateTermsAcceptance(true);
      await tester.pumpAndSettle();
      expect(cubit.state.canSubmit, isTrue);
      expect(
        tester
            .widget<AppButton>(button(S.current.walletConfirmPayment))
            .isActive,
        isTrue,
      );
      await tester.tap(button(S.current.walletConfirmPayment));
      await tester.pumpAndSettle();
      expect(cubit.state.submissionStatus, RequestStatus.success);
      expect(find.byType(WalletLinkedDepositScreen), findsNothing);
      expect(find.text(S.current.walletDepositChanged), findsOneWidget);
      expect(
        tester.widget<AvpSnackBar>(find.byType(AvpSnackBar)).type,
        AvpSnackBarType.success,
      );
      await dismissAvpSnackBar(tester);
    },
  );
  testWidgets('pending payment disables editing, OTP and both back paths', (
    tester,
  ) async {
    await getIt.unregister<WalletRepository>();
    final repository = PendingWalletRepository();
    getIt.registerSingleton<WalletRepository>(repository);
    await mountWallet(tester, const WalletChargeScreen());
    final cubit = tester
        .element(find.byType(WalletChargeForm))
        .read<WalletChargeCubit>();
    cubit.updateAmount('100000');
    await cubit.requestOtp();
    cubit.updateOtp('2345');
    await tester.pump();
    await tester.tap(button(S.current.walletConfirmPayment));
    await tester.pump();
    expect(
      tester
          .widget<AppButton>(button(S.current.walletConfirmPayment))
          .isLoading,
      true,
    );
    await tester.tap(button(S.current.walletConfirmPayment));
    await tester.pump();
    expect(repository.submissions, 1);
    final fields = tester.widgetList<AppTextField>(find.byType(AppTextField));
    expect(fields.every((f) => !f.enabled), true);
    final pops = tester.widgetList<PopScope>(find.byType(PopScope));
    expect(pops.any((p) => !p.canPop), true);
    repository.pending.complete(
      Success(
        WalletReceipt(
          trackingId: 'DEMO-PENDING',
          type: WalletTransactionType.charge,
          amountRial: 100000,
          createdAt: DateTime.now(),
          source: 'deposit',
          destination: 'wallet',
          balanceRial: 700000,
        ),
      ),
    );
    await tester.pumpAndSettle();
  });
  testWidgets(
    'filters start unchecked, discard dismissal and apply a selected type',
    (tester) async {
      await mountWallet(tester, const WalletTransactionsScreen());
      await captureWallet(tester, 'transactions');
      await tester.tap(find.text(S.current.walletTransactionType));
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<AppCheckbox>(find.byType(AppCheckbox))
            .every((c) => c.value == false),
        true,
      );
      await captureWallet(tester, 'types_empty');
      await tester.tap(
        find.descendant(
          of: find.byType(WalletTransactionFilterSheet),
          matching: find.text(S.current.walletCharge),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(button(S.current.walletCancel));
      await tester.pumpAndSettle();
      final cubit = tester
          .element(find.byType(WalletTransactionFilters))
          .read<WalletTransactionsCubit>();
      expect(cubit.state.filter.types, isEmpty);
      await tester.tap(find.text(S.current.walletTransactionType));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(WalletTransactionFilterSheet),
          matching: find.text(S.current.walletCharge),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(button(S.current.walletApplyFilter));
      await tester.pumpAndSettle();
      expect(find.byType(WalletTransactionFilterSheet), findsNothing);
      expect(cubit.state.filter.types, {WalletTransactionType.charge});
      await captureWallet(tester, 'types_applied');
      await tester.tap(find.text(S.current.walletAmountFilter));
      await tester.pumpAndSettle();
      await captureWallet(tester, 'amount_empty');
      cubit.updateMin('100000');
      cubit.updateMax('1000000');
      await tester.pumpAndSettle();
      await captureWallet(tester, 'amount_filled');
      await tester.tap(button(S.current.walletCancel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.walletDateFilter));
      await tester.pumpAndSettle();
      cubit.selectPeriod(WalletDatePeriod.custom);
      await tester.pumpAndSettle();
      await captureWallet(tester, 'date_custom');
      await tester.tap(button(S.current.walletCancel));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'custom Jalali input returns a date and cancelling preserves the bound',
    (tester) async {
      await mountWallet(tester, const WalletTransactionsScreen());
      await tester.tap(find.text(S.current.walletDateFilter));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.walletCustomDate));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(WalletFilterDateField).first);
      await tester.pumpAndSettle();
      expect(find.byType(WalletJalaliDatePicker), findsOneWidget);
      await tester.enterText(
        find.descendant(
          of: find.byType(WalletJalaliDatePicker),
          matching: find.byType(TextField),
        ),
        '1403/12/30',
      );
      await tester.pump();
      await captureWallet(tester, 'jalali_date_input');
      await tester.tap(
        find.descendant(
          of: find.byType(WalletJalaliDatePicker),
          matching: button(S.current.walletApplyFilter),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(WalletJalaliDatePicker), findsNothing);
      final cubit = tester
          .element(find.byType(WalletTransactionFilters))
          .read<WalletTransactionsCubit>();
      expect(cubit.state.draftFrom, DateTime(2025, 3, 20));
      await tester.tap(find.byType(WalletFilterDateField).last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(WalletJalaliDatePicker),
          matching: find.byType(TextField),
        ),
        '1404/12/30',
      );
      await tester.pump();
      expect(
        tester
            .widget<AppButton>(
              find.descendant(
                of: find.byType(WalletJalaliDatePicker),
                matching: button(S.current.walletApplyFilter),
              ),
            )
            .isActive,
        false,
      );
      await tester.tap(
        find.descendant(
          of: find.byType(WalletJalaliDatePicker),
          matching: button(S.current.walletCancel),
        ),
      );
      await tester.pumpAndSettle();
      expect(cubit.state.draftTo, isNull);
      await tester.tap(button(S.current.walletCancel));
      await tester.pumpAndSettle();
      expect(find.byType(WalletTransactionFilterSheet), findsNothing);
    },
  );
  testWidgets('withdraw and transfer render their returned receipts', (
    tester,
  ) async {
    await mountWallet(tester, const WalletWithdrawScreen());
    final withdrawal = tester
        .element(find.byType(WalletWithdrawForm))
        .read<WalletWithdrawCubit>();
    withdrawal.updateAmount('100000');
    await withdrawal.requestOtp();
    withdrawal.updateOtp('2345');
    await tester.pump();
    await captureWallet(tester, 'withdraw_filled');
    await tester.tap(button(S.current.walletConfirmPayment));
    await tester.pumpAndSettle();
    expect(find.text(S.current.walletWithdrawSuccess), findsOneWidget);
    await captureWallet(tester, 'withdraw_receipt');
    await mountWallet(tester, const WalletTransferScreen());
    final transfer = tester
        .element(find.byType(WalletTransferForm))
        .read<WalletTransferCubit>();
    await tester.enterText(find.byType(TextField).first, '09126024179');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(transfer.state.recipient, isNotNull);
    await tester.enterText(find.byType(TextField).last, '200000');
    await tester.pump();
    await captureWallet(tester, 'transfer_filled');
    await tester.tap(button(S.current.walletConfirmTransfer));
    await tester.pumpAndSettle();
    expect(find.text(S.current.walletTransferSuccess), findsOneWidget);
    await captureWallet(tester, 'transfer_receipt');
    expect(tester.takeException(), isNull);
  });
  testWidgets('linked deposit selection and terms enable confirmation', (
    tester,
  ) async {
    await mountWallet(tester, const WalletLinkedDepositScreen());
    await tester.tap(find.byType(AppSelect<WalletDeposit>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10.12003456.2').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AppCheckbox));
    await tester.pumpAndSettle();
    final cubit = tester
        .element(find.byType(WalletLinkedDepositForm))
        .read<WalletLinkedDepositCubit>();
    expect(cubit.state.canSubmit, true);
    await captureWallet(tester, 'linked_deposit_filled');
    await tester.tap(button(S.current.walletTerms));
    await tester.pumpAndSettle();
    await captureWallet(tester, 'terms');
    expect(find.text(cubit.state.catalog!.terms), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final (name, screen) in <(String, Widget)>[
    ('withdraw', const WalletWithdrawScreen()),
    ('transfer', const WalletTransferScreen()),
    ('linked_deposit', const WalletLinkedDepositScreen()),
  ]) {
    testWidgets('$name follows Figma page layout', (tester) async {
      await mountWallet(tester, screen);
      await captureWallet(tester, name);
      expect(tester.takeException(), isNull);
    });
  }
  for (final locale in ['fa', 'en', 'ar']) {
    for (final (name, screen) in <(String, Widget)>[
      ('charge', const WalletChargeScreen()),
      ('linked_deposit', const WalletLinkedDepositScreen()),
      ('transactions', const WalletTransactionsScreen()),
    ]) {
      testWidgets('$name remains usable at 320px and 1.5 text in $locale', (
        tester,
      ) async {
        await mountWallet(
          tester,
          screen,
          size: const Size(320, 640),
          scale: 1.5,
          locale: locale,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
  for (final (id, screenType) in <(String, Type)>[
    ('wallet-info', WalletOverviewScreen),
    ('wallet-charge', WalletChargeScreen),
    ('wallet-withdraw', WalletWithdrawScreen),
    ('wallet-transfer', WalletTransferScreen),
    ('wallet-deposit', WalletLinkedDepositScreen),
    ('wallet-history', WalletTransactionsScreen),
  ]) {
    testWidgets('$id enters its central route', (tester) async {
      await mountWallet(
        tester,
        Builder(
          builder: (context) => AppButton(
            label: 'open',
            onPressed: () => ServiceRegistry.openCardService(context, id),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(screenType), findsOneWidget);
    });
  }
}
