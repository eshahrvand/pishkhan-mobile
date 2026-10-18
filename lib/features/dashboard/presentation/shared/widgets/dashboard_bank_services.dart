import 'package:flutter_bloc/flutter_bloc.dart';

import 'dashboard_favorites_card.dart';
import 'dashboard_dashed_border.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/home_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_grid_card.dart';

class DashboardBankServices extends StatelessWidget {
  const DashboardBankServices({
    super.key,
    required this.onEdit,
    required this.onReset,
    required this.onAdd,
    required this.onRemove,
    required this.onConfirm,
    required this.onCancel,
    required this.onService,
    required this.onAllServices,
  });
  final VoidCallback onEdit, onReset, onAdd, onConfirm, onCancel, onAllServices;
  final ValueChanged<DashboardService> onRemove;
  final ValueChanged<DashboardService> onService;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.isEditingFavorites != current.isEditingFavorites ||
          previous.homeData != current.homeData ||
          previous.favoriteServices != current.favoriteServices,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(15.2),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: AppRadius.borderLg,
                border: Border.all(
                  color: context.colors.borderSubtle,
                  width: .8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          S.current.dashboardBankServices,
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
                          onPressed: onAllServices,
                          label: S.current.dashboardViewAll,
                          trailingIcon: AvpImage(
                            image: AppAssets.dashboardAllAngle,
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
                          for (final service in state.fixedServices)
                            SizedBox(
                              width: width,
                              child: Center(
                                child: AppServiceGridItemView(
                                  tileColor: AppDashboardColors.tileSurface,
                                  item: AppServiceGridItem(
                                    id: service.id,
                                    label: service.label(),
                                    icon: service == DashboardService.assistant
                                        ? const AppAssistantIcon()
                                        : AvpImage(
                                            image: service.fixedAsset,
                                            width: 32,
                                            height: 32,
                                          ),
                                    onTap: () => onService(service),
                                  ),
                                  labelStyle: AppTypography.caption.copyWith(
                                    color: AppDashboardColors.serviceText,
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
            if (state.isEditingFavorites ||
                (state.homeData?.favorites ?? const <String>[]).isNotEmpty)
              DashboardFavoritesCard(
                state: state,
                onEdit: onEdit,
                onReset: onReset,
                onAdd: onAdd,
                onRemove: onRemove,
                onConfirm: onConfirm,
                onCancel: onCancel,
                onService: onService,
              )
            else
              CustomPaint(
                painter: const DashboardDashedBorder(
                  color: AppDashboardColors.favoritesBorder,
                  radius: 10,
                  dash: 8,
                  gap: 8,
                ),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppDashboardColors.favoritesSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AppButton(
                    onPressed: onEdit,
                    label: S.current.dashboardAddFavorites,
                    foregroundColor: AppDashboardColors.favoritesAction,
                    leadingIcon: AvpImage(
                      image: AppAssets.dashboardAddFavorites,
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
      },
    );
  }
}
