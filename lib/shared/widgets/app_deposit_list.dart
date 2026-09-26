import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Local Figma SVG assets used by [AppDepositList].
abstract final class AppDepositListIcons {
  static const _basePath = 'assets/images/deposit_list/';

  static Widget moreHorizontal() => _svg('more_horizontal.svg');
  static Widget deposit() => Transform.rotate(
    angle: math.pi,
    child: Transform.flip(flipY: true, child: _svg('deposit.svg')),
  );
  static Widget divider() => SizedBox(
    height: .5,
    width: double.infinity,
    child: SvgPicture.asset('${_basePath}divider.svg', fit: BoxFit.fill),
  );

  static Widget _svg(String name) => SizedBox(
    width: 20,
    height: 20,
    child: SvgPicture.asset('$_basePath$name', fit: BoxFit.contain),
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
  });

  final String title;
  final String accountNumber;
  final String statusLabel;
  final AppBadgeColor statusColor;
  final Widget? moreIcon;
  final Widget? depositIcon;
  final VoidCallback? onMoreTap;

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
                _header(context),
                const SizedBox(height: 8),
                AppDepositListIcons.divider(),
                const SizedBox(height: 8),
                _detailRow(
                  context,
                  leading: Text(
                    accountNumber,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.ltr,
                    style: _mediumStyle(colors.textPrimary),
                  ),
                  label: 'شماره سپرده',
                ),
                const SizedBox(height: 8),
                _detailRow(
                  context,
                  leading: AppBadge(
                    label: statusLabel,
                    color: statusColor,
                    background: AppBadgeBackground.light,
                    corner: AppBadgeCorner.rounded,
                  ),
                  label: 'وضعیت',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final colors = context.colors;
    final more = SizedBox(
      width: 20,
      height: 20,
      child: Center(child: moreIcon ?? AppDepositListIcons.moreHorizontal()),
    );
    return SizedBox(
      height: 20,
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          onMoreTap == null
              ? more
              : InkWell(
                  onTap: onMoreTap,
                  borderRadius: AppRadius.borderXs,
                  child: more,
                ),
          const Spacer(),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: _mediumStyle(colors.textPrimary),
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 20,
            height: 20,
            child: Center(child: depositIcon ?? AppDepositListIcons.deposit()),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    BuildContext context, {
    required Widget leading,
    required String label,
  }) => SizedBox(
    height: 22,
    child: Row(
      textDirection: TextDirection.ltr,
      children: [
        Flexible(child: leading),
        const Spacer(),
        Text(label, style: _regularStyle(context.colors.textSecondary)),
      ],
    ),
  );

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
