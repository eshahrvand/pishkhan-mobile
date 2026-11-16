import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_transaction_card.dart';

import '../../../domain/entities/wallet.dart';
import '../cubit/transactions_cubit.dart';
import '../../shared/wallet_labels.dart';

class WalletTransactionList extends StatelessWidget {
  const WalletTransactionList({super.key, required this.state});
  final WalletTransactionsState state;
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: context.read<WalletTransactionsCubit>().fetchTransactions,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (state.transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Text(
                S.current.walletEmptyTransactions,
                textAlign: TextAlign.center,
              ),
            ),
          for (final transaction in state.transactions)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppTransactionCard(
                type: switch (transaction.type) {
                  WalletTransactionType.charge => AppTransactionType.charge,
                  WalletTransactionType.withdraw =>
                    AppTransactionType.discharge,
                  WalletTransactionType.transfer => AppTransactionType.transfer,
                  WalletTransactionType.shopping => AppTransactionType.shopping,
                },
                title: walletTypeLabel(transaction.type),
                amount: CurrencyFormatter.format(transaction.amountRial),
                date: walletDateLabel(transaction.createdAt),
              ),
            ),
        ],
      ),
    );
  }
}
