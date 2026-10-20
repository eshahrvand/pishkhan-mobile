import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

/// Report details allow wrapped values instead of truncating banking information.
class ReportDetailRow extends StatelessWidget {
  const ReportDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final String label;
  final Widget value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: context.colors.borderSubtle,
                  width: .5,
                ),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
              height: 20 / 14,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 20 / 14,
                  letterSpacing: 0,
                ),
                textAlign: TextAlign.end,
                child: value,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
