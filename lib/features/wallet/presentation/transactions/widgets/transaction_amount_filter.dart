import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/transactions_cubit.dart';
import '../../shared/wallet_amount_field.dart';

class WalletTransactionAmountFilter extends StatelessWidget {
  const WalletTransactionAmountFilter({super.key, required this.state});
  final WalletTransactionsState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WalletAmountField(
          label: S.current.walletMinAmount,
          value: state.draftMin,
          amountToman: state.draftMinToman,
          onChanged: context.read<WalletTransactionsCubit>().updateMin,
        ),
        const SizedBox(height: 24),
        WalletAmountField(
          label: S.current.walletMaxAmount,
          value: state.draftMax,
          amountToman: state.draftMaxToman,
          onChanged: context.read<WalletTransactionsCubit>().updateMax,
        ),
        if (state.isAmountRangeError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(S.current.walletRangeInvalid),
          ),
      ],
    );
  }
}
