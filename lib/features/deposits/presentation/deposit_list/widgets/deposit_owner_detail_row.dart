import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

class DepositOwnerDetailRow extends StatelessWidget {
  const DepositOwnerDetailRow({
    super.key,
    required this.label,
    required this.value,
    required this.separatorAsset,
    this.textDirection = TextDirection.rtl,
  });
  final String label;
  final String value;
  final String separatorAsset;
  final TextDirection textDirection;
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 32),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                height: 18 / 12,
                letterSpacing: 0,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AvpImage(
                image: separatorAsset,
                height: .5,
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: (MediaQuery.sizeOf(context).width - 40) * .6,
              ),
              child: Text(
                value,
                textAlign: TextAlign.end,
                textDirection: textDirection,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 18 / 12,
                  letterSpacing: 0,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
