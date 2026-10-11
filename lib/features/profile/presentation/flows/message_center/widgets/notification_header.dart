import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

class NotificationHeader extends StatelessWidget {
  const NotificationHeader({super.key, this.title, this.action});
  final String? title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Container(
    height: 64,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: context.colors.surface,
      border: Border(
        bottom: BorderSide(color: context.colors.border, width: .8),
      ),
    ),
    child: Row(
      children: [
        SizedBox.square(
          dimension: 24,
          child: IconButton(
            key: const Key('notification_back'),
            padding: EdgeInsets.zero,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => Navigator.of(context).maybePop(),
            icon: SvgPicture.asset(AppAssets.notificationBack),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: title == null
              ? const SizedBox.shrink()
              : Text(
                  title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleSmall.copyWith(
                    color: context.colors.textPrimary,
                    height: 20 / 14,
                    letterSpacing: 0,
                  ),
                ),
        ),
        ?action,
      ],
    ),
  );
}
