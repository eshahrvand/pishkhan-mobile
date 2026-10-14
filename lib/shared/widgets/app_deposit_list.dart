import 'app_deposit_list_header.dart';
import 'app_deposit_list_detail_row.dart';

import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

/// Local Figma SVG assets used by [AppDepositList].
abstract final class AppDepositListIcons {
  // The exported source asset is vertical; Figma rotates it -90° for this
  // card's physical-left horizontal overflow affordance.
  static Widget moreHorizontal() => Transform.rotate(
    angle: -math.pi / 2,
    child: _svg(AppAssets.iconMoreVertical20Gray700),
  );
  static Widget deposit() => Transform.rotate(
    angle: math.pi,
    child: Transform.flip(
      flipY: true,
      child: _svg(AppAssets.depositListDeposit),
    ),
  );
  static Widget divider() => SizedBox(
    height: .5,
    width: double.infinity,
    child: SvgPicture.asset(AppAssets.dividerCardGray200, fit: BoxFit.fill),
  );

  static Widget _svg(String path) => SizedBox(
    width: 20,
    height: 20,
    child: SvgPicture.asset(path, fit: BoxFit.contain),
  );
}

/// App-owned, Figma-aligned item for a customer's deposit list.
class AppDepositList extends StatelessWidget {
  const AppDepositList({
    super.key,
    required this.title,
    required this.accountNumber,
    this.statusLabel = 'باز',
    this.statusColor = AppBadgeColor.success,
    this.moreIcon,
    this.depositIcon,
    this.onMoreTap,
    this.accountNumberLabel = 'شماره سپرده',
    this.statusFieldLabel = 'وضعیت',
    this.divider,
    this.alignContentToEdges = false,
  });

  final String title;
  final String accountNumber;
  final String statusLabel;
  final AppBadgeColor statusColor;
  final Widget? moreIcon;
  final Widget? depositIcon;
  final VoidCallback? onMoreTap;
  final String accountNumberLabel, statusFieldLabel;
  final Widget? divider;
  final bool alignContentToEdges;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceSubtle,
          borderRadius: AppRadius.borderMd,
          boxShadow: AppShadows.sm,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppDepositListHeader(
                  alignContentToEdges: alignContentToEdges,
                  depositIcon: depositIcon,
                  moreIcon: moreIcon,
                  onMoreTap: onMoreTap,
                  title: title,
                ),
                const SizedBox(height: 8),
                divider ?? AppDepositListIcons.divider(),
                const SizedBox(height: 8),
                AppDepositListDetailRow(
                  leading: Text(
                    accountNumber,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.ltr,
                    style: _mediumStyle(colors.textPrimary),
                  ),
                  label: accountNumberLabel,
                  alignContentToEdges: alignContentToEdges,
                ),
                const SizedBox(height: 8),
                AppDepositListDetailRow(
                  leading: AppBadge(
                    label: statusLabel,
                    color: statusColor,
                    background: AppBadgeBackground.light,
                    corner: AppBadgeCorner.rounded,
                  ),
                  label: statusFieldLabel,
                  alignContentToEdges: alignContentToEdges,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _regularStyle(Color color) => AppTypography.bodySmall.copyWith(
    color: color,
    height: 18 / 12,
    letterSpacing: 0,
  );

  TextStyle _mediumStyle(Color color) => AppTypography.bodySmall.copyWith(
    color: color,
    fontWeight: FontWeight.w500,
    height: 18 / 12,
    letterSpacing: 0,
  );
}
