import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

class AuthServicesSectionTitle extends StatelessWidget {
  const AuthServicesSectionTitle({
    required this.title,
    required this.dividerAsset,
    super.key,
  });

  final String title;
  final String dividerAsset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: AppLoginColors.sectionLabel,
              fontWeight: FontWeight.w600,
              height: 20 / 14,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AvpImage(image: dividerAsset, height: 1, fit: BoxFit.fill),
        ),
      ],
    );
  }
}
