import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_assets.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    this.onMenuPressed,
    this.onProfilePressed,
    this.onNotificationsPressed,
  });

  final VoidCallback? onMenuPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onNotificationsPressed;

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('dashboard_header'),
    height: 64,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: context.colors.surface,
      boxShadow: AppShadows.sm,
    ),
    child: Row(
      textDirection: TextDirection.ltr,
      children: [
        _HeaderAction(
          asset: DashboardAssets.headerUser,
          tooltip: context.l10n.profileLabel,
          onPressed: onProfilePressed,
        ),
        _HeaderAction(
          asset: DashboardAssets.headerBell,
          tooltip: context.l10n.notificationsLabel,
          onPressed: onNotificationsPressed,
        ),
        Expanded(
          child: Text(
            context.l10n.appTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.titleSmall.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
              height: 20 / 14,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 40),
        _HeaderAction(
          key: const Key('dashboard_menu_button'),
          asset: DashboardAssets.headerMenu,
          tooltip: context.l10n.servicesMenuLabel,
          onPressed: onMenuPressed,
        ),
      ],
    ),
  );
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.asset,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final String asset;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 40,
    child: IconButton(
      onPressed: onPressed ?? () {},
      padding: const EdgeInsets.all(8),
      tooltip: tooltip,
      icon: SvgPicture.asset(asset, width: 24, height: 24),
    ),
  );
}
