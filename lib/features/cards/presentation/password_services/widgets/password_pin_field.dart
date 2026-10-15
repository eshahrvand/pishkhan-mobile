import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pishkhan_mobile/features/cards/presentation/password_services/widgets/password_styles.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

class PasswordPinField extends StatelessWidget {
  const PasswordPinField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.visible,
    required this.onVisibilityChanged,
    required this.onChanged,
    this.focusNode,
    this.errorText,
  });
  final TextEditingController controller;
  final String hintText;
  final bool visible;
  final VoidCallback onVisibilityChanged;
  final ValueChanged<String> onChanged;
  final FocusNode? focusNode;
  final String? errorText;
  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      focusNode: focusNode,
      hintText: hintText,
      obscureText: !visible,
      obscuringCharacter: '*',
      autocorrect: false,
      enableSuggestions: false,
      enableIMEPersonalizedLearning: false,
      keyboardType: TextInputType.number,
      normalizeDigits: true,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      focusRing: AppTextFieldFocusRing.none,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
      textStyle: passwordBody(context),
      errorText: errorText,
      suffixIcon: AppButton(
        variant: AppButtonVariant.text,
        size: AppButtonSize.lg,
        tooltip: visible ? S.current.passwordHide : S.current.passwordShow,
        onPressed: onVisibilityChanged,
        icon: SizedBox.square(
          dimension: 20,
          child: visible
              ? AvpImage(image: AppAssets.resalatCardEye)
              : AvpImage(image: AppAssets.passwordEyeSlash),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
