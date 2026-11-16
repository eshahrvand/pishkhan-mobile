import 'package:pishkhan_mobile/shared/widgets/flow_exit_sheet.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/core/flow/flow_navigation.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/withdraw_cubit.dart';
import '../widgets/withdraw_form.dart';
import '../../shared/wallet_scaffold.dart';
import '../../shared/wallet_receipt_card.dart';

import 'package:pishkhan_mobile/core/platform/platform_share.dart';

class WalletWithdrawScreen extends StatelessWidget {
  const WalletWithdrawScreen({super.key});
  void _showFailure(BuildContext context, WalletWithdrawState state) {
    avpSnackBar(
      context: context,
      type: AvpSnackBarType.error,
      message: state.message!,
    );
  }

  Future<void> _share(BuildContext context, WalletWithdrawState state) async {
    context.read<WalletWithdrawCubit>().consumeInteraction();
    final result = await PlatformShare.shareText(state.shareText!);
    if (context.mounted) {
      context.read<WalletWithdrawCubit>().applyShareResult(result);
    }
  }

  Future<void> _handleNavigation(
    BuildContext context,
    WalletWithdrawState state,
  ) async {
    switch (state.navigation) {
      case FlowNavigation.confirmExit:
        context.read<WalletWithdrawCubit>().consumeNavigation();
        final confirmed = await showFlowExitSheet(context);
        if (context.mounted) {
          context.read<WalletWithdrawCubit>().applyExitConfirmation(confirmed);
        }
      case FlowNavigation.back:
        // Rebuild PopScope with the authorized exit before performing the pop.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) NavigationActions.back(context);
        });
      case FlowNavigation.home:
        NavigationActions.returnHome(context);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WalletWithdrawCubit()..fetchWallet(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<WalletWithdrawCubit, WalletWithdrawState>(
            listenWhen: (previous, current) =>
                previous.navigation != current.navigation &&
                current.navigation != null,
            listener: _handleNavigation,
          ),
          BlocListener<WalletWithdrawCubit, WalletWithdrawState>(
            listenWhen: (previous, current) =>
                previous.shareStatus != current.shareStatus &&
                current.shareStatus == RequestStatus.failure,
            listener: _showFailure,
          ),
          BlocListener<WalletWithdrawCubit, WalletWithdrawState>(
            listenWhen: (previous, current) =>
                previous.walletStatus != current.walletStatus &&
                current.walletStatus == RequestStatus.failure,
            listener: _showFailure,
          ),
          BlocListener<WalletWithdrawCubit, WalletWithdrawState>(
            listenWhen: (previous, current) =>
                previous.submissionStatus != current.submissionStatus &&
                current.submissionStatus == RequestStatus.failure,
            listener: _showFailure,
          ),
          BlocListener<WalletWithdrawCubit, WalletWithdrawState>(
            listenWhen: (previous, current) =>
                previous.otpStatus != current.otpStatus &&
                current.otpStatus == RequestStatus.failure,
            listener: _showFailure,
          ),

          BlocListener<WalletWithdrawCubit, WalletWithdrawState>(
            listenWhen: (previous, current) =>
                previous.effect != current.effect && current.effect != null,
            listener: _share,
          ),
        ],
        child: BlocBuilder<WalletWithdrawCubit, WalletWithdrawState>(
          builder: (context, state) {
            return WalletScaffold(
              onBack: context.read<WalletWithdrawCubit>().requestBack,
              canPop: state.navigation == FlowNavigation.back,
              title: state.receipt != null
                  ? S.current.walletReceiptTitle
                  : S.current.walletWithdrawTitle,
              busy:
                  state.walletStatus == RequestStatus.loading ||
                  state.otpStatus == RequestStatus.loading ||
                  state.submissionStatus == RequestStatus.loading ||
                  state.shareStatus == RequestStatus.loading,
              showAssistant: state.receipt == null,
              showClose: state.receipt != null,
              footer: state.receipt != null
                  ? AppButton(
                      label: S.current.walletShareReceipt,
                      isLoading: state.shareStatus == RequestStatus.loading,
                      isActive: state.shareStatus != RequestStatus.loading,
                      size: AppButtonSize.lg,
                      onPressed: context
                          .read<WalletWithdrawCubit>()
                          .requestShare,
                    )
                  : AppButton(
                      label: S.current.walletConfirmPayment,
                      size: AppButtonSize.lg,
                      isLoading:
                          state.submissionStatus == RequestStatus.loading,
                      isActive:
                          state.canSubmit &&
                          state.otpStatus != RequestStatus.loading,
                      onPressed: context
                          .read<WalletWithdrawCubit>()
                          .submitPayment,
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
                              .read<WalletWithdrawCubit>()
                              .fetchWallet,
                        ),
                      ),
                      RequestStatus.success => WalletWithdrawForm(state: state),
                    },
            );
          },
        ),
      ),
    );
  }
}
