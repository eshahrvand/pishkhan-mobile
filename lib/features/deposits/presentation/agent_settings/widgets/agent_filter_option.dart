import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

/// Whole-row checkbox target used by the three multi-selection sheets.
class AgentFilterOption extends StatelessWidget {
  const AgentFilterOption({
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
    return InkWell(
      onTap: onPressed,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            AppCheckbox(
              value: selected,
              onChanged: (_) => onPressed(),
              size: AppCheckboxSize.md,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w500,
                  height: 20 / 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
