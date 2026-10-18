import 'app_occupation_card_detail_row.dart';

import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    return Directionality(
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
                      child: AvpImage(
                        image: AppAssets.iconMoreVertical20Gray700,
                        width: 20,
                        height: 20,
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
                      child: AvpImage(image: AppAssets.occupationCardBriefcase),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: .5,
              child: AvpImage(
                image: AppAssets.dividerCardGray200,
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(height: 8),
            AppOccupationCardDetailRow(value: title, label: 'عنوان'),
            const SizedBox(height: 8),
            AppOccupationCardDetailRow(value: description, label: 'شرح'),
          ],
        ),
      ),
    );
  }

  TextStyle _regularStyle(Color color) => AppTypography.bodySmall.copyWith(
    color: color,
    height: 18 / 12,
    letterSpacing: 0,
  );

  TextStyle _mediumStyle(Color color) =>
      _regularStyle(color).copyWith(fontWeight: FontWeight.w500);
}
