import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_agent_cards.dart';

import '../cubit/agent_settings_cubit.dart';
import 'agent_filters.dart';
import 'agent_labels.dart';

class AgentSettingsContent extends StatelessWidget {
  const AgentSettingsContent({super.key, required this.state});

  final AgentSettingsState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: Row(
            children: [
              for (final tab in AgentTab.values)
                Expanded(
                  child: InkWell(
                    onTap: () =>
                        context.read<AgentSettingsCubit>().selectTab(tab),
                    child: Semantics(
                      selected: state.tab == tab,
                      button: true,
                      child: Column(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                tab == AgentTab.myAgents
                                    ? S.current.agentSettingsMine
                                    : S.current.agentSettingsDelegated,
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      fontWeight: state.tab == tab
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: state.tab == tab
                                          ? context.colors.primary
                                          : context.colors.textTertiary,
                                      height: 20 / 14,
                                    ),
                              ),
                            ),
                          ),
                          Container(
                            height: 2,
                            color: state.tab == tab
                                ? context.colors.primary
                                : context.colors.borderSubtle,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: AgentFilters(state: state),
        ),
        Expanded(
          // The assistant and Add overlay the list, matching both tab layouts.
          child: Stack(
            children: [
              if (state.agentsStatus == RequestStatus.initial ||
                  state.agentsStatus == RequestStatus.loading)
                const Center(child: CircularProgressIndicator())
              else if (state.agentsStatus == RequestStatus.failure)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox.shrink(),
                      const SizedBox(height: 12),
                      AppButton(
                        isLoading: state.agentsStatus == RequestStatus.loading,
                        label: S.current.dashboardRetry,
                        onPressed: context
                            .read<AgentSettingsCubit>()
                            .fetchAgents,
                      ),
                    ],
                  ),
                )
              else if (state.visibleAgents.isEmpty)
                Center(
                  child: Text(
                    S.current.agentSettingsEmpty,
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    state.canAddAgent ? 132 : 72,
                  ),
                  itemCount: state.visibleAgents.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (state.tab == AgentTab.myAgents) {
                      return AppMyAgentCard(
                        bodyColor: AppPalette.gray100,
                        detailLabelColor: context.colors.textTertiary,
                        actionAlignment: Alignment.centerLeft,
                        name: state.visibleAgents[index].agentName,
                        identityNumber:
                            state.visibleAgents[index].agentNationalId,
                        kind: agentKindLabel(state.visibleAgents[index].kind),
                        depositNumber: state.visibleAgents[index].depositNumber,
                        validUntil: JalaliDateFormatter.format(
                          state.visibleAgents[index].expiresAt,
                        ),
                        status: agentCardStatus(
                          state.visibleAgents[index].status,
                        ),
                        onMorePressed: () => context
                            .read<AgentSettingsCubit>()
                            .requestAgentActions(state.visibleAgents[index]),
                      );
                    }
                    return AppMeAsAgentCard(
                      bodyColor: AppPalette.gray100,
                      detailLabelColor: context.colors.textTertiary,
                      actionAlignment: Alignment.centerLeft,
                      depositNumber: state.visibleAgents[index].depositNumber,
                      kind: agentKindLabel(state.visibleAgents[index].kind),
                      owner: state.visibleAgents[index].ownerName,
                      validUntil: JalaliDateFormatter.format(
                        state.visibleAgents[index].expiresAt,
                      ),
                      status: agentCardStatus(
                        state.visibleAgents[index].status,
                      ),
                      onMorePressed: () => context
                          .read<AgentSettingsCubit>()
                          .requestAgentActions(state.visibleAgents[index]),
                    );
                  },
                ),
              Positioned(
                left: 16,
                bottom: state.canAddAgent ? 76 : 16,
                child: AppAssistantButton(
                  onPressed: context
                      .read<AgentSettingsCubit>()
                      .requestAssistant,
                ),
              ),
              if (state.canAddAgent)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    child: AppButton(
                      label: S.current.agentSettingsAdd,
                      leadingIcon: const AvpImage(
                        image: '${AppConstants.baseImage}agent_plus.svg',
                        width: 20,
                        height: 20,
                      ),
                      onPressed: context
                          .read<AgentSettingsCubit>()
                          .requestIntroduction,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
