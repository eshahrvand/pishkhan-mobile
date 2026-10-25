import 'package:pishkhan_mobile/core/config/constant.dart';

import 'app_occupation_card_detail_row.dart';

import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

/// Figma occupation summary card used by the personal-information flow.
class AppOccupationCard extends StatelessWidget {
  const AppOccupationCard({
    super.key,
    this.title = 'طراح',
    this.description = 'UI / UX Designer',
    this.headerTitle,
    this.onMoreTap,
    this.titleLabel = 'عنوان',
    this.descriptionLabel = 'شرح',
    this.outlined = false,
  });

  final String titleLabel;
  final String descriptionLabel;
  final bool outlined;
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
        padding: EdgeInsets.symmetric(
          horizontal: outlined ? 15.2 : 16,
          vertical: outlined ? 11.2 : 12,
        ),
        decoration: BoxDecoration(
          color: outlined ? context.colors.surface : AppPalette.gray50,
          borderRadius: AppRadius.borderMd,
          boxShadow: outlined ? null : AppShadows.sm,
          border: outlined
              ? Border.all(color: AppPalette.gray200, width: .8)
              : null,
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
                        image:
                            '${AppConstants.baseImage}icon_more_vertical_20_gray700.svg',
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
                      child: AvpImage(
                        image:
                            '${AppConstants.baseImage}occupation_card_briefcase.svg',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: .5,
              child: AvpImage(
                image: '${AppConstants.baseImage}divider_card_gray200.svg',
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(height: 8),
            AppOccupationCardDetailRow(value: title, label: titleLabel),
            const SizedBox(height: 8),
            AppOccupationCardDetailRow(
              value: description,
              label: descriptionLabel,
            ),
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
