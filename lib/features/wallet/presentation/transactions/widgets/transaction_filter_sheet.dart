import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../../../domain/entities/wallet.dart';
import '../cubit/transactions_cubit.dart';
import 'transaction_type_filter.dart';
import 'transaction_date_filter.dart';
import 'transaction_amount_filter.dart';

Future<bool?> showWalletTransactionFilter(BuildContext context) =>
    showAppServiceSheet<bool>(
      context,
      BlocProvider.value(
        value: context.read<WalletTransactionsCubit>(),
        child: const WalletTransactionFilterSheet(),
      ),
    );

class WalletTransactionFilterSheet extends StatelessWidget {
  const WalletTransactionFilterSheet({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletTransactionsCubit, WalletTransactionsState>(
      listenWhen: (previous, current) =>
          previous.transactionsStatus != current.transactionsStatus &&
          current.transactionsStatus == RequestStatus.loading,
      listener: (context, state) => Navigator.of(context).pop(true),
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBottomSheetHeader(
                title: switch (state.filterKind) {
                  WalletFilterKind.types => S.current.walletTransactionType,
                  WalletFilterKind.date => S.current.walletTransactionDate,
                  _ => S.current.walletAmountFilter,
                },
                showLeftAction: false,
                showRightIcon: false,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: switch (state.filterKind) {
                  WalletFilterKind.types => WalletTransactionTypeFilter(
                    state: state,
                  ),
                  WalletFilterKind.date => WalletTransactionDateFilter(
                    state: state,
                  ),
                  WalletFilterKind.amount => WalletTransactionAmountFilter(
                    state: state,
                  ),
                  null => const SizedBox.shrink(),
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: S.current.walletCancel,
                        variant: AppButtonVariant.secondaryGray,
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: S.current.walletApplyFilter,
                        isActive: state.canApply,
                        onPressed: context
                            .read<WalletTransactionsCubit>()
                            .applyFilter,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
