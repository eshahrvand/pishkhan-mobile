import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/widgets/app_compact_status_badge.dart';

enum AppConfirmerStatus { approved, waiting }

/// Figma confirmer/person details card.
class AppConfirmerDetailsCard extends StatelessWidget {
  const AppConfirmerDetailsCard({
    super.key,
    this.name = 'بهار مبارک',
    this.phoneNumber = '۰۰۸۱۲۳۴۵۶۷',
    this.role = 'معرف',
    this.depositRelation = 'صاحب سپرده و امضا',
    this.sharePercentage = '۴۰٪',
    this.status = AppConfirmerStatus.approved,
    this.approvedLabel = 'در انتظار تایید',
    this.waitingLabel = 'در انتظار تایید',
  });

  final String name;
  final String phoneNumber;
  final String role;
  final String depositRelation;
  final String sharePercentage;
  final AppConfirmerStatus status;
  final String approvedLabel;
  final String waitingLabel;

  @override
  Widget build(BuildContext context) {
    final isWaiting = status == AppConfirmerStatus.waiting;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        key: const Key('app_confirmer_details_card'),
        width: 343,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: AppRadius.borderLg),
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: context.colors.borderSubtle),
          borderRadius: AppRadius.borderLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 76,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              color: AppPalette.gray25,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(name, textAlign: TextAlign.right, style: _nameStyle),
                  const SizedBox(height: 4),
                  Row(
                    textDirection: TextDirection.ltr,
                    children: [
                      AppCompactStatusBadge(
                        label: isWaiting ? waitingLabel : approvedLabel,
                        status: isWaiting
                            ? AppCompactStatus.warning
                            : AppCompactStatus.success,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          phoneNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.ltr,
                          style: _subtitleStyle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 118,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              color: context.colors.surfaceSubtle,
              child: Column(
                children: [
                  _detailRow(value: role, label: 'نقش'),
                  const SizedBox(height: 12),
                  _detailRow(value: depositRelation, label: 'ارتباط با سپرده'),
                  const SizedBox(height: 12),
                  _detailRow(value: sharePercentage, label: 'درصد اشتراک'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow({required String value, required String label}) => SizedBox(
    height: 18,
    child: Row(
      textDirection: TextDirection.ltr,
      children: [
        Expanded(
          child: Text(value, textAlign: TextAlign.left, style: _valueStyle),
        ),
        Expanded(
          child: Text(label, textAlign: TextAlign.right, style: _labelStyle),
        ),
      ],
    ),
  );

  TextStyle get _nameStyle => AppTypography.titleSmall.copyWith(
    color: const Color(0xFF181D27),
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 20 / 14,
    letterSpacing: 0,
  );

  TextStyle get _subtitleStyle => AppTypography.bodyMedium.copyWith(
    color: AppPalette.gray700,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    letterSpacing: 0,
  );

  TextStyle get _valueStyle => AppTypography.bodySmall.copyWith(
    color: const Color(0xFF181D27),
    fontWeight: FontWeight.w500,
    height: 18 / 12,
    letterSpacing: 0,
  );

  TextStyle get _labelStyle => AppTypography.bodySmall.copyWith(
    color: const Color(0xFF181D27),
    height: 18 / 12,
    letterSpacing: 0,
  );
}
