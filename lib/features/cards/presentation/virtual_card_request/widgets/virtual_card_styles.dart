import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

TextStyle virtualCardBodyStyle(BuildContext context) =>
    AppTypography.bodyMedium.copyWith(
      height: 20 / 14,
      letterSpacing: 0,
      color: AppPasswordServiceColors.title,
    );
TextStyle virtualCardLabelStyle(BuildContext context) =>
    AppTypography.bodySmall.copyWith(
      height: 18 / 12,
      letterSpacing: 0,
      fontWeight: FontWeight.w500,
      color: context.colors.textSecondary,
    );
