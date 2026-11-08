import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/overview_cubit.dart';
import '../widgets/overview_content.dart';
import '../../shared/wallet_scaffold.dart';

class WalletOverviewScreen extends StatelessWidget {
  const WalletOverviewScreen({super.key});
  void _showFailure(BuildContext context, WalletOverviewState state) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(state.message!)));
  }

  Future<void> _openFlow(
    BuildContext context,
    WalletOverviewState state,
  ) async {
    context.read<WalletOverviewCubit>().consumeNavigation();
    final result = await context.push<Object?>(switch (state.destination!) {
      WalletDestination.charge => AppRoutes.walletCharge,
      WalletDestination.withdraw => AppRoutes.walletWithdraw,
      WalletDestination.transfer => AppRoutes.walletTransfer,
      WalletDestination.linkedDeposit => AppRoutes.walletLinkedDeposit,
      WalletDestination.transactions => AppRoutes.walletTransactions,
    });
    if (context.mounted) {
      await context.read<WalletOverviewCubit>().applyFlowReturn(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WalletOverviewCubit()..fetchWallet(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<WalletOverviewCubit, WalletOverviewState>(
            listenWhen: (previous, current) =>
                previous.walletStatus != current.walletStatus &&
                current.walletStatus == RequestStatus.failure,
            listener: _showFailure,
          ),
          BlocListener<WalletOverviewCubit, WalletOverviewState>(
            listenWhen: (previous, current) =>
                previous.destination != current.destination &&
                current.destination != null,
            listener: _openFlow,
          ),
        ],
        child: BlocBuilder<WalletOverviewCubit, WalletOverviewState>(
          builder: (context, state) {
            return WalletScaffold(
              title: S.current.walletTitle,
              child: switch (state.walletStatus) {
                RequestStatus.initial || RequestStatus.loading => const Center(
                  child: CircularProgressIndicator(),
                ),
                RequestStatus.failure => Center(
                  child: AppButton(
                    label: S.current.dashboardRetry,
                    onPressed: context.read<WalletOverviewCubit>().fetchWallet,
                  ),
                ),
                RequestStatus.success => WalletOverviewContent(state: state),
              },
            );
          },
        ),
      ),
    );
  }
}
