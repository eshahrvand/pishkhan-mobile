import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/second_password_cubit.dart';
import 'password_rule_row.dart';

class PasswordRules extends StatelessWidget {
  const PasswordRules({super.key, required this.state});
  final SecondPasswordState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PasswordRuleRow(
          label: S.current.passwordLengthRule,
          isValid: state.isPasswordLengthValid,
        ),
        const SizedBox(height: 12),
        PasswordRuleRow(
          label: S.current.passwordPatternRule,
          isValid: state.isPasswordPatternValid,
        ),
        const SizedBox(height: 12),
        PasswordRuleRow(
          label: S.current.passwordDateRule,
          isValid: state.isPasswordDateValid,
        ),
      ],
    );
  }
}
