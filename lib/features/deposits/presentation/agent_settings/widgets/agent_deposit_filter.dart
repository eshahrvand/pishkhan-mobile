import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../deposit_list/widgets/deposit_sheet.dart';
import '../cubit/agent_settings_cubit.dart';
import 'agent_filter_option.dart';
import 'agent_filter_panel.dart';

Future<bool?> showAgentDepositFilter(BuildContext context) {
  return showDepositSheet<bool>(
    context,
    BlocProvider.value(
      value: context.read<AgentSettingsCubit>(),
      child: const AgentDepositFilter(),
    ),
  );
}

class AgentDepositFilter extends StatelessWidget {
  const AgentDepositFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AgentSettingsCubit, AgentSettingsState>(
      buildWhen: (previous, current) =>
          previous.draftDeposits != current.draftDeposits ||
          previous.isEveryDepositSelected != current.isEveryDepositSelected ||
          previous.depositNumbers != current.depositNumbers,
      builder: (context, state) {
        return AgentFilterPanel(
          title: S.current.agentDeposit,
          options: [
            AgentFilterOption(
              label: S.current.agentSettingsSelectAll,
              selected: state.isEveryDepositSelected,
              onPressed: context
                  .read<AgentSettingsCubit>()
                  .toggleAllDraftDeposits,
            ),
            for (final number in state.depositNumbers)
              AgentFilterOption(
                label: CurrencyFormatter.toPersianDigits(number),
                selected: state.draftDeposits.contains(number),
                onPressed: () => context
                    .read<AgentSettingsCubit>()
                    .toggleDraftDeposit(number),
              ),
          ],
        );
      },
    );
  }
}
