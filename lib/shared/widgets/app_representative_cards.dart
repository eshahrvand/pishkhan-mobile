import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_compact_status_badge.dart';

enum AppRepresentativeStatus { active, waiting, expired }

/// A representation granted to the current user.
class AppMeAsRepresentativeCard extends StatelessWidget {
  const AppMeAsRepresentativeCard({
    super.key,
    this.depositNumber = '۱.۲۳۴۵۶۷.۱',
    this.kind = 'صدور دسته چک',
    this.owner = 'بهار مبارک',
    this.validUntil = '۱۴۰۵/۰۶/۳۰',
    this.status = AppRepresentativeStatus.active,
    this.onMorePressed,
  });

  final String depositNumber;
  final String kind;
  final String owner;
  final String validUntil;
  final AppRepresentativeStatus status;
  final VoidCallback? onMorePressed;

  @override
  Widget build(BuildContext context) => _RepresentativeCard(
    key: const Key('app_me_as_representative_card'),
    title: depositNumber,
    status: status,
    onMorePressed: onMorePressed,
    rows: [
      (label: 'نوع نمایندگی', value: kind),
      (label: 'نام صاحب سپرده', value: owner),
      (label: 'تاریخ اعتبار', value: validUntil),
    ],
  );
}

/// A representation the current user has granted to another person.
class AppMyRepresentativeCard extends StatelessWidget {
  const AppMyRepresentativeCard({
    super.key,
    this.name = 'بهار مبارک',
    this.identityNumber = '۰۰۸۱۲۳۴۵۶۷',
    this.kind = 'صدور دسته چک',
    this.depositNumber = '۱.۲۳۴۵۶۷.۱',
    this.validUntil = '۱۴۰۵/۰۶/۳۰',
    this.status = AppRepresentativeStatus.active,
    this.onMorePressed,
  });

  final String name;
  final String identityNumber;
  final String kind;
  final String depositNumber;
  final String validUntil;
  final AppRepresentativeStatus status;
  final VoidCallback? onMorePressed;

  @override
  Widget build(BuildContext context) => _RepresentativeCard(
    key: const Key('app_my_representative_card'),
    title: name,
    secondary: identityNumber,
    status: status,
    onMorePressed: onMorePressed,
    rows: [
      (label: 'نوع نمایندگی', value: kind),
      (label: 'سپرده', value: depositNumber),
      (label: 'تاریخ اعتبار', value: validUntil),
    ],
  );
}

class _RepresentativeCard extends StatelessWidget {
  const _RepresentativeCard({
    super.key,
    required this.title,
    required this.status,
    required this.rows,
    required this.onMorePressed,
    this.secondary,
  });

  final String title;
  final String? secondary;
  final AppRepresentativeStatus status;
  final List<({String label, String value})> rows;
  final VoidCallback? onMorePressed;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
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
              child: Row(
                textDirection: TextDirection.ltr,
                children: [
                  SizedBox.square(
                    dimension: 48,
                    child: InkWell(
                      key: const Key('app_representative_more'),
                      onTap: onMorePressed,
                      borderRadius: AppRadius.borderSm,
                      child: Center(
                        child: SizedBox.square(
                          dimension: 20,
                          child: SvgPicture.asset(
                            AppAssets.representativeCardMoreVertical,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: _nameStyle,
                        ),
                        const SizedBox(height: 4),
                        _statusLine(),
                      ],
                    ),
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
                  for (var index = 0; index < rows.length; index++) ...[
                    if (index > 0) const SizedBox(height: 12),
                    _detailRow(rows[index]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusLine() {
    final badge = AppCompactStatusBadge(
      label: switch (status) {
        AppRepresentativeStatus.active => 'فعال',
        AppRepresentativeStatus.waiting => 'در انتظار تایید',
        AppRepresentativeStatus.expired => 'منقضی شده',
      },
      status: switch (status) {
        AppRepresentativeStatus.active => AppCompactStatus.success,
        AppRepresentativeStatus.waiting => AppCompactStatus.warning,
        AppRepresentativeStatus.expired => AppCompactStatus.error,
      },
    );
    if (secondary == null) {
      return Align(alignment: Alignment.centerRight, child: badge);
    }
    return Row(
      textDirection: TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        badge,
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            secondary!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.ltr,
            style: _subtitleStyle,
          ),
        ),
      ],
    );
  }

  Widget _detailRow(({String label, String value}) row) => SizedBox(
    height: 18,
    child: Row(
      textDirection: TextDirection.ltr,
      children: [
        Expanded(
          child: Text(row.value, textAlign: TextAlign.left, style: _valueStyle),
        ),
        Expanded(
          child: Text(
            row.label,
            textAlign: TextAlign.right,
            style: _labelStyle,
          ),
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
