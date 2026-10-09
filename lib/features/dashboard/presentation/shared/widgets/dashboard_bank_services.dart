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
    this.fixedServices = DashboardService.fixed,
    required this.onEdit,
    required this.onReset,
    required this.onAdd,
    required this.onRemove,
    required this.onConfirm,
    required this.onCancel,
    required this.onService,
    required this.onAllServices,
  });
  final DashboardState state;
  final List<DashboardService> fixedServices;
  final VoidCallback onEdit, onReset, onAdd, onConfirm, onCancel, onAllServices;
  final ValueChanged<String> onRemove;
  final ValueChanged<DashboardService> onService;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Container(
        key: const Key('dashboard_bank_services'),
        padding: const EdgeInsets.all(15.2),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: context.colors.borderSubtle, width: .8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.dashboardBankServices,
                    style: AppTypography.titleSmall.copyWith(
                      color: AppDashboardColors.sectionText,
                      height: 20 / 14,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                SizedBox(
                  width: 113 * MediaQuery.textScalerOf(context).scale(1),
                  height: 20,
                  child: AppButton(
                    key: const Key('dashboard_all_services'),
                    onPressed: onAllServices,
                    label: context.l10n.dashboardViewAll,
                    trailingIcon: SvgPicture.asset(
                      AppAssets.dashboardAllAngle,
                      width: 20,
                      height: 20,
                    ),
                    variant: AppButtonVariant.text,
                    horizontalPadding: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 306 ? 4 : 3;
                final width =
                    (constraints.maxWidth - (columns - 1) * 6) / columns;
                return Wrap(
                  spacing: 6,
                  runSpacing: 12,
                  children: [
                    for (final service in fixedServices)
                      SizedBox(
                        width: width,
                        child: Center(
                          child: AppServiceGridItemView(
                            tileColor: AppDashboardColors.tileSurface,
                            item: AppServiceGridItem(
                              id: service.id,
                              label: service.label(context.l10n),
                              icon: service == DashboardService.assistant
                                  ? const DashboardAssistantIcon()
                                  : SvgPicture.asset(
                                      service.fixedAsset,
                                      width: 32,
                                      height: 32,
                                    ),
                              onTap: () => onService(service),
                            ),
                            labelStyle: AppTypography.labelSmall.copyWith(
                              color: AppDashboardColors.serviceText,
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              height: 16 / 10,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      if (state.isEditing || state.favorites.isNotEmpty)
        _favorites(context)
      else
        CustomPaint(
          painter: const DashboardDashedBorder(
            color: AppDashboardColors.favoritesBorder,
            radius: 10,
            dash: 8,
            gap: 8,
          ),
          child: Container(
            key: const Key('dashboard_add_favorites'),
            height: 44,
            decoration: BoxDecoration(
              color: AppDashboardColors.favoritesSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: AppButton(
              key: const Key('dashboard_customize'),
              onPressed: onEdit,
              label: context.l10n.dashboardAddFavorites,
              foregroundColor: AppDashboardColors.favoritesAction,
              leadingIcon: SvgPicture.asset(
                AppAssets.dashboardAddFavorites,
                width: 20,
                height: 20,
              ),
              variant: AppButtonVariant.text,
              horizontalPadding: 8,
            ),
          ),
        ),
    ],
  );

  Widget _favorites(BuildContext context) => Container(
    key: const Key('dashboard_favorites_card'),
    padding: const EdgeInsets.all(15.2),
    decoration: BoxDecoration(
      color: AppDashboardColors.favoritesSurface,
      borderRadius: AppRadius.borderLg,
      border: Border.all(color: AppDashboardColors.favoritesBorder, width: .8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.dashboardYourFavorites,
                style: AppTypography.titleSmall.copyWith(
                  color: AppDashboardColors.sectionText,
                  height: 20 / 14,
                  letterSpacing: 0,
                ),
              ),
            ),
            if (state.isEditing && state.favorites.isNotEmpty)
              SizedBox(
                width: 20,
                height: 20,
                child: AppButton(
                  key: const Key('dashboard_reset'),
                  onPressed: onReset,
                  icon: SvgPicture.asset(
                    AppAssets.dashboardReset,
                    width: 20,
                    height: 20,
                  ),
                  variant: AppButtonVariant.text,
                  semanticLabel: context.l10n.dashboardResetTitle,
                ),
              )
            else if (!state.isEditing)
              SizedBox(
                width: 80 * MediaQuery.textScalerOf(context).scale(1),
                height: 20,
                child: AppButton(
                  key: const Key('dashboard_customize'),
                  onPressed: onEdit,
                  label: context.l10n.dashboardEdit,
                  foregroundColor: AppDashboardColors.favoritesAction,
                  leadingIcon: SvgPicture.asset(
                    AppAssets.dashboardEdit,
                    width: 20,
                    height: 20,
                  ),
                  variant: AppButtonVariant.text,
                  horizontalPadding: 2,
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        if (state.isEditing) ...[
          Container(
            key: const Key('dashboard_favorites_editor'),
            padding: const EdgeInsets.symmetric(
              horizontal: 7.2,
              vertical: 11.2,
            ),
            decoration: BoxDecoration(
              color: AppDashboardColors.editorSurface,
              border: Border.all(
                color: AppDashboardColors.editorBorder,
                width: .8,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _grid(context, editable: true),
                if (state.visibleFavorites.length ==
                    DashboardCubit.maxFavorites) ...[
                  const SizedBox(height: 12),
                  Container(
                    key: const Key('dashboard_favorites_limit'),
                    constraints: const BoxConstraints(minHeight: 40),
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      14,
                      10,
                      14,
                      10,
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
                            style: AppTypography.bodySmall.copyWith(
                              color: AppLoginColors.noticeText,
                              fontWeight: FontWeight.w500,
                              height: 18 / 12,
                              letterSpacing: 0,
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
                foregroundColor: context.colors.textSecondary,
                size: AppButtonSize.sm,
                variant: AppButtonVariant.text,
                horizontalPadding: 0,
              ),
            ],
          ),
        ] else
          _grid(context, editable: false),
      ],
    ),
  );

  Widget _grid(BuildContext context, {required bool editable}) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 274 ? 4 : 3;
      final width = (constraints.maxWidth - (columns - 1) * 6) / columns;
      final services = state.visibleFavorites
          .expand(
            (id) =>
                DashboardService.values.where((service) => service.id == id),
          )
          .toList();
      return Wrap(
        spacing: 6,
        runSpacing: 12,
        children: [
          for (final service in services)
            SizedBox(
              width: width,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AppServiceGridItemView(
                    width: width,
                    tileSize: editable ? 66 : 64,
                    usesIconTile: false,
                    item: AppServiceGridItem(
                      id: 'favorite-${service.id}',
                      label: service.label(context.l10n),
                      iconSize: Size.square(editable ? 66 : 64),
                      icon: DashboardServiceTile(
                        service: service,
                        editing: editable,
                      ),
                      onTap: editable ? null : () => onService(service),
                    ),
                    labelStyle: AppTypography.labelSmall.copyWith(
                      color: AppDashboardColors.serviceText,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      height: 16 / 10,
                      letterSpacing: 0,
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
          if (editable && services.length < DashboardCubit.maxFavorites)
            SizedBox(width: width, child: _add(context, width)),
        ],
      );
    },
  );

  Widget _add(BuildContext context, double width) => Semantics(
    button: true,
    label: context.l10n.dashboardAddService,
    child: InkWell(
      key: const Key('dashboard_add_service'),
      onTap: onAdd,
      borderRadius: AppRadius.borderMd,
      child: Column(
        children: [
          CustomPaint(
            painter: const DashboardDashedBorder(
              color: AppDashboardColors.addBorder,
              radius: 12,
              dash: 8,
              gap: 8,
            ),
            child: Container(
              width: 66,
              height: 66,
              decoration: const BoxDecoration(
                color: AppDashboardColors.addSurface,
                borderRadius: AppRadius.borderMd,
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppAssets.dashboardGreenPlus,
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: width,
            child: Text(
              context.l10n.dashboardAddService,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: AppDashboardColors.addText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 18 / 12,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

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
  bool shouldRepaint(DashboardDashedBorder old) =>
      color != old.color ||
      radius != old.radius ||
      dash != old.dash ||
      gap != old.gap;
}
