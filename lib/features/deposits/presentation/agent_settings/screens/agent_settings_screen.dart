import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/router/app_router.dart';
import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../cubit/agent_settings_cubit.dart';
import '../widgets/agent_actions_sheet.dart';
import '../widgets/agent_deposit_filter.dart';
import '../widgets/agent_details.dart';
import '../widgets/agent_kind_filter.dart';
import '../widgets/agent_settings_content.dart';
import '../widgets/agent_status_filter.dart';

class AgentSettingsScreen extends StatelessWidget {
  const AgentSettingsScreen({
    super.key,
    this.initialDepositNumber,
    this.onAssistantPressed,
  });

  final String? initialDepositNumber;
  final VoidCallback? onAssistantPressed;

  Future<void> _handleEffect(
    BuildContext context,
    AgentSettingsState state,
  ) async {
    switch (state.effect) {
      case AgentDepositFilterRequested():
        final applied = await showAgentDepositFilter(context);
        if (context.mounted) {
          context.read<AgentSettingsCubit>().applyDepositFilterResult(applied);
        }
      case AgentKindFilterRequested():
        final applied = await showAgentKindFilter(context);
        if (context.mounted) {
          context.read<AgentSettingsCubit>().applyKindFilterResult(applied);
        }
      case AgentStatusFilterRequested():
        final applied = await showAgentStatusFilter(context);
        if (context.mounted) {
          context.read<AgentSettingsCubit>().applyStatusFilterResult(applied);
        }
      case AgentActionsRequested(:final agent):
        final action = await showAgentActions(context);
        if (context.mounted) {
          context.read<AgentSettingsCubit>().selectAgentAction(agent, action);
        }
      case AgentIntroductionRequested(:final depositNumber):
        await context.push<void>(
          AppRoutes.introduceAgent,
          extra: AgentRouteArguments(initialDepositNumber: depositNumber),
        );
      case AgentUnavailableRequested():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.cardFeatureUnavailable)),
        );
      case AgentBackRequested():
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) NavigationActions.back(context);
        });
      case AgentAssistantRequested():
        NavigationActions.returnHome(context);
        onAssistantPressed?.call();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AgentSettingsCubit(initialDepositNumber: initialDepositNumber)
            ..fetchAgents(),
      child: BlocConsumer<AgentSettingsCubit, AgentSettingsState>(
        listenWhen: (previous, current) =>
            previous.effectId != current.effectId,
        listener: _handleEffect,
        builder: (context, state) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: PopScope(
              canPop: state.effect is AgentBackRequested,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop) {
                  context.read<AgentSettingsCubit>().requestBack();
                }
              },
              child: Scaffold(
                backgroundColor: context.colors.surfaceSubtle,
                body: SafeArea(
                  child: Column(
                    children: [
                      AppTopBar(
                        title: state.details == null
                            ? S.current.dashboardAgentSettings
                            : S.current.agentSettingsDetails,
                        showLeadingActions: false,
                        leadingAction: state.details == null
                            ? null
                            : AppButton(
                                icon: const SizedBox.square(
                                  dimension: 24,
                                  child: Center(
                                    child: AvpImage(
                                      image: AppAssets.agentCancel,
                                      color: AppPalette.error500,
                                    ),
                                  ),
                                ),
                                tooltip: S.current.agentSettingsCancel,
                                variant: AppButtonVariant.text,
                                onPressed: context
                                    .read<AgentSettingsCubit>()
                                    .requestCancellation,
                              ),
                        trailingIcon: const AvpImage(
                          image: AppAssets.depositFeatureBack,
                          width: 24,
                          height: 24,
                        ),
                        trailingTooltip: S.current.backLabel,
                        onTrailingPressed: context
                            .read<AgentSettingsCubit>()
                            .requestBack,
                      ),
                      Expanded(
                        child: state.details == null
                            ? AgentSettingsContent(state: state)
                            : AgentDetails(agent: state.details!),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
