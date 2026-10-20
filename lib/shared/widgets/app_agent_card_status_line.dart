import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/widgets/app_compact_status_badge.dart';

import 'app_agent_cards.dart';

class AppAgentCardStatusLine extends StatelessWidget {
  const AppAgentCardStatusLine({
    super.key,
    required this.secondary,
    required this.status,
  });
  final String? secondary;
  final AppAgentStatus status;

  @override
  Widget build(BuildContext context) {
    final badge = AppCompactStatusBadge(
      label: switch (status) {
        AppAgentStatus.active => 'فعال',
        AppAgentStatus.waiting => 'در انتظار تایید',
        AppAgentStatus.expired => 'منقضی شده',
      },
      status: switch (status) {
        AppAgentStatus.active => AppCompactStatus.success,
        AppAgentStatus.waiting => AppCompactStatus.warning,
        AppAgentStatus.expired => AppCompactStatus.error,
      },
    );
    if (secondary == null) {
      return Row(
        textDirection: TextDirection.ltr,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [badge],
      );
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
