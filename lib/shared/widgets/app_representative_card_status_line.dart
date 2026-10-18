import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/widgets/app_compact_status_badge.dart';

import 'app_representative_cards.dart';

class AppRepresentativeCardStatusLine extends StatelessWidget {
  const AppRepresentativeCardStatusLine({
    super.key,
    required this.secondary,
    required this.status,
  });
  final String? secondary;
  final AppRepresentativeStatus status;

  @override
  Widget build(BuildContext context) {
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

  TextStyle get _subtitleStyle => AppTypography.bodyMedium.copyWith(
    color: AppPalette.gray700,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    letterSpacing: 0,
  );
}
