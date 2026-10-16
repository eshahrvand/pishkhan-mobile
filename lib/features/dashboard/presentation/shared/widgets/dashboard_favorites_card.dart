import 'package:flutter_bloc/flutter_bloc.dart';

import 'dashboard_favorites_grid.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/home_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

class DashboardFavoritesCard extends StatelessWidget {
  const DashboardFavoritesCard({
    super.key,
    required this.onEdit,
    required this.onReset,
    required this.onAdd,
    required this.onRemove,
    required this.onConfirm,
    required this.onCancel,
    required this.onService,
  });
  final VoidCallback onEdit;
  final VoidCallback onReset;
  final VoidCallback onAdd;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final ValueChanged<String> onRemove;
  final ValueChanged<DashboardService> onService;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.draft != current.draft ||
          previous.homeData != current.homeData ||
          previous.isFavoritesLimitReached != current.isFavoritesLimitReached,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(15.2),
          decoration: BoxDecoration(
            color: AppDashboardColors.favoritesSurface,
            borderRadius: AppRadius.borderLg,
            border: Border.all(
              color: AppDashboardColors.favoritesBorder,
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
                      S.current.dashboardYourFavorites,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppDashboardColors.sectionText,
                        height: 20 / 14,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  if (state.draft != null &&
                      (state.homeData?.favorites ?? const <String>[])
                          .isNotEmpty)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: AppButton(
                        onPressed: onReset,
                        icon: AvpImage(
                          image: AppAssets.dashboardReset,
                          width: 20,
                          height: 20,
                        ),
                        variant: AppButtonVariant.text,
                        semanticLabel: S.current.dashboardResetTitle,
                      ),
                    )
                  else if (state.draft == null)
                    SizedBox(
                      width: 80 * MediaQuery.textScalerOf(context).scale(1),
                      height: 20,
                      child: AppButton(
                        onPressed: onEdit,
                        label: S.current.dashboardEdit,
                        foregroundColor: AppDashboardColors.favoritesAction,
                        leadingIcon: AvpImage(
                          image: AppAssets.dashboardEdit,
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
              if (state.draft != null) ...[
                Container(
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
                      DashboardFavoritesGrid(
                        editable: true,
                        onAdd: onAdd,
                        onRemove: onRemove,
                        onService: onService,
                      ),
                      if (state.isFavoritesLimitReached) ...[
                        const SizedBox(height: 12),
                        Container(
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
                              AvpImage(
                                image: AppAssets.authInfoCircle,
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  S.current.dashboardFavoritesLimit,
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
                        onPressed: onConfirm,
                        label: S.current.dashboardConfirm,
                        size: AppButtonSize.sm,
                      ),
                    ),
                    const SizedBox(width: 12),
                    AppButton(
                      onPressed: onCancel,
                      label: S.current.dashboardCancel,
                      foregroundColor: context.colors.textSecondary,
                      size: AppButtonSize.sm,
                      variant: AppButtonVariant.text,
                      horizontalPadding: 0,
                    ),
                  ],
                ),
              ] else
                DashboardFavoritesGrid(
                  editable: false,
                  onAdd: onAdd,
                  onRemove: onRemove,
                  onService: onService,
                ),
            ],
          ),
        );
      },
    );
  }
}
