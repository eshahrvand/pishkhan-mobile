import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_service_tile.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_grid_card.dart';

class DashboardBankServices extends StatelessWidget {
  const DashboardBankServices({
    super.key,
    required this.state,
    required this.onEdit,
    required this.onReset,
    required this.onAdd,
    required this.onRemove,
    required this.onConfirm,
    required this.onCancel,
    required this.onService,
  });
  final DashboardState state;
  final VoidCallback onEdit, onReset, onAdd, onConfirm, onCancel;
  final ValueChanged<String> onRemove;
  final ValueChanged<DashboardService> onService;

  @override
  Widget build(BuildContext context) => AppServiceGridCard(
    key: const Key('dashboard_bank_services'),
    title: context.l10n.dashboardBankServices,
    itemSpacing: 6,
    footerSpacing: 16,
    type: AppServiceGridCardType.quick,
    headerAction: Semantics(
      button: true,
      label: state.isEditing
          ? context.l10n.dashboardResetTitle
          : context.l10n.dashboardCustomize,
      child: SvgPicture.asset(
        state.isEditing
            ? AppAssets.dashboardReset
            : AppAssets.serviceGridSetting,
        key: Key(state.isEditing ? 'dashboard_reset' : 'dashboard_customize'),
      ),
    ),
    onHeaderTap: state.isEditing ? onReset : onEdit,
    items: [
      for (final service in DashboardService.fixed)
        AppServiceGridItem(
          id: service.id,
          label: service.label(context.l10n),
          iconSize: const Size.square(64),
          icon: DashboardServiceTile(service: service, fixed: true),
          onTap: () => onService(service),
        ),
    ],
    footer: state.isEditing
        ? _editor(context)
        : state.favorites.isEmpty
        ? null
        : _favorites(context),
  );

  Widget _favorites(BuildContext context) => _row(context, editable: false);

  Widget _editor(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SizedBox(
        height: 0,
        child: OverflowBox(
          minHeight: .8,
          maxHeight: .8,
          child: Image.asset(
            AppAssets.dashboardEditDivider,
            height: .8,
            fit: BoxFit.fill,
          ),
        ),
      ),
      const SizedBox(height: 16),
      Text(
        context.l10n.dashboardYourFavorites,
        style: AppTypography.bodySmall.copyWith(
          color: context.colors.textTertiary,
          height: 18 / 12,
          letterSpacing: 0,
        ),
      ),
      const SizedBox(height: 12),
      CustomPaint(
        painter: DashboardDashedBorder(
          color: AppPalette.warning200,
          radius: 10,
        ),
        child: Container(
          key: const Key('dashboard_favorites_editor'),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: AppPalette.warning25,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              _row(context, editable: true),
              if (state.visibleFavorites.length == 4) ...[
                const SizedBox(height: 12),
                Container(
                  key: const Key('dashboard_favorites_limit'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceDisabled,
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppAssets.authInfoCircle,
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.l10n.dashboardFavoritesLimit,
                          textAlign: TextAlign.start,
                          style: AppTypography.bodySmall.copyWith(
                            height: 18 / 12,
                            letterSpacing: 0,
                            color: context.colors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      Row(
        textDirection: TextDirection.ltr,
        children: [
          SizedBox(
            width: 100,
            child: AppButton(
              key: const Key('dashboard_confirm'),
              onPressed: onConfirm,
              label: context.l10n.dashboardConfirm,
              size: AppButtonSize.sm,
            ),
          ),
          const SizedBox(width: 12),
          AppButton(
            key: const Key('dashboard_cancel'),
            onPressed: onCancel,
            label: context.l10n.dashboardCancel,
            variant: AppButtonVariant.text,
            size: AppButtonSize.sm,
          ),
        ],
      ),
    ],
  );

  Widget _row(BuildContext context, {required bool editable}) {
    final services = state.visibleFavorites
        .map(
          (id) =>
              DashboardService.values.firstWhere((service) => service.id == id),
        )
        .toList();
    final slots = <Widget>[
      for (final service in services)
        Expanded(
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AppServiceGridItemView(
                  usesIconTile: false,
                  item: AppServiceGridItem(
                    id: 'favorite-${service.id}',
                    label: service.label(context.l10n),
                    iconSize: const Size.square(64),
                    icon: DashboardServiceTile(
                      service: service,
                      editing: editable,
                      full: services.length == 4,
                    ),
                    onTap: editable ? null : () => onService(service),
                  ),
                ),
                if (editable)
                  Positioned(
                    left: 0,
                    top: -2,
                    child: Semantics(
                      button: true,
                      label:
                          '${context.l10n.dashboardRemoveService} ${service.label(context.l10n)}',
                      child: InkWell(
                        key: Key('dashboard_remove_${service.id}'),
                        onTap: () => onRemove(service.id),
                        child: SizedBox.square(
                          dimension: 20,
                          child: Center(
                            child: ClipOval(
                              child: SizedBox.square(
                                dimension: 16,
                                child: OverflowBox(
                                  maxWidth: 20,
                                  maxHeight: 20,
                                  child: SvgPicture.asset(
                                    AppAssets.dashboardMinus,
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      if (editable && services.length < 4)
        Expanded(child: Center(child: _add(context))),
      for (
        var i = services.length + (editable && services.length < 4 ? 1 : 0);
        i < 4;
        i++
      )
        const Expanded(child: SizedBox.shrink()),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < slots.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          slots[i],
        ],
      ],
    );
  }

  Widget _add(BuildContext context) => SizedBox(
    width: 72,
    child: Semantics(
      button: true,
      label: context.l10n.dashboardAddService,
      child: InkWell(
        key: const Key('dashboard_add_service'),
        onTap: onAdd,
        borderRadius: AppRadius.borderMd,
        child: Column(
          children: [
            CustomPaint(
              painter: DashboardDashedBorder(
                color: AppPalette.success300,
                radius: 12,
                dash: 8,
                gap: 8,
              ),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: context.colors.successSubtle,
                  borderRadius: AppRadius.borderMd,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppAssets.dashboardPlus,
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.dashboardAddService,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 12,
                height: 18 / 12,
                letterSpacing: 0,
                color: AppPalette.success500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Figma's dashed outline is a border, not a substituted icon asset.
class DashboardDashedBorder extends CustomPainter {
  const DashboardDashedBorder({
    required this.color,
    required this.radius,
    this.dash = 12,
    this.gap = 12,
  });
  final Color color;
  final double radius, dash, gap;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8;
    for (final metric in path.computeMetrics()) {
      for (double offset = 0; offset < metric.length; offset += dash + gap) {
        canvas.drawPath(metric.extractPath(offset, offset + dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(DashboardDashedBorder oldDelegate) =>
      color != oldDelegate.color ||
      radius != oldDelegate.radius ||
      dash != oldDelegate.dash ||
      gap != oldDelegate.gap;
}
