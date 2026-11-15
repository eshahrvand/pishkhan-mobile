import 'dart:async';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/flow/service_registry.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/wallet/data/repositories/mock_wallet_repository.dart';
import 'package:pishkhan_mobile/features/wallet/domain/entities/wallet.dart';
import 'package:pishkhan_mobile/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/charge/screens/charge_screen.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/withdraw/screens/withdraw_screen.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/transfer/screens/transfer_screen.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/linked_deposit/screens/linked_deposit_screen.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/overview/screens/overview_screen.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/transactions/screens/transactions_screen.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/shared/wallet_scaffold.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/charge/cubit/charge_cubit.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/charge/widgets/charge_form.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/withdraw/cubit/withdraw_cubit.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/withdraw/widgets/withdraw_form.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/transfer/cubit/transfer_cubit.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/transfer/widgets/transfer_form.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/linked_deposit/cubit/linked_deposit_cubit.dart';
import 'package:pishkhan_mobile/features/wallet/presentation/linked_deposit/widgets/linked_deposit_form.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/shared/widgets/flow_exit_sheet.dart';

import 'wallet_test_support.dart';

class DelayedCatalogRepository extends MockWalletRepository {
  final pending = Completer<Result<WalletCatalog>>();
  @override
  Future<Result<WalletCatalog>> fetchCatalog() => pending.future;
  Future<void> finish() async => pending.complete(await super.fetchCatalog());
}

class DelayedTransactionsRepository extends MockWalletRepository {
  final pending = Completer<Result<List<WalletReceipt>>>();
  @override
  Future<Result<List<WalletReceipt>>> fetchTransactions(
    WalletTransactionFilter filter,
  ) => pending.future;
  void finish() => pending.complete(const Success([]));
}

class DelayedRecipientRepository extends MockWalletRepository {
  final pending = Completer<Result<WalletRecipient>>();
  @override
  Future<Result<WalletRecipient>> inquireRecipient(String destination) =>
      pending.future;
}

class DelayedOtpRepository extends MockWalletRepository {
  final pending = Completer<Result<WalletOtpChallenge>>();
  @override
  Future<Result<WalletOtpChallenge>> requestOtp(
    WalletTransactionType type,
    int amountRial,
  ) => pending.future;
}

class DelayedSubmissionRepository extends MockWalletRepository {
  final payment = Completer<Result<WalletReceipt>>();
  final deposit = Completer<Result<WalletSummary>>();
  @override
  Future<Result<WalletReceipt>> withdraw(WalletPaymentRequest request) =>
      payment.future;
  @override
  Future<Result<WalletReceipt>> transfer(WalletTransferRequest request) =>
      payment.future;
  @override
  Future<Result<WalletSummary>> changeLinkedDeposit(
    WalletDeposit target,
    String key,
  ) => deposit.future;
}

void main() {
  setUpAll(loadWalletFonts);
  setUp(configureDependencies);
  tearDown(() => getIt.reset());

  for (final charge in [true, false]) {
    testWidgets(
      '${charge ? 'charge' : 'withdraw'} blocks Back while requesting OTP',
      (tester) async {
        final repository = DelayedOtpRepository();
        await getIt.unregister<WalletRepository>();
        getIt.registerSingleton<WalletRepository>(repository);
        await mountWallet(
          tester,
          charge ? const WalletChargeScreen() : const WalletWithdrawScreen(),
        );
        await tester.enterText(find.byType(TextField).first, '100000');
        await tester.pump();
        await tester.tap(find.text(S.current.walletRequestOtp));
        await tester.pump();
        expect(
          tester.widget<AppTopBar>(find.byType(AppTopBar)).isTrailingActive,
          isFalse,
        );
        await tester.binding.handlePopRoute();
        await tester.pump();
        expect(find.byType(FlowExitSheet), findsNothing);
        repository.pending.complete(
          Success(
            WalletOtpChallenge(
              id: 'pending',
              expiresAt: DateTime.now().add(const Duration(seconds: 60)),
              codeLength: 4,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester.widget<AppTopBar>(find.byType(AppTopBar)).isTrailingActive,
          isTrue,
        );
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  for (final operation in ['withdraw', 'transfer', 'linked deposit']) {
    testWidgets('$operation blocks Back until submission completes', (
      tester,
    ) async {
      final repository = DelayedSubmissionRepository();
      await getIt.unregister<WalletRepository>();
      getIt.registerSingleton<WalletRepository>(repository);
      switch (operation) {
        case 'withdraw':
          await mountWallet(tester, const WalletWithdrawScreen());
          final cubit = tester
              .element(find.byType(WalletWithdrawForm))
              .read<WalletWithdrawCubit>();
          cubit.updateAmount('100000');
          await cubit.requestOtp();
          cubit.updateOtp(MockWalletRepository.demoOtp);
        case 'transfer':
          await mountWallet(tester, const WalletTransferScreen());
          final cubit = tester
              .element(find.byType(WalletTransferForm))
              .read<WalletTransferCubit>();
          cubit.updateDestination('09126024179');
          await cubit.inquireRecipient();
          cubit.updateAmount('100000');
        case 'linked deposit':
          await mountWallet(tester, const WalletLinkedDepositScreen());
          final cubit = tester
              .element(find.byType(WalletLinkedDepositForm))
              .read<WalletLinkedDepositCubit>();
          cubit.selectDeposit(cubit.state.destinations.first);
          cubit.updateTermsAcceptance(true);
      }
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(
          operation == 'transfer'
              ? S.current.walletConfirmTransfer
              : S.current.walletConfirmPayment,
        ),
      );
      await tester.pump();
      expect(
        tester.widget<AppTopBar>(find.byType(AppTopBar)).isTrailingActive,
        isFalse,
      );
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(find.byType(FlowExitSheet), findsNothing);
      if (operation == 'linked deposit') {
        repository.deposit.complete(
          const Success(
            WalletSummary(
              id: 'wallet',
              balanceRial: 600000,
              linkedDeposit: WalletDeposit('d2', '10.12003456.2'),
            ),
          ),
        );
      } else {
        repository.payment.complete(
          Success(
            WalletReceipt(
              trackingId: 'pending',
              type: operation == 'withdraw'
                  ? WalletTransactionType.withdraw
                  : WalletTransactionType.transfer,
              amountRial: 100000,
              createdAt: DateTime.now(),
              source: 'wallet',
              destination: 'target',
              balanceRial: 500000,
            ),
          ),
        );
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  for (final operation in ['charge', 'withdraw', 'transfer']) {
    testWidgets(
      '$operation receipt Back returns home without reopening a form',
      (tester) async {
        await mountWallet(
          tester,
          Builder(
            builder: (context) => AppButton(
              label: 'wallet entry',
              onPressed: () =>
                  ServiceRegistry.openCardService(context, 'wallet-$operation'),
            ),
          ),
        );
        await tester.tap(find.text('wallet entry'));
        await tester.pumpAndSettle();
        switch (operation) {
          case 'charge':
            final cubit = tester
                .element(find.byType(WalletChargeForm))
                .read<WalletChargeCubit>();
            cubit.updateAmount('100000');
            await cubit.requestOtp();
            cubit.updateOtp(MockWalletRepository.demoOtp);
            await cubit.submitPayment();
          case 'withdraw':
            final cubit = tester
                .element(find.byType(WalletWithdrawForm))
                .read<WalletWithdrawCubit>();
            cubit.updateAmount('100000');
            await cubit.requestOtp();
            cubit.updateOtp(MockWalletRepository.demoOtp);
            await cubit.submitPayment();
          case 'transfer':
            final cubit = tester
                .element(find.byType(WalletTransferForm))
                .read<WalletTransferCubit>();
            cubit.updateDestination('09126024179');
            await cubit.inquireRecipient();
            cubit.updateAmount('100000');
            await cubit.submitTransfer();
        }
        await tester.pumpAndSettle();
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('wallet entry'), findsOneWidget);
        expect(find.byType(WalletScaffold), findsNothing);
        expect(find.byType(FlowExitSheet), findsNothing);
      },
    );
  }

  for (final (name, screen) in <(String, Widget)>[
    ('overview', const WalletOverviewScreen()),
    ('charge', const WalletChargeScreen()),
    ('withdraw', const WalletWithdrawScreen()),
    ('transfer', const WalletTransferScreen()),
    ('linked deposit', const WalletLinkedDepositScreen()),
  ]) {
    testWidgets('$name blocks both Back controls during catalog fetch', (
      tester,
    ) async {
      final repository = DelayedCatalogRepository();
      await getIt.unregister<WalletRepository>();
      getIt.registerSingleton<WalletRepository>(repository);
      await mountWallet(tester, screen, settle: false);
      expect(
        tester
            .widget<PopScope>(
              find.descendant(
                of: find.byType(WalletScaffold),
                matching: find.byWidgetPredicate(
                  (widget) => widget is PopScope,
                ),
              ),
            )
            .canPop,
        isFalse,
      );
      expect(
        tester.widget<AppTopBar>(find.byType(AppTopBar)).isTrailingActive,
        isFalse,
      );
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(find.byType(FlowExitSheet), findsNothing);
      await repository.finish();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('transactions blocks Back during its fetch', (tester) async {
    final repository = DelayedTransactionsRepository();
    await getIt.unregister<WalletRepository>();
    getIt.registerSingleton<WalletRepository>(repository);
    await mountWallet(tester, const WalletTransactionsScreen(), settle: false);
    expect(
      tester
          .widget<PopScope>(
            find.descendant(
              of: find.byType(WalletScaffold),
              matching: find.byWidgetPredicate((widget) => widget is PopScope),
            ),
          )
          .canPop,
      isFalse,
    );
    expect(
      tester.widget<AppTopBar>(find.byType(AppTopBar)).isTrailingActive,
      isFalse,
    );
    repository.finish();
    await tester.pumpAndSettle();
  });

  testWidgets('recipient inquiry blocks Back until its response', (
    tester,
  ) async {
    final repository = DelayedRecipientRepository();
    await getIt.unregister<WalletRepository>();
    getIt.registerSingleton<WalletRepository>(repository);
    await mountWallet(tester, const WalletTransferScreen());
    await tester.enterText(find.byType(TextField).first, '09126024179');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(
      tester.widget<AppTopBar>(find.byType(AppTopBar)).isTrailingActive,
      isFalse,
    );
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(FlowExitSheet), findsNothing);
    repository.pending.complete(
      const Success(WalletRecipient(id: '09126024179', name: 'مهسا جوانمرد')),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<AppTopBar>(find.byType(AppTopBar)).isTrailingActive,
      isTrue,
    );
  });

  for (final (id, screenType) in <(String, Type)>[
    ('wallet-charge', WalletChargeScreen),
    ('wallet-withdraw', WalletWithdrawScreen),
    ('wallet-transfer', WalletTransferScreen),
    ('wallet-deposit', WalletLinkedDepositScreen),
  ]) {
    for (final systemBack in [false, true]) {
      testWidgets(
        '$id ${systemBack ? 'system' : 'header'} Back confirms discard and preserves Stay',
        (tester) async {
          await mountWallet(
            tester,
            Builder(
              builder: (context) => AppButton(
                label: 'open wallet',
                onPressed: () => ServiceRegistry.openCardService(context, id),
              ),
            ),
          );
          await tester.tap(find.text('open wallet'));
          await tester.pumpAndSettle();
          if (id == 'wallet-deposit') {
            await tester.tap(find.byType(AppCheckbox));
          } else {
            await tester.enterText(find.byType(TextField).first, '123');
          }
          await tester.pumpAndSettle();
          Future<void> back() async {
            if (systemBack) {
              await tester.binding.handlePopRoute();
            } else {
              await tester.tap(find.byTooltip(S.current.backLabel));
            }
            await tester.pumpAndSettle();
          }

          await back();
          expect(find.byType(FlowExitSheet), findsOneWidget);
          await tester.tap(find.text(S.current.passwordStay));
          await tester.pumpAndSettle();
          expect(find.byType(screenType), findsOneWidget);
          if (id == 'wallet-deposit') {
            expect(
              tester.widget<AppCheckbox>(find.byType(AppCheckbox)).value,
              isTrue,
            );
          } else {
            expect(
              tester
                  .widget<AppTextField>(find.byType(AppTextField).first)
                  .value,
              '123',
            );
          }
          await back();
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(find.byType(FlowExitSheet), findsNothing);
          expect(find.byType(screenType), findsOneWidget);
          await back();
          await tester.tap(find.text(S.current.passwordExit));
          await tester.pumpAndSettle();
          expect(find.byType(screenType), findsNothing);
          expect(find.text('open wallet'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
