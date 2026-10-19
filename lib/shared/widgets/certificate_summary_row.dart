import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

class CertificateSummaryRow extends StatelessWidget {
  const CertificateSummaryRow({
    super.key,
    required this.label,
    required this.value,
    required this.asset,
  });
  final String label;
  final String value;
  final String asset;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall!
              .copyWith(color: context.colors.textSecondary, height: 18 / 12),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AvpImage(image: asset, height: .5, fit: BoxFit.fill),
        ),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: (MediaQuery.sizeOf(context).width - 64) * .65,
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall!
                .copyWith(fontWeight: FontWeight.w500, height: 18 / 12),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
