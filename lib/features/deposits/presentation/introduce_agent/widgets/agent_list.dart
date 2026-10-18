import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_agent_card.dart';

import '../../deposit_list/widgets/deposit_ui.dart';
import '../cubit/agent_cubit.dart';

class AgentList extends StatelessWidget {
  const AgentList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AgentCubit, AgentState>(
      buildWhen: (previous, current) =>
          previous.agents != current.agents ||
          previous.isEditable != current.isEditable,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final agent in state.agents) ...[
              AppAgentCard(
                title: S.current.agentNewPerson,
                secondary: CurrencyFormatter.toPersianDigits(agent.nationalId),
                actionIcon: depositIcon(AppAssets.fileUploadTrash, size: 20),
                actionLabel: S.current.agentRemove,
                actionAlignment: Alignment.centerLeft,
                bodyColor: AppPalette.gray100,
                detailLabelColor: context.colors.textTertiary,
                onMorePressed: state.isEditable
                    ? () => context.read<AgentCubit>().removeAgent(agent)
                    : null,
                rows: [
                  (
                    label: S.current.agentKind,
                    value: S.current.agentChequeBook,
                  ),
                  (
                    label: S.current.agentDepositShort,
                    value: CurrencyFormatter.toPersianDigits(
                      agent.deposit.number,
                    ),
                  ),
                  (
                    label: S.current.agentValidity,
                    value: JalaliDateFormatter.format(agent.validUntil),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: IntrinsicWidth(
                child: SizedBox(
                  height: 20,
                  child: AppButton(
                    label: S.current.agentAddNext,
                    leadingIcon: depositIcon(AppAssets.issuancePlus, size: 20),
                    variant: AppButtonVariant.text,
                    size: AppButtonSize.sm,
                    horizontalPadding: 0,
                    contentGap: 8,
                    labelStyle: Theme.of(context).textTheme.bodySmall!
                        .copyWith(fontWeight: FontWeight.w500, height: 18 / 12),
                    constrainLabel: true,
                    onPressed: state.isEditable
                        ? context.read<AgentCubit>().requestNextAgent
                        : null,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
