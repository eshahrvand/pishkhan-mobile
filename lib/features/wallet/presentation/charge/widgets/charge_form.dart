import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/charge_cubit.dart';
import '../../shared/wallet_balance_summary.dart';
import '../../shared/wallet_amount_field.dart';
import '../../shared/wallet_otp_field.dart';

class WalletChargeForm extends StatelessWidget {
  const WalletChargeForm({super.key, required this.state});
  final WalletChargeState state;
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
          WalletAmountField(
            label: S.current.walletChargeAmount,
            value: state.amount,
            amountToman: state.amountToman,
            isError: state.isAmountError,
            enabled:
                state.wallet != null &&
                state.otpStatus != RequestStatus.loading &&
                state.submissionStatus != RequestStatus.loading,
            onChanged: context.read<WalletChargeCubit>().updateAmount,
          ),
          const SizedBox(height: 24),
          WalletOtpField(
            value: state.otp,
            onChanged: context.read<WalletChargeCubit>().updateOtp,
            onRequest: context.read<WalletChargeCubit>().requestOtp,
            canRequest:
                state.canRequestOtp &&
                state.submissionStatus != RequestStatus.loading,
            isLoading: state.otpStatus == RequestStatus.loading,
            remainingSeconds: state.remainingSeconds,
            hasChallenge: state.challenge != null,
            codeLength: state.challenge?.codeLength ?? 4,
            enabled:
                state.challenge != null &&
                state.remainingSeconds > 0 &&
                state.otpStatus != RequestStatus.loading &&
                state.submissionStatus != RequestStatus.loading,
          ),
        ],
      ),
    );
  }
}
