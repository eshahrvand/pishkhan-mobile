import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../../deposit_list/widgets/deposit_sheet.dart';
import '../../deposit_list/widgets/deposit_ui.dart';
import '../cubit/agent_settings_effect.dart';

Future<AgentAction?> showAgentActions(BuildContext context) {
  return showDepositSheet<AgentAction>(context, const AgentActionsSheet());
}

class AgentActionsSheet extends StatelessWidget {
  const AgentActionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppBottomSheetHeader(type: AppBottomSheetHeaderType.handleOnly),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => context.pop(AgentAction.details),
                child: SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      S.current.agentSettingsDetails,
                      style: Theme.of(context).textTheme.bodyMedium!
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
              const DepositDivider(),
              InkWell(
                onTap: () => context.pop(AgentAction.cancel),
                child: SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      S.current.agentSettingsCancel,
                      style: Theme.of(context).textTheme.bodyMedium!
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
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
