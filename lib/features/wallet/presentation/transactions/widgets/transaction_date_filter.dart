import 'wallet_jalali_date_picker.dart';

import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/wallet.dart';
import '../cubit/transactions_cubit.dart';
import '../../shared/wallet_labels.dart';
import 'wallet_filter_date_field.dart';

class WalletTransactionDateFilter extends StatelessWidget {
  const WalletTransactionDateFilter({super.key, required this.state});
  final WalletTransactionsState state;
  Future<void> _openDatePicker(
    BuildContext context,
    WalletTransactionsState state,
  ) async {
    final input = await showWalletJalaliDatePicker(context);
    if (context.mounted) {
      context.read<WalletTransactionsCubit>().applyDatePickerResult(input);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletTransactionsCubit, WalletTransactionsState>(
      listenWhen: (previous, current) =>
          previous.datePickerTarget == null && current.datePickerTarget != null,
      listener: _openDatePicker,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final period in WalletDatePeriod.values)
            Semantics(
              checked: state.draftPeriod == period,
              inMutuallyExclusiveGroup: true,
              child: SizedBox(
                height: 56,
                child: InkWell(
                  onTap: () => context
                      .read<WalletTransactionsCubit>()
                      .selectPeriod(period),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: state.draftPeriod == period
                                ? context.colors.primary
                                : context.colors.border,
                          ),
                          color: state.draftPeriod == period
                              ? context.colors.primary
                              : context.colors.surface,
                        ),
                        child: state.draftPeriod == period
                            ? const AvpImage(
                                image:
                                    '${AppConstants.baseImage}cheque_cancel_check.svg',
                                width: 16,
                                height: 16,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        walletPeriodLabel(period),
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (state.draftPeriod == WalletDatePeriod.custom) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: WalletFilterDateField(
                    label: S.current.walletFromDate,
                    hint: S.current.walletStartDate,
                    value: state.draftFrom,
                    onPressed: context
                        .read<WalletTransactionsCubit>()
                        .openFromDatePicker,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: WalletFilterDateField(
                    label: S.current.walletToDate,
                    hint: S.current.walletEndDate,
                    value: state.draftTo,
                    onPressed: context
                        .read<WalletTransactionsCubit>()
                        .openToDatePicker,
                  ),
                ),
              ],
            ),
          ],
          if (state.isDateRangeError)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(S.current.walletRangeInvalid),
            ),
        ],
      ),
    );
  }
}
