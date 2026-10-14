import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

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
          child: SvgPicture.asset(
            isValid
                ? AppAssets.passwordCheckActive
                : AppAssets.passwordCheckInactive,
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
