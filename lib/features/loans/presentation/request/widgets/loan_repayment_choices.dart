import 'package:flutter/material.dart';

import 'loan_radio_choice.dart';

/// Radio choices composed from the authored selected artwork (no package radio exists).
class LoanRepaymentChoices<T> extends StatelessWidget {
  const LoanRepaymentChoices({
    super.key,
    required this.value,
    this.checkMark = false,
    this.labelStyle,
    required this.first,
    required this.second,
    required this.firstLabel,
    required this.secondLabel,
    required this.onChanged,
  });
  final T value;
  final bool checkMark;
  final TextStyle? labelStyle;
  final T first;
  final T second;
  final String firstLabel;
  final String secondLabel;
  final ValueChanged<T>? onChanged;
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 12,
      children: [
        LoanRadioChoice(
          label: firstLabel,
          selected: value == first,
          checkMark: checkMark,
          labelStyle: labelStyle,
          onPressed: onChanged == null
              ? null
              : () {
                  onChanged!(first);
                },
        ),
        LoanRadioChoice(
          label: secondLabel,
          selected: value == second,
          checkMark: checkMark,
          labelStyle: labelStyle,
          onPressed: onChanged == null
              ? null
              : () {
                  onChanged!(second);
                },
        ),
      ],
    );
  }
}
