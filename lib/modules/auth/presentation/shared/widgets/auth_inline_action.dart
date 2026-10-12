import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

class AuthInlineAction extends StatelessWidget {
  const AuthInlineAction({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderSm,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            label,
            style: AppTypography.titleSmall.copyWith(
              color: context.colors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 20 / 14,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}
