import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../cubit/transactions_cubit.dart';

Future<String?> showWalletJalaliDatePicker(BuildContext context) =>
    showAppServiceSheet<String>(
      context,
      BlocProvider.value(
        value: context.read<WalletTransactionsCubit>(),
        child: const WalletJalaliDatePicker(),
      ),
    );

/// Explicit Jalali input; uses the existing central parser, using the existing design-system fields.
class WalletJalaliDatePicker extends StatelessWidget {
  const WalletJalaliDatePicker({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletTransactionsCubit, WalletTransactionsState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBottomSheetHeader(
                title: S.current.walletDateSelection,
                showLeftAction: false,
                showRightIcon: false,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: CertificateInput(
                  label: S.current.walletDateSelection,
                  hint: 'YYYY/MM/DD',
                  value: state.datePickerInput,
                  latin: true,
                  maxLength: 10,
                  errorText: state.isDatePickerError
                      ? S.current.walletDateInvalid
                      : null,
                  onChanged: context
                      .read<WalletTransactionsCubit>()
                      .updateDatePickerInput,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: S.current.walletCancel,
                        variant: AppButtonVariant.secondaryGray,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: S.current.walletApplyFilter,
                        isActive: state.canConfirmDate,
                        onPressed: () =>
                            Navigator.of(context).pop(state.datePickerInput),
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
