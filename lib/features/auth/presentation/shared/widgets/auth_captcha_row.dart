import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_field_icon.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_numeric_field.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';

class AuthCaptchaRow extends StatelessWidget {
  const AuthCaptchaRow({required this.step, super.key});
  final AuthStep step;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: BlocSelector<AuthCubit, AuthState, (String, bool)>(
            selector: (state) =>
                (state.captcha, state.invalidFields.contains('captcha')),
            builder: (context, value) => AuthNumericField(
              key: ValueKey('${step.name}-captcha'),
              value: value.$1,
              hintText: context.l10n.captchaHint,
              errorText: value.$2 ? context.l10n.authInvalidCaptcha : null,
              suffixIcon: AuthFieldIcon(
                AuthAssets.refresh,
                semanticLabel: context.l10n.refreshCaptcha,
                onPressed: cubit.refreshCaptcha,
              ),
              maxLength: 6,
              textInputAction: TextInputAction.done,
              onChanged: cubit.captchaChanged,
              onFocusLost: () => cubit.validateField('captcha'),
              onSubmitted: (_) {
                if (cubit.requestOtp()) {
                  FocusManager.instance.primaryFocus?.unfocus();
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 7),
        const SizedBox(width: 148, child: _CaptchaImage()),
      ],
    );
  }
}

class _CaptchaImage extends StatelessWidget {
  const _CaptchaImage();

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('auth_captcha_image'),
    height: 44,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: context.colors.surface,
      border: Border.all(color: context.colors.border),
      borderRadius: AppRadius.borderSm,
      boxShadow: AppShadows.xs,
    ),
    child: Image.asset(
      AuthAssets.captcha,
      width: 100,
      height: 34,
      fit: BoxFit.cover,
    ),
  );
}
