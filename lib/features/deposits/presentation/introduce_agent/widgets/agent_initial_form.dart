import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/agent_cubit.dart';
import 'agent_form.dart';

class AgentInitialForm extends StatelessWidget {
  const AgentInitialForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AgentForm(),
        const SizedBox(height: 20),
        BlocBuilder<AgentCubit, AgentState>(
          buildWhen: (previous, current) =>
              previous.canSaveDraft != current.canSaveDraft,
          builder: (context, state) {
            return SizedBox(
              width: 240,
              child: AppButton(
                label: S.current.agentPreliminarySave,
                variant: AppButtonVariant.outline,
                size: AppButtonSize.md,
                onPressed: state.canSaveDraft
                    ? () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        context.read<AgentCubit>().saveDraft();
                      }
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }
}
