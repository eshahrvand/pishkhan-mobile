import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/wallet.dart';
import '../cubit/transactions_cubit.dart';
import '../../shared/wallet_labels.dart';

class WalletTransactionTypeFilter extends StatelessWidget {
  const WalletTransactionTypeFilter({super.key, required this.state});
  final WalletTransactionsState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 56,
          child: Row(
            children: [
              AppCheckbox(
                value: state.draftTypes.isEmpty
                    ? false
                    : state.draftTypes.length ==
                          WalletTransactionType.values.length
                    ? true
                    : null,
                onChanged: (_) =>
                    context.read<WalletTransactionsCubit>().toggleAllTypes(),
              ),
              const SizedBox(width: 12),
              Text(S.current.walletSelectAll, style: AppTypography.bodyMedium),
            ],
          ),
        ),
        for (final type in WalletTransactionType.values)
          SizedBox(
            height: 56,
            child: InkWell(
              onTap: () =>
                  context.read<WalletTransactionsCubit>().toggleType(type),
              child: Row(
                children: [
                  AppCheckbox(
                    value: state.draftTypes.contains(type),
                    onChanged: (_) => context
                        .read<WalletTransactionsCubit>()
                        .toggleType(type),
                  ),
                  const SizedBox(width: 12),
                  Text(walletTypeLabel(type), style: AppTypography.bodyMedium),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
