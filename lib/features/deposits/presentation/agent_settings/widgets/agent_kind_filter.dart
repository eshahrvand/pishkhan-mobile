import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../deposit_list/widgets/deposit_sheet.dart';
import '../cubit/agent_settings_cubit.dart';
import 'agent_filter_option.dart';
import 'agent_filter_panel.dart';
import 'agent_labels.dart';

Future<bool?> showAgentKindFilter(BuildContext context) {
  return showDepositSheet<bool>(
    context,
    BlocProvider.value(
      value: context.read<AgentSettingsCubit>(),
      child: const AgentKindFilter(),
    ),
  );
}

class AgentKindFilter extends StatelessWidget {
  const AgentKindFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AgentSettingsCubit, AgentSettingsState>(
      buildWhen: (previous, current) =>
          previous.draftKinds != current.draftKinds ||
          previous.isEveryKindSelected != current.isEveryKindSelected,
      builder: (context, state) {
        return AgentFilterPanel(
          title: S.current.agentKind,
          options: [
            AgentFilterOption(
              label: S.current.agentSettingsSelectAll,
              selected: state.isEveryKindSelected,
              onPressed: context.read<AgentSettingsCubit>().toggleAllDraftKinds,
            ),
            for (final kind in AgentKind.values)
              AgentFilterOption(
                label: agentKindLabel(kind),
                selected: state.draftKinds.contains(kind),
                onPressed: () =>
                    context.read<AgentSettingsCubit>().toggleDraftKind(kind),
              ),
          ],
        );
      },
    );
  }
}
