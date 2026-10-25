import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/agent_settings_cubit.dart';

class AgentFilters extends StatelessWidget {
  const AgentFilters({super.key, required this.state});

  final AgentSettingsState state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: AppChips(
              label: S.current.agentDepositShort,
              selected: state.depositFilter != null,
              icon: AvpImage(
                image: state.depositFilter == null
                    ? '${AppConstants.baseImage}deposit_list_chevron.svg'
                    : '${AppConstants.baseImage}deposit_list_clear.svg',
                width: 20,
                height: 20,
              ),
              onPressed: state.agentsStatus == RequestStatus.success
                  ? context.read<AgentSettingsCubit>().requestDepositFilter
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Directionality(
            textDirection: TextDirection.ltr,
            child: AppChips(
              label: S.current.agentKind,
              selected: state.kindFilter != null,
              icon: AvpImage(
                image: state.kindFilter == null
                    ? '${AppConstants.baseImage}deposit_list_chevron.svg'
                    : '${AppConstants.baseImage}deposit_list_clear.svg',
                width: 20,
                height: 20,
              ),
              onPressed: state.agentsStatus == RequestStatus.success
                  ? context.read<AgentSettingsCubit>().requestKindFilter
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Directionality(
            textDirection: TextDirection.ltr,
            child: AppChips(
              label: S.current.depositListStatus,
              selected: state.statusFilter != null,
              icon: AvpImage(
                image: state.statusFilter == null
                    ? '${AppConstants.baseImage}deposit_list_chevron.svg'
                    : '${AppConstants.baseImage}deposit_list_clear.svg',
                width: 20,
                height: 20,
              ),
              onPressed: state.agentsStatus == RequestStatus.success
                  ? context.read<AgentSettingsCubit>().requestStatusFilter
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
