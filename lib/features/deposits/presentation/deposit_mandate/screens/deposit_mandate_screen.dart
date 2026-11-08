import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/shared/widgets/flow_exit_dialog.dart';

import '../../deposit_list/widgets/deposit_ui.dart';
import '../cubit/deposit_mandate_cubit.dart';
import '../widgets/deposit_mandate_footer.dart';
import '../widgets/deposit_mandate_form.dart';
import '../widgets/deposit_mandate_receipt_dialog.dart';

class DepositMandateScreen extends StatelessWidget {
  const DepositMandateScreen({
    super.key,
    this.initialDepositNumber,
    this.onAssistantPressed,
  });
  final String? initialDepositNumber;
  final VoidCallback? onAssistantPressed;

  void _showRequestFailure(BuildContext context, DepositMandateState state) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(state.message!)));
  }

  Future<void> _handleEffect(
    BuildContext context,
    DepositMandateState state,
  ) async {
    switch (state.effect) {
      case DepositMandateEffect.confirmExit:
        context.read<DepositMandateCubit>().consumeDepositMandateInteraction();
        final confirmed = await showFlowExitDialog(context);
        if (context.mounted) {
          context.read<DepositMandateCubit>().applyExitConfirmation(confirmed);
        }
      case DepositMandateEffect.back:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) NavigationActions.back(context);
        });
      case DepositMandateEffect.home:
        NavigationActions.returnHome(context);
      case DepositMandateEffect.assistant:
        context.read<DepositMandateCubit>().consumeDepositMandateInteraction();
        NavigationActions.returnHome(context);
        onAssistantPressed?.call();
      case DepositMandateEffect.termsUnavailable:
        context.read<DepositMandateCubit>().consumeDepositMandateInteraction();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.issuanceTermsUnavailable)),
        );
      case null:
        break;
    }
  }

  Future<void> _handleReceipt(
    BuildContext context,
    DepositMandateState state,
  ) async {
    await showDepositMandateReceiptDialog(context, state.receipt!);
    if (context.mounted) {
      context.read<DepositMandateCubit>().applyReceiptDismissal();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DepositMandateCubit(initialDepositNumber: initialDepositNumber)
            ..fetchCatalog(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<DepositMandateCubit, DepositMandateState>(
            listenWhen: (previous, current) =>
                previous.submissionStatus != current.submissionStatus &&
                current.submissionStatus == RequestStatus.success,
            listener: _handleReceipt,
          ),
          BlocListener<DepositMandateCubit, DepositMandateState>(
            listenWhen: (previous, current) =>
                previous.catalogStatus != current.catalogStatus &&
                current.catalogStatus == RequestStatus.failure,
            listener: _showRequestFailure,
          ),
          BlocListener<DepositMandateCubit, DepositMandateState>(
            listenWhen: (previous, current) =>
                previous.submissionStatus != current.submissionStatus &&
                current.submissionStatus == RequestStatus.failure,
            listener: _showRequestFailure,
          ),
          BlocListener<DepositMandateCubit, DepositMandateState>(
            listenWhen: (previous, current) =>
                previous.effect != current.effect && current.effect != null,
            listener: _handleEffect,
          ),
        ],
        child: BlocBuilder<DepositMandateCubit, DepositMandateState>(
          builder: (context, state) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: PopScope(
                canPop:
                    (state.catalogStatus != RequestStatus.loading &&
                        state.submissionStatus != RequestStatus.loading) &&
                    (state.effect == DepositMandateEffect.back),
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop &&
                      state.catalogStatus != RequestStatus.loading &&
                      state.submissionStatus != RequestStatus.loading) {
                    context.read<DepositMandateCubit>().requestBack();
                  }
                },
                child: Scaffold(
                  backgroundColor: context.colors.surfaceSubtle,
                  body: SafeArea(
                    child: Column(
                      children: [
                        AppTopBar(
                          title: S.current.depositMandate,
                          showLeadingActions: false,
                          leadingAction: const SizedBox.shrink(),
                          trailingIcon: depositIcon(
                            '${AppConstants.baseImage}deposit_list_back.svg',
                          ),
                          trailingTooltip: S.current.backLabel,
                          onTrailingPressed: context
                              .read<DepositMandateCubit>()
                              .requestBack,
                          isTrailingActive:
                              (state.catalogStatus != RequestStatus.loading &&
                              state.submissionStatus != RequestStatus.loading),
                        ),
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              const DepositMandateForm(),
                              Positioned(
                                left: 16,
                                bottom: 16,
                                child: AppAssistantButton(
                                  onPressed: context
                                      .read<DepositMandateCubit>()
                                      .requestAssistant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const DepositMandateFooter(),
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
