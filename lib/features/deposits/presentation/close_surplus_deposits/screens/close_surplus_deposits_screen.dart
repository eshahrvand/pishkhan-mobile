import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/shared/widgets/flow_exit_dialog.dart';

import '../../deposit_list/widgets/deposit_ui.dart';
import '../cubit/close_surplus_deposits_cubit.dart';
import '../widgets/close_surplus_deposits_footer.dart';
import '../widgets/close_surplus_deposits_form.dart';
import '../widgets/surplus_deposits_result.dart';
import '../widgets/surplus_deposit_receipt_dialog.dart';

class CloseSurplusDepositsScreen extends StatelessWidget {
  const CloseSurplusDepositsScreen({
    super.key,
    this.initialDepositNumber,
    this.onAssistantPressed,
  });

  final String? initialDepositNumber;
  final VoidCallback? onAssistantPressed;

  Future<void> _handleEffect(
    BuildContext context,
    CloseSurplusDepositsState state,
  ) async {
    switch (state.effect) {
      case CloseSurplusDepositsEffect.confirmExit:
        final confirmed = await showFlowExitDialog(context);
        if (context.mounted) {
          context.read<CloseSurplusDepositsCubit>().applyExitConfirmation(
            confirmed,
          );
        }
      case CloseSurplusDepositsEffect.back:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) NavigationActions.back(context);
        });
      case CloseSurplusDepositsEffect.home:
        NavigationActions.returnHome(context);
      case CloseSurplusDepositsEffect.assistant:
        NavigationActions.returnHome(context);
        onAssistantPressed?.call();
      case CloseSurplusDepositsEffect.termsUnavailable:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.issuanceTermsUnavailable)),
        );
      case null:
        break;
    }
  }

  Future<void> _handleReceipt(
    BuildContext context,
    CloseSurplusDepositsState state,
  ) async {
    await showSurplusDepositReceiptDialog(context, state.receipt!);
    if (context.mounted) {
      context.read<CloseSurplusDepositsCubit>().applyReceiptDismissal();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CloseSurplusDepositsCubit(initialDepositNumber: initialDepositNumber)
            ..fetchPrimaryDeposits(),
      child: BlocListener<CloseSurplusDepositsCubit, CloseSurplusDepositsState>(
        listenWhen: (previous, current) =>
            previous.submissionStatus != current.submissionStatus &&
            current.submissionStatus == RequestStatus.success,
        listener: _handleReceipt,
        child:
            BlocConsumer<CloseSurplusDepositsCubit, CloseSurplusDepositsState>(
              listenWhen: (previous, current) =>
                  previous.effectId != current.effectId,
              listener: _handleEffect,
              builder: (context, state) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: PopScope(
                    canPop: state.effect == CloseSurplusDepositsEffect.back,
                    onPopInvokedWithResult: (didPop, _) {
                      if (!didPop) {
                        context.read<CloseSurplusDepositsCubit>().requestBack();
                      }
                    },
                    child: Scaffold(
                      backgroundColor: context.colors.surfaceSubtle,
                      body: SafeArea(
                        child: Column(
                          children: [
                            AppTopBar(
                              title: S.current.surplusDepositsTitle,
                              showLeadingActions: false,
                              leadingAction: const SizedBox.shrink(),
                              trailingIcon: depositIcon(
                                AppAssets.depositFeatureBack,
                              ),
                              trailingTooltip: S.current.backLabel,
                              onTrailingPressed: context
                                  .read<CloseSurplusDepositsCubit>()
                                  .requestBack,
                            ),
                            Expanded(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (state.step ==
                                      CloseSurplusDepositsStep.primaryDeposit)
                                    CloseSurplusDepositsForm(state: state)
                                  else
                                    SurplusDepositsResult(state: state),
                                  Positioned(
                                    left: 16,
                                    bottom: 16,
                                    child: AppAssistantButton(
                                      onPressed: context
                                          .read<CloseSurplusDepositsCubit>()
                                          .requestAssistant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CloseSurplusDepositsFooter(state: state),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}
