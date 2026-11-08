import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/transactions_cubit.dart';
import '../widgets/transaction_filters.dart';
import '../widgets/transaction_list.dart';
import '../widgets/transaction_filter_sheet.dart';
import '../../shared/wallet_scaffold.dart';

class WalletTransactionsScreen extends StatelessWidget {
  const WalletTransactionsScreen({super.key});
  void _showFailure(BuildContext context, WalletTransactionsState state) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(state.message!)));
  }

  Future<void> _openFilter(
    BuildContext context,
    WalletTransactionsState state,
  ) async {
    final applied = await showWalletTransactionFilter(context);
    if (context.mounted) {
      context.read<WalletTransactionsCubit>().applyFilterDismissal(applied);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WalletTransactionsCubit()..fetchTransactions(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<WalletTransactionsCubit, WalletTransactionsState>(
            listenWhen: (previous, current) =>
                previous.transactionsStatus != current.transactionsStatus &&
                current.transactionsStatus == RequestStatus.failure,
            listener: _showFailure,
          ),
          BlocListener<WalletTransactionsCubit, WalletTransactionsState>(
            listenWhen: (previous, current) =>
                previous.filterKind == null && current.filterKind != null,
            listener: _openFilter,
          ),
        ],
        child: BlocBuilder<WalletTransactionsCubit, WalletTransactionsState>(
          builder: (context, state) {
            return WalletScaffold(
              title: S.current.walletTransactionsTitle,
              child: Column(
                children: [
                  WalletTransactionFilters(state: state),
                  Expanded(
                    child: switch (state.transactionsStatus) {
                      RequestStatus.initial || RequestStatus.loading =>
                        const Center(child: CircularProgressIndicator()),
                      RequestStatus.failure => Center(
                        child: AppButton(
                          label: S.current.dashboardRetry,
                          onPressed: context
                              .read<WalletTransactionsCubit>()
                              .fetchTransactions,
                        ),
                      ),
                      RequestStatus.success => WalletTransactionList(
                        state: state,
                      ),
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
