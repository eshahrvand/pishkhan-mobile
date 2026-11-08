import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/transactions_cubit.dart';

class WalletTransactionFilters extends StatelessWidget {
  const WalletTransactionFilters({super.key, required this.state});
  final WalletTransactionsState state;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                AppChips(
                  label: S.current.walletTransactionType,
                  selected: state.filter.types.isNotEmpty,
                  icon: AvpImage(
                    image: state.filter.types.isEmpty
                        ? '${AppConstants.baseImage}deposit_list_chevron.svg'
                        : '${AppConstants.baseImage}deposit_list_clear.svg',
                    width: 20,
                    height: 20,
                  ),
                  onPressed: state.transactionsStatus != RequestStatus.loading
                      ? context.read<WalletTransactionsCubit>().requestTypes
                      : null,
                ),
                const SizedBox(width: 12),
                AppChips(
                  label: S.current.walletDateFilter,
                  selected: state.filter.period != null,
                  icon: AvpImage(
                    image: state.filter.period == null
                        ? '${AppConstants.baseImage}deposit_list_chevron.svg'
                        : '${AppConstants.baseImage}deposit_list_clear.svg',
                    width: 20,
                    height: 20,
                  ),
                  onPressed: state.transactionsStatus != RequestStatus.loading
                      ? context.read<WalletTransactionsCubit>().requestDate
                      : null,
                ),
                const SizedBox(width: 12),
                AppChips(
                  label: S.current.walletAmountFilter,
                  selected:
                      state.filter.minRial != null ||
                      state.filter.maxRial != null,
                  icon: AvpImage(
                    image:
                        state.filter.minRial == null &&
                            state.filter.maxRial == null
                        ? '${AppConstants.baseImage}deposit_list_chevron.svg'
                        : '${AppConstants.baseImage}deposit_list_clear.svg',
                    width: 20,
                    height: 20,
                  ),
                  onPressed: state.transactionsStatus != RequestStatus.loading
                      ? context.read<WalletTransactionsCubit>().requestAmount
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const AvpImage(
            image: '${AppConstants.baseImage}wallet_receipt_outer_divider.png',
            height: 1,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
        ],
      ),
    );
  }
}
