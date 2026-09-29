import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

/// Figma occupation summary card used by the personal-information flow.
class AppOccupationCard extends StatelessWidget {
  const AppOccupationCard({
    super.key,
    this.title = 'طراح',
    this.description = 'UI / UX Designer',
    this.headerTitle,
    this.onMoreTap,
  });

  final String title;
  final String description;
  final String? headerTitle;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Container(
      key: const Key('app_occupation_card'),
      width: 343,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppPalette.gray50,
        borderRadius: AppRadius.borderMd,
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 20,
            child: Row(
              textDirection: TextDirection.ltr,
              children: [
                InkWell(
                  key: const Key('app_occupation_more'),
                  onTap: onMoreTap,
                  child: Transform.rotate(
                    angle: -math.pi / 2,
                    child: SvgPicture.asset(
                      AppAssets.iconMoreVertical20Gray700,
                    ),
                  ),
                ),
                const Spacer(),
                if (headerTitle case final value?) ...[
                  Flexible(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: _mediumStyle(AppPalette.gray900),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Transform.rotate(
                  angle: math.pi,
                  child: Transform.flip(
                    flipY: true,
                    child: SvgPicture.asset(AppAssets.occupationCardBriefcase),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: .5,
            child: SvgPicture.asset(
              AppAssets.dividerCardGray200,
              fit: BoxFit.fill,
            ),
          ),
          const SizedBox(height: 8),
          _detailRow(value: title, label: 'عنوان'),
          const SizedBox(height: 8),
          _detailRow(value: description, label: 'شرح'),
        ],
      ),
    ),
  );

  Widget _detailRow({required String value, required String label}) => SizedBox(
    height: 22,
    child: Row(
      textDirection: TextDirection.ltr,
      children: [
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.ltr,
            style: _mediumStyle(AppPalette.gray900),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: _regularStyle(AppPalette.gray700)),
      ],
    ),
  );

  TextStyle _regularStyle(Color color) => AppTypography.bodySmall.copyWith(
    color: color,
    height: 18 / 12,
    letterSpacing: 0,
  );

  TextStyle _mediumStyle(Color color) =>
      _regularStyle(color).copyWith(fontWeight: FontWeight.w500);
}
