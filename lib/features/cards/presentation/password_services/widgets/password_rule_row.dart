import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

import 'password_styles.dart';

class PasswordRuleRow extends StatelessWidget {
  const PasswordRuleRow({
    super.key,
    required this.label,
    required this.isValid,
  });
  final String label;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox.square(
          dimension: 20,
          child: AvpImage(
            image: isValid
                ? '${AppConstants.baseImage}password_check_active.svg'
                : '${AppConstants.baseImage}password_check_inactive.svg',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: passwordBody(context).copyWith(
              color: isValid
                  ? context.colors.textSecondary
                  : AppPasswordServiceColors.hint,
            ),
          ),
        ),
      ],
    );
  }
}
