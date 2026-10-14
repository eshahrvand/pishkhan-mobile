import 'app_representative_card_status_line.dart';
import 'app_representative_card_detail_row.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import 'app_representative_cards.dart';

class AppRepresentativeCard extends StatelessWidget {
  const AppRepresentativeCard({
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
                        AppRepresentativeCardStatusLine(
                          secondary: secondary,
                          status: status,
                        ),
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
                    AppRepresentativeCardDetailRow(row: rows[index]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
