import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    this.onMenuPressed,
    this.trailingIcon,
    this.trailingTooltip,
    this.onTrailingPressed,
    this.title,
    this.showLeadingActions = true,
    this.leadingAction,
    this.onProfilePressed,
    this.onNotificationsPressed,
  });

  final VoidCallback? onMenuPressed;
  final String? title;
  final Widget? trailingIcon;
  final String? trailingTooltip;
  final VoidCallback? onTrailingPressed;
  final bool showLeadingActions;
  final Widget? leadingAction;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onNotificationsPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('dashboard_header'),
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          bottom: BorderSide(color: context.colors.border, width: .8),
        ),
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          if (leadingAction != null)
            leadingAction!
          else if (showLeadingActions) ...[
            _HeaderAction(
              asset: AppAssets.dashboardHeaderUser,
              tooltip: S.current.profileLabel,
              onPressed: onProfilePressed,
            ),
            _HeaderAction(
              asset: AppAssets.dashboardHeaderBell,
              tooltip: S.current.notificationsLabel,
              onPressed: onNotificationsPressed,
            ),
          ] else
            const SizedBox(width: 80),
          Expanded(
            child: Text(
              title ?? S.current.appTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: AppTypography.titleSmall.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w600,
                height: 20 / 14,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 4),
          _HeaderAction(
            key: const Key('dashboard_menu_button'),
            dimension: 40,
            asset: AppAssets.dashboardHeaderMenu,
            icon: trailingIcon,
            tooltip: trailingTooltip ?? S.current.servicesMenuLabel,
            onPressed: onTrailingPressed ?? onMenuPressed,
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.asset,
    required this.tooltip,
    required this.onPressed,
    super.key,
    this.dimension = 40,
    this.icon,
  });

  final double dimension;
  final String asset;
  final Widget? icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: dimension,
      child: AppButton(
        onPressed: onPressed ?? () {},
        variant: AppButtonVariant.text,
        tooltip: tooltip,
        icon: icon ?? SvgPicture.asset(asset, width: 24, height: 24),
      ),
    );
  }
}
