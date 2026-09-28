import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    this.showDetails = true,
    this.onMoreTap,
  });

  final String title;
  final String requestNumber;
  final String details;
  final String date;
  final String statusLabel;
  final AppBadgeColor statusColor;
  final bool showDetails;
  final VoidCallback? onMoreTap;

  static const _assetPath = 'assets/images/request_report_card/';

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Container(
      key: const Key('app_request_report_card'),
      width: 343,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppPalette.gray25,
        border: Border.all(color: AppPalette.gray200),
        borderRadius: AppRadius.borderMd,
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
                  key: const Key('app_request_report_more'),
                  onTap: onMoreTap,
                  child: Transform.rotate(
                    angle: math.pi / 2,
                    child: SvgPicture.asset('${_assetPath}more_horizontal.svg'),
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
          const SizedBox(height: 8),
          SizedBox(
            height: .5,
            child: SvgPicture.asset(
              '${_assetPath}divider.svg',
              fit: BoxFit.fill,
            ),
          ),
          const SizedBox(height: 8),
          _detailRow(value: requestNumber, label: 'شناسه:'),
          if (showDetails) ...[
            const SizedBox(height: 8),
            _detailRow(value: details, label: 'جزئیات:'),
          ],
          const SizedBox(height: 8),
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
                  corner: AppBadgeCorner.rounded,
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
            textAlign: TextAlign.left,
            style: _mediumStyle(AppPalette.gray900),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: _regularStyle(AppPalette.gray700)),
      ],
    ),
  );

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
