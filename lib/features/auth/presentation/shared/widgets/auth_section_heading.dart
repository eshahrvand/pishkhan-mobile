import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';

class AuthSectionHeading extends StatelessWidget {
  const AuthSectionHeading({
    required this.title,
    required this.description,
    super.key,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          SvgPicture.asset(AuthAssets.sectionMark, width: 10, height: 20),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
                height: 24 / 16,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        description,
        textAlign: TextAlign.start,
        style: AppTypography.bodyMedium.copyWith(
          color: context.colors.textTertiary,
          height: 20 / 14,
          letterSpacing: 0,
        ),
      ),
    ],
  );
}
