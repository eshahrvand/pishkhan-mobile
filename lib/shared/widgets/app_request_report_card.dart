import 'package:pishkhan_mobile/core/config/constant.dart';

import 'app_request_report_card_detail_row.dart';

import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

enum AppRequestReportCardType { standard, dashboard }

/// Figma request report card with an optional details row.
class AppRequestReportCard extends StatelessWidget {
  const AppRequestReportCard({
    super.key,
    this.title = 'تغییر سپرده جهت کسر اقساط',
    this.requestNumber = '۱۳۷/۴۸۷۵۶۷',
    this.details = 'درخواست تغییر سپرده جهت کسر اقساط',
    this.date = '۱۴۰۳/۱۱/۱۳  -  ۰۸:۱۲',
    this.statusLabel = 'لیبل',
    this.statusColor = AppBadgeColor.success,
    this.statusCorner = AppBadgeCorner.rounded,
    this.showDetails = true,
    this.width = 343,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    this.sectionSpacing = 8,
    this.footerSpacing = 8,
    this.headerHeight = 20,
    this.identifierLabel = 'شناسه:',
    this.detailsLabel = 'جزئیات:',
    this.type = AppRequestReportCardType.standard,
    this.divider,
    this.dividerHeight = .5,
    this.onMoreTap,
  });

  final String title;
  final String requestNumber;
  final String details;
  final String date;
  final String statusLabel;
  final AppBadgeColor statusColor;
  final AppBadgeCorner statusCorner;
  final bool showDetails;
  final double width;
  final EdgeInsetsGeometry contentPadding;
  final double sectionSpacing;
  final double footerSpacing;
  final double headerHeight;
  final String identifierLabel;
  final String detailsLabel;
  final AppRequestReportCardType type;
  final Widget? divider;
  final double dividerHeight;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        key: const Key('app_request_report_card'),
        width: width,
        padding: contentPadding,
        decoration: type == AppRequestReportCardType.dashboard
            ? BoxDecoration(
                color: context.colors.surface,
                border: Border.all(
                  color: context.colors.surface.withValues(alpha: .8),
                ),
                borderRadius: AppRadius.borderLg,
                boxShadow: AppShadows.sm,
              )
            : BoxDecoration(
                color: AppPalette.gray25,
                border: Border.all(color: AppPalette.gray200),
                borderRadius: AppRadius.borderMd,
              ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: headerHeight,
              child: Row(
                textDirection: TextDirection.ltr,
                children: [
                  InkWell(
                    key: const Key('app_request_report_more'),
                    onTap: onMoreTap,
                    child: Transform.rotate(
                      angle: math.pi / 2,
                      child: AvpImage(
                        image:
                            '${AppConstants.baseImage}icon_more_vertical_20_gray700.svg',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: _titleStyle,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: sectionSpacing),
            SizedBox(
              height: dividerHeight,
              child:
                  divider ??
                  AvpImage(
                    image: '${AppConstants.baseImage}divider_card_gray200.svg',
                    fit: BoxFit.fill,
                  ),
            ),
            SizedBox(height: sectionSpacing),
            AppRequestReportCardDetailRow(
              value: requestNumber,
              label: identifierLabel,
            ),
            if (showDetails) ...[
              SizedBox(height: sectionSpacing),
              AppRequestReportCardDetailRow(
                value: details,
                label: detailsLabel,
              ),
            ],
            SizedBox(height: footerSpacing),
            SizedBox(
              height: 22,
              child: Row(
                textDirection: TextDirection.ltr,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppBadge(
                    label: statusLabel,
                    color: statusColor,
                    background: AppBadgeBackground.light,
                    size: AppBadgeSize.small,
                    corner: statusCorner,
                  ),
                  Flexible(
                    child: Text(
                      date,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: _mediumStyle(AppPalette.gray700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _titleStyle => AppTypography.bodySmall.copyWith(
    color: AppPalette.gray900,
    fontWeight: FontWeight.w600,
    height: 18 / 12,
    letterSpacing: 0,
  );

  TextStyle _regularStyle(Color color) => AppTypography.bodySmall.copyWith(
    color: color,
    height: 18 / 12,
    letterSpacing: 0,
  );

  TextStyle _mediumStyle(Color color) =>
      _regularStyle(color).copyWith(fontWeight: FontWeight.w500);
}
