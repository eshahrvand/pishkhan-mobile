import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/representative_cubit.dart';
import 'representative_form.dart';

class RepresentativeInitialForm extends StatelessWidget {
  const RepresentativeInitialForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const RepresentativeForm(),
        const SizedBox(height: 20),
        BlocBuilder<RepresentativeCubit, RepresentativeState>(
          buildWhen: (previous, current) =>
              previous.canSaveDraft != current.canSaveDraft,
          builder: (context, state) {
            return SizedBox(
              width: 240,
              child: AppButton(
                label: S.current.representativePreliminarySave,
                variant: AppButtonVariant.outline,
                size: AppButtonSize.md,
                onPressed: state.canSaveDraft
                    ? () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        context.read<RepresentativeCubit>().saveDraft();
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
