import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../deposit_list/widgets/deposit_sheet.dart';
import '../cubit/agent_settings_cubit.dart';
import 'agent_filter_option.dart';
import 'agent_filter_panel.dart';
import 'agent_labels.dart';

Future<bool?> showAgentStatusFilter(BuildContext context) {
  return showDepositSheet<bool>(
    context,
    BlocProvider.value(
      value: context.read<AgentSettingsCubit>(),
      child: const AgentStatusFilter(),
    ),
  );
}

class AgentStatusFilter extends StatelessWidget {
  const AgentStatusFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AgentSettingsCubit, AgentSettingsState>(
      buildWhen: (previous, current) =>
          previous.draftStatuses != current.draftStatuses ||
          previous.isEveryStatusSelected != current.isEveryStatusSelected,
      builder: (context, state) {
        return AgentFilterPanel(
          title: S.current.depositListStatus,
          options: [
            AgentFilterOption(
              label: S.current.agentSettingsSelectAll,
              selected: state.isEveryStatusSelected,
              onPressed: context
                  .read<AgentSettingsCubit>()
                  .toggleAllDraftStatuses,
            ),
            for (final status in AgentStatus.values)
              AgentFilterOption(
                label: agentStatusLabel(status),
                selected: state.draftStatuses.contains(status),
                onPressed: () => context
                    .read<AgentSettingsCubit>()
                    .toggleDraftStatus(status),
              ),
          ],
        );
      },
    );
  }
}
