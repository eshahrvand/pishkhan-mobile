import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/second_password_cubit.dart';
import 'password_rule_row.dart';

class PasswordRules extends StatelessWidget {
  const PasswordRules({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SecondPasswordCubit, SecondPasswordState>(
      buildWhen: (previous, current) =>
          previous.lengthValid != current.lengthValid ||
          previous.patternValid != current.patternValid ||
          previous.dateValid != current.dateValid,
      builder: (context, state) {
        return Column(
          children: [
            PasswordRuleRow(
              label: S.current.passwordLengthRule,
              isValid: state.lengthValid,
            ),
            const SizedBox(height: 12),
            PasswordRuleRow(
              label: S.current.passwordPatternRule,
              isValid: state.patternValid,
            ),
            const SizedBox(height: 12),
            PasswordRuleRow(
              label: S.current.passwordDateRule,
              isValid: state.dateValid,
            ),
          ],
        );
      },
    );
  }
}
