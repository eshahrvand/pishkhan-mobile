import 'package:flutter_bloc/flutter_bloc.dart';

import 'dashboard_dashed_border.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/home_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_service_tile.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_grid_card.dart';

class DashboardFavoritesGrid extends StatelessWidget {
  const DashboardFavoritesGrid({
    super.key,
    required this.editable,
    required this.onAdd,
    required this.onRemove,
    required this.onService,
  });
  final bool editable;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final ValueChanged<DashboardService> onService;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.favoriteServices != current.favoriteServices ||
          previous.canAddFavorite != current.canAddFavorite,
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 274 ? 4 : 3;
            final width = (constraints.maxWidth - (columns - 1) * 6) / columns;
            return Wrap(
              spacing: 6,
              runSpacing: 12,
              children: [
                for (final service in state.favoriteServices)
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
                            label: service.label(),
                            iconSize: Size.square(editable ? 66 : 64),
                            icon: DashboardServiceTile(
                              service: service,
                              editing: editable,
                            ),
                            onTap: editable ? null : () => onService(service),
                          ),
                          labelStyle: AppTypography.caption.copyWith(
                            color: AppDashboardColors.serviceText,
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
                                  '${S.current.dashboardRemoveService} ${service.label()}',
                              child: InkWell(
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
                                          child: AvpImage(
                                            image: AppAssets.dashboardMinus,
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
                if (editable && state.canAddFavorite)
                  SizedBox(
                    width: width,
                    child: Semantics(
                      button: true,
                      label: S.current.dashboardAddService,
                      child: InkWell(
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
                                  child: AvpImage(
                                    image: AppAssets.dashboardGreenPlus,
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
                                S.current.dashboardAddService,
                                textAlign: TextAlign.center,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppDashboardColors.addText,
                                  fontWeight: FontWeight.w500,
                                  height: 18 / 12,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
