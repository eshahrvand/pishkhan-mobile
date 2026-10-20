import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

/// Full-row selection target shared by the type and status filter lists.
class ReportFilterOption extends StatelessWidget {
  const ReportFilterOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: InkWell(
        onTap: onPressed,
        child: Row(
          children: [
            AppCheckbox(
              value: selected,
              size: AppCheckboxSize.md,
              onChanged: (_) {
                onPressed();
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w500,
                  height: 20 / 14,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
