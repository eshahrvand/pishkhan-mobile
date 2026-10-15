import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pishkhan_mobile/features/auth/presentation/password_services/cubit/second_password_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/widgets/password_styles.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

class PasswordRecordingSection extends StatelessWidget {
  const PasswordRecordingSection({super.key});
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SecondPasswordCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          S.current.passwordRecordingPrompt,
          style: passwordBody(context).copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: AppRadius.borderSm,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AvpImage(image: AppAssets.passwordRecording, fit: BoxFit.cover),
                ColoredBox(
                  color: AppPasswordServiceColors.recordingScrim.withValues(
                    alpha: .4,
                  ),
                ),
                Center(
                  child: AppButton(
                    variant: AppButtonVariant.text,
                    size: AppButtonSize.lg,

                    tooltip: S.current.passwordConfirmMock,
                    onPressed: cubit.confirmMockRecording,
                    icon: SizedBox.square(
                      dimension: 23,
                      child: AvpImage(
                        image: AppAssets.passwordRecordPlay,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: IntrinsicWidth(
            child: AppButton(
              onPressed: cubit.recordAgain,
              label: S.current.passwordRecordAgain,
              variant: AppButtonVariant.text,
              horizontalPadding: 4,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          S.current.passwordMockKyc,
          style: Theme.of(context).textTheme.bodySmall!
              .copyWith(color: context.colors.textTertiary, height: 18 / 12),
        ),
        BlocBuilder<SecondPasswordCubit, SecondPasswordState>(
          buildWhen: (previous, current) =>
              previous.recordingConfirmed != current.recordingConfirmed,
          builder: (context, state) => AppCheckbox(
            value: state.recordingConfirmed,
            label: S.current.passwordConfirmMock,
            onChanged: (v) {
              if (v == true) {
                cubit.confirmMockRecording();
              } else {
                cubit.recordAgain();
              }
            },
          ),
        ),
      ],
    );
  }
}
