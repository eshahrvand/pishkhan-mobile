import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../cubit/transfer_cubit.dart';
import '../../shared/wallet_balance_summary.dart';
import '../../shared/wallet_amount_field.dart';

class WalletTransferForm extends StatelessWidget {
  const WalletTransferForm({super.key, required this.state});
  final WalletTransferState state;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.wallet != null)
            WalletBalanceSummary(balanceRial: state.wallet!.balanceRial),
          const SizedBox(height: 20),
          const AvpImage(
            image: '${AppConstants.baseImage}wallet_receipt_outer_divider.png',
            height: 1,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
          const SizedBox(height: 20),
          CertificateInput(
            label: S.current.walletDestination,
            hint: S.current.walletDestinationHint,
            value: state.destination,
            numeric: true,
            maxLength: 20,
            enabled:
                state.wallet != null &&
                state.submissionStatus != RequestStatus.loading,
            errorText: state.isDestinationError
                ? S.current.walletRecipientInvalid
                : null,
            onChanged: context.read<WalletTransferCubit>().updateDestination,
          ),
          if (state.recipientStatus == RequestStatus.loading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (state.recipientStatus == RequestStatus.failure)
            AppButton(
              label: S.current.walletInquiryRetry,
              variant: AppButtonVariant.text,
              onPressed: context.read<WalletTransferCubit>().inquireRecipient,
            ),
          if (state.recipient != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      S.current.walletRecipientName,
                      style: certificateLabelStyle(context),
                    ),
                    const Spacer(),
                    Text(
                      state.recipient!.name,
                      style: certificateValueStyle(context),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          WalletAmountField(
            label: S.current.walletTransferAmount,
            value: state.amount,
            amountToman: state.amountToman,
            isError: state.isAmountError,
            enabled:
                state.wallet != null &&
                state.submissionStatus != RequestStatus.loading,
            onChanged: context.read<WalletTransferCubit>().updateAmount,
          ),
        ],
      ),
    );
  }
}
