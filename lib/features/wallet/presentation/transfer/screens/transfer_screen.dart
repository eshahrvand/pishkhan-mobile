import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/transfer_cubit.dart';
import '../widgets/transfer_form.dart';
import '../../shared/wallet_scaffold.dart';
import '../../shared/wallet_receipt_card.dart';
import '../../shared/wallet_platform_effects.dart';

class WalletTransferScreen extends StatelessWidget {
  const WalletTransferScreen({super.key});
  void _showFailure(BuildContext context, WalletTransferState state) {
    avpSnackBar(
      context: context,
      type: AvpSnackBarType.error,
      message: state.message!,
    );
  }

  Future<void> _share(BuildContext context, WalletTransferState state) async {
    context.read<WalletTransferCubit>().consumeInteraction();
    await shareWalletReceipt(context, state.shareText!);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WalletTransferCubit()..fetchWallet(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<WalletTransferCubit, WalletTransferState>(
            listenWhen: (previous, current) =>
                previous.walletStatus != current.walletStatus &&
                current.walletStatus == RequestStatus.failure,
            listener: _showFailure,
          ),
          BlocListener<WalletTransferCubit, WalletTransferState>(
            listenWhen: (previous, current) =>
                previous.submissionStatus != current.submissionStatus &&
                current.submissionStatus == RequestStatus.failure,
            listener: _showFailure,
          ),
          BlocListener<WalletTransferCubit, WalletTransferState>(
            listenWhen: (previous, current) =>
                previous.recipientStatus != current.recipientStatus &&
                current.recipientStatus == RequestStatus.failure,
            listener: _showFailure,
          ),

          BlocListener<WalletTransferCubit, WalletTransferState>(
            listenWhen: (previous, current) =>
                previous.effect != current.effect && current.effect != null,
            listener: _share,
          ),
        ],
        child: BlocBuilder<WalletTransferCubit, WalletTransferState>(
          builder: (context, state) {
            return WalletScaffold(
              title: state.receipt != null
                  ? S.current.walletReceiptTitle
                  : S.current.walletTransferTitle,
              busy: state.submissionStatus == RequestStatus.loading,
              showAssistant: state.receipt == null,
              showClose: state.receipt != null,
              footer: state.receipt != null
                  ? AppButton(
                      label: S.current.walletShareReceipt,
                      size: AppButtonSize.lg,
                      onPressed: context
                          .read<WalletTransferCubit>()
                          .requestShare,
                    )
                  : AppButton(
                      label: S.current.walletConfirmTransfer,
                      size: AppButtonSize.lg,
                      isLoading:
                          state.submissionStatus == RequestStatus.loading,
                      isActive:
                          state.canSubmit &&
                          state.recipientStatus != RequestStatus.loading,
                      onPressed: context
                          .read<WalletTransferCubit>()
                          .submitTransfer,
                    ),
              child: state.receipt != null
                  ? WalletReceiptCard(receipt: state.receipt!)
                  : switch (state.walletStatus) {
                      RequestStatus.initial || RequestStatus.loading =>
                        const Center(child: CircularProgressIndicator()),
                      RequestStatus.failure => Center(
                        child: AppButton(
                          label: S.current.dashboardRetry,
                          onPressed: context
                              .read<WalletTransferCubit>()
                              .fetchWallet,
                        ),
                      ),
                      RequestStatus.success => WalletTransferForm(state: state),
                    },
            );
          },
        ),
      ),
    );
  }
}
