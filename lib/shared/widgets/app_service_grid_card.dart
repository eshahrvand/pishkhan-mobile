import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

/// The two Figma visual treatments for a service category card.
enum AppServiceGridCardType { service, quick }

/// Figma SVG assets used by [AppServiceGridCard] previews.
abstract final class AppServiceGridIcons {
  static Widget representativePurple() =>
      _svg(AppAssets.serviceGridRepresentativePurple);
  static Widget quickService() =>
      _svg(AppAssets.serviceGridQuickService, size: const Size(70, 70.5));
  static Widget quickAccess() =>
      _svg(AppAssets.serviceGridQuickAccess, size: const Size.square(20));
  static Widget angleLeft() =>
      _svg(AppAssets.iconAngleLeft20Gray700, size: const Size.square(20));

  static Widget _svg(String path, {Size size = const Size.square(32)}) =>
      SizedBox(
        width: size.width,
        height: size.height,
        child: SvgPicture.asset(path, fit: BoxFit.contain),
      );
}

/// Feature data and interaction supplied to [AppServiceGridCard].
@immutable
class AppServiceGridItem {
  const AppServiceGridItem({
    required this.id,
    required this.label,
    required this.icon,
    this.iconSize = const Size.square(32),
    this.onTap,
    this.enabled = true,
  });

  final String id;
  final String label;
  final Widget icon;
  final Size iconSize;
  final VoidCallback? onTap;
  final bool enabled;
}

/// App-owned, Figma-aligned RTL grid card for services and quick access.
class AppServiceGridCard extends StatelessWidget {
  const AppServiceGridCard({
    super.key,
    required this.title,
    required this.items,
    this.type = AppServiceGridCardType.service,
    this.headerAction,
    this.onHeaderTap,
    this.footer,
    this.itemSpacing = 0,
    this.footerSpacing = AppSpacing.mdLg,
  });

  final String title;
  final List<AppServiceGridItem> items;
  final AppServiceGridCardType type;
  final Widget? headerAction;
  final VoidCallback? onHeaderTap;
  final Widget? footer;
  final double itemSpacing;
  final double footerSpacing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final header = Row(
      children: [
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.start,
            style: AppTypography.titleSmall.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
              height: 20 / 14,
              letterSpacing: 0,
            ),
          ),
        ),
        if (headerAction != null) ...[
          const SizedBox(width: AppSpacing.sm),
          SizedBox(width: 20, height: 20, child: Center(child: headerAction)),
        ],
      ],
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.borderLg,
          boxShadow: AppShadows.sm,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: AppSpacing.paddingMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                onHeaderTap == null
                    ? header
                    : InkWell(
                        onTap: onHeaderTap,
                        borderRadius: AppRadius.borderSm,
                        child: header,
                      ),
                const SizedBox(height: AppSpacing.mdLg),
                if (items.length <= 4)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var index = 0; index < items.length; index++) ...[
                        if (index > 0) SizedBox(width: itemSpacing),
                        Expanded(
                          child: Center(
                            child: AppServiceGridItemView(
                              item: items[index],
                              usesIconTile:
                                  type == AppServiceGridCardType.service,
                            ),
                          ),
                        ),
                      ],
                    ],
                  )
                else
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 6,
                    runSpacing: AppSpacing.mdLg,
                    children: [
                      for (final item in items)
                        AppServiceGridItemView(
                          item: item,
                          usesIconTile: type == AppServiceGridCardType.service,
                        ),
                    ],
                  ),
                if (footer != null) ...[
                  SizedBox(height: footerSpacing),
                  footer!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppServiceGridItemView extends StatelessWidget {
  const AppServiceGridItemView({
    required this.item,
    this.usesIconTile = true,
    this.tileColor,
    this.labelStyle,
    super.key,
  });

  final AppServiceGridItem item;
  final bool usesIconTile;
  final Color? tileColor;

  /// Instance typography override for the Figma micro-service component.
  /// Derive overrides from [AppTypography] to retain the package font.
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          key: Key('app_service_grid_icon_${item.id}'),
          width: 64,
          height: 64,
          child: usesIconTile
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    color: tileColor ?? colors.surfaceSubtle,
                    borderRadius: AppRadius.borderMd,
                    boxShadow: AppShadows.sm,
                  ),
                  child: Center(child: _icon()),
                )
              : Center(child: _icon()),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: 72,
          child: Text(
            item.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall
                .copyWith(
                  color: colors.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  height: 16 / 10,
                  letterSpacing: 0,
                )
                .merge(labelStyle),
          ),
        ),
      ],
    );

    return Semantics(
      button: item.onTap != null,
      enabled: item.enabled,
      label: item.label,
      child: SizedBox(
        width: 72,
        child: InkWell(
          onTap: item.enabled ? item.onTap : null,
          borderRadius: AppRadius.borderMd,
          child: content,
        ),
      ),
    );
  }

  Widget _icon() => OverflowBox(
    maxWidth: item.iconSize.width,
    maxHeight: item.iconSize.height,
    child: SizedBox(
      width: item.iconSize.width,
      height: item.iconSize.height,
      child: Center(child: item.icon),
    ),
  );
}
