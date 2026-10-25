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
import '../cubit/agent_cubit.dart';
import '../widgets/agent_footer.dart';
import '../widgets/agent_initial_form.dart';
import '../widgets/agent_list.dart';
import '../widgets/agent_receipt_dialog.dart';
import '../widgets/agent_sheet.dart';

class IntroduceAgentScreen extends StatelessWidget {
  const IntroduceAgentScreen({super.key, this.initialDepositNumber});
  final String? initialDepositNumber;

  Future<void> _handleEffect(BuildContext context, AgentState state) async {
    if (state.message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.message!)));
      return;
    }

    switch (state.effect) {
      case AgentEffect.addNext:
        context.read<AgentCubit>().consumeAgentInteraction();
        await showAgentSheet(context, context.read<AgentCubit>());
      case AgentEffect.confirmExit:
        context.read<AgentCubit>().consumeAgentInteraction();
        final confirmed = await showFlowExitDialog(context);
        if (context.mounted) {
          context.read<AgentCubit>().applyExitConfirmation(confirmed);
        }
      case AgentEffect.back:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) NavigationActions.back(context);
        });
      case AgentEffect.home:
        NavigationActions.returnHome(context);
      case null:
        break;
    }
  }

  Future<void> _handleReceipt(BuildContext context, AgentState state) async {
    await showAgentReceiptDialog(context, state.receipt!);
    if (context.mounted) {
      context.read<AgentCubit>().applyReceiptDismissal();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AgentCubit(initialDepositNumber: initialDepositNumber)
            ..fetchDeposits(),
      child: BlocListener<AgentCubit, AgentState>(
        listenWhen: (previous, current) =>
            previous.submissionStatus != current.submissionStatus &&
            current.submissionStatus == RequestStatus.success,
        listener: _handleReceipt,
        child: BlocConsumer<AgentCubit, AgentState>(
          listenWhen: (previous, current) =>
              (previous.effect != current.effect &&
                  current.effect != null) ||
              ((previous.depositsStatus != current.depositsStatus &&
                      current.depositsStatus == RequestStatus.failure) ||
                  (previous.submissionStatus != current.submissionStatus &&
                      current.submissionStatus == RequestStatus.failure)),
          listener: _handleEffect,

          builder: (context, state) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: PopScope(
                canPop:
                    (state.depositsStatus != RequestStatus.loading &&
                        state.submissionStatus != RequestStatus.loading) &&
                    (state.effect == AgentEffect.back),
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop &&
                      state.depositsStatus != RequestStatus.loading &&
                      state.submissionStatus != RequestStatus.loading) {
                    context.read<AgentCubit>().requestBack();
                  }
                },
                child: Scaffold(
                  backgroundColor: context.colors.surfaceSubtle,
                  body: SafeArea(
                    child: Column(
                      children: [
                        AppTopBar(
                          title: S.current.agentTitle,
                          showLeadingActions: false,
                          leadingAction: const SizedBox.shrink(),
                          trailingIcon: depositIcon(
                            '${AppConstants.baseImage}deposit_list_back.svg',
                          ),
                          trailingTooltip: S.current.backLabel,
                          onTrailingPressed:
                              (state.depositsStatus != RequestStatus.loading &&
                                  state.submissionStatus !=
                                      RequestStatus.loading)
                              ? context.read<AgentCubit>().requestBack
                              : null,
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  72,
                                ),
                                child: BlocBuilder<AgentCubit, AgentState>(
                                  buildWhen: (previous, current) =>
                                      previous.depositsStatus !=
                                          current.depositsStatus ||
                                      previous.deposits.isEmpty !=
                                          current.deposits.isEmpty ||
                                      previous.agents.isEmpty !=
                                          current.agents.isEmpty,
                                  builder: (context, state) {
                                    switch (state.depositsStatus) {
                                      case RequestStatus.initial:
                                      case RequestStatus.loading:
                                        return const IgnorePointer(
                                          child: Opacity(
                                            opacity: .45,
                                            child: AgentInitialForm(),
                                          ),
                                        );
                                      case RequestStatus.failure:
                                        return Column(
                                          children: [
                                            AppButton(
                                              isLoading:
                                                  state.depositsStatus ==
                                                  RequestStatus.loading,
                                              label: S.current.dashboardRetry,
                                              onPressed: context
                                                  .read<AgentCubit>()
                                                  .fetchDeposits,
                                            ),
                                          ],
                                        );
                                      case RequestStatus.success:
                                        if (state.deposits.isEmpty) {
                                          return Text(S.current.depositsEmpty);
                                        }
                                        return state.agents.isEmpty
                                            ? const AgentInitialForm()
                                            : const AgentList();
                                    }
                                  },
                                ),
                              ),
                              Positioned(
                                left: 16,
                                bottom: 16,
                                child: AppAssistantButton(
                                  onPressed: context
                                      .read<AgentCubit>()
                                      .requestHome,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const AgentFooter(),
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
