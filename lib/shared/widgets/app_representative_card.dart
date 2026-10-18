import 'app_representative_card_status_line.dart';
import 'app_representative_card_detail_row.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import 'app_representative_cards.dart';

class AppRepresentativeCard extends StatelessWidget {
  const AppRepresentativeCard({
    super.key,
    required this.title,
    this.status,
    required this.rows,
    required this.onMorePressed,
    this.secondary,
    this.actionIcon,
    this.actionLabel,
    this.actionAlignment = Alignment.center,
    this.bodyColor,
    this.detailLabelColor,
  });

  final String title;
  final String? secondary;
  final AppRepresentativeStatus? status;
  final List<({String label, String value})> rows;
  final VoidCallback? onMorePressed;
  final Widget? actionIcon;
  final String? actionLabel;
  final AlignmentGeometry actionAlignment;
  final Color? bodyColor, detailLabelColor;

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
                    child: Semantics(
                      label: actionLabel,
                      button: true,
                      child: InkWell(
                        key: const Key('app_representative_more'),
                        onTap: onMorePressed,
                        borderRadius: AppRadius.borderSm,
                        child: Align(
                          alignment: actionAlignment,
                          child: SizedBox.square(
                            dimension: 20,
                            child:
                                actionIcon ??
                                AvpImage(
                                  image:
                                      AppAssets.representativeCardMoreVertical,
                                  fit: BoxFit.contain,
                                ),
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
                        if (status == null)
                          Text(
                            secondary ?? '',
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: context.colors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                  height: 20 / 14,
                                ),
                          )
                        else
                          AppRepresentativeCardStatusLine(
                            secondary: secondary,
                            status: status!,
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
              color: bodyColor ?? context.colors.surfaceSubtle,
              child: Column(
                children: [
                  for (var index = 0; index < rows.length; index++) ...[
                    if (index > 0) const SizedBox(height: 12),
                    AppRepresentativeCardDetailRow(
                      row: rows[index],
                      labelColor: detailLabelColor,
                    ),
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
}
