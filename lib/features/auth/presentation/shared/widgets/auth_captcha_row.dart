import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pishkhan_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_field_icon.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';

class AuthCaptchaRow extends StatelessWidget {
  const AuthCaptchaRow({
    required this.step,
    required this.onChanged,
    super.key,
  });

  final AuthStep step;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppTextField(
            key: ValueKey('${step.name}-captcha'),
            hintText: context.l10n.captchaHint,
            suffixIcon: const AuthFieldIcon('$authAssetPath/refresh.svg'),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            normalizeDigits: true,
            focusRing: AppTextFieldFocusRing.subtle,
            inputFormatters: [LengthLimitingTextInputFormatter(6)],
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 7),
        const Expanded(child: _CaptchaImage()),
      ],
    );
  }
}

class _CaptchaImage extends StatelessWidget {
  const _CaptchaImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(color: context.colors.border),
        borderRadius: AppRadius.borderSm,
        boxShadow: AppShadows.xs,
      ),
      child: Image.asset(
        '$authAssetPath/captcha.png',
        width: 100,
        height: 34,
        fit: BoxFit.contain,
      ),
    );
  }
}
