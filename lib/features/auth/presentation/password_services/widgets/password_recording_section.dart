import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:pishkhan_mobile/features/auth/presentation/password_services/cubit/second_password_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/widgets/password_styles.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
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
          context.l10n.passwordRecordingPrompt,
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
                Image.asset(AppAssets.passwordRecording, fit: BoxFit.cover),
                ColoredBox(
                  color: AppPasswordServiceColors.recordingScrim.withValues(
                    alpha: .4,
                  ),
                ),
                Center(
                  child: AppButton(
                    variant: AppButtonVariant.text,
                    size: AppButtonSize.lg,

                    tooltip: context.l10n.passwordConfirmMock,
                    onPressed: cubit.confirmMockRecording,
                    icon: SizedBox.square(
                      dimension: 23,
                      child: SvgPicture.asset(
                        AppAssets.passwordRecordPlay,
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
              label: context.l10n.passwordRecordAgain,
              variant: AppButtonVariant.text,
              horizontalPadding: 4,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.passwordMockKyc,
          style: Theme.of(context).textTheme.bodySmall!
              .copyWith(color: context.colors.textTertiary, height: 18 / 12),
        ),
        BlocSelector<SecondPasswordCubit, SecondPasswordState, bool>(
          selector: (s) => s.recordingConfirmed,
          builder: (context, confirmed) => AppCheckbox(
            value: confirmed,
            label: context.l10n.passwordConfirmMock,
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
