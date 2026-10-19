import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import 'password_styles.dart';

class PasswordServiceSelect<T> extends StatelessWidget {
  const PasswordServiceSelect({
    super.key,
    required this.title,
    required this.hint,
    required this.value,
    required this.options,
    required this.change,
  });
  final String title, hint;
  final T? value;
  final List<AppSelectOption<T>> options;
  final ValueChanged<T> change;
  @override
  Widget build(BuildContext context) {
    return AppSelect<T>(
      label: title,
      hintText: hint,
      value: value,
      options: options,
      onChanged: change,
      labelSpacing: 8,
      labelStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
        height: 18 / 12,
        fontWeight: FontWeight.w500,
        color: context.colors.textSecondary,
        letterSpacing: 0,
      ),
      textStyle: passwordBody(context).copyWith(
        fontWeight: FontWeight.w400,
        color: value == null
            ? AppPasswordServiceColors.hint
            : context.colors.textPrimary,
      ),
      trailing: SizedBox.square(
        dimension: 20,
        child: AvpImage(
          image: value == null
              ? AppAssets.issuanceSelectEmpty
              : AppAssets.cardFeaturesChevron,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
