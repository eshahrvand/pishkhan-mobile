import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

import 'issuance_styles.dart';

class IssuanceToggleRow extends StatelessWidget {
  const IssuanceToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: label,
            child: AppToggle(
              value: value,
              onChanged: onChanged,
              appearance: AppToggleAppearance.issuance,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: issuanceBody(
                context,
                medium: true,
              ).copyWith(color: context.colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
