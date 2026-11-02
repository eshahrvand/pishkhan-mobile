import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pishkhan_mobile/features/cards/presentation/password_services/cubit/second_password_cubit.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/widgets/password_styles.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

class PasswordRecordingSection extends StatelessWidget {
  const PasswordRecordingSection({super.key, required this.state});
  final SecondPasswordState state;
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
                AvpImage(
                  image: '${AppConstants.baseImage}password_recording.png',
                  fit: BoxFit.cover,
                ),
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
                        image:
                            '${AppConstants.baseImage}password_record_play.svg',
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
              onPressed: cubit.resetRecordingConfirmation,
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
        AppCheckbox(
          value: state.isRecordingConfirmed,
          label: S.current.passwordConfirmMock,
          onChanged: cubit.updateRecordingConfirmation,
        ),
      ],
    );
  }
}
