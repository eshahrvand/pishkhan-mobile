import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_grid_card.dart';

Future<DashboardService?> showDashboardServicesSheet(
  BuildContext context, {
  Set<String> excluded = const {},
  List<DashboardService>? category,
}) => showModalBottomSheet<DashboardService>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: Colors.transparent,
  barrierColor: context.colors.textSecondary.withValues(alpha: .65),
  builder: (_) =>
      DashboardServicesSheet(excluded: excluded, category: category),
);

class DashboardServicesSheet extends StatefulWidget {
  const DashboardServicesSheet({
    super.key,
    this.excluded = const {},
    this.category,
  });
  final Set<String> excluded;
  final List<DashboardService>? category;

  @override
  State<DashboardServicesSheet> createState() => _DashboardServicesSheetState();
}

class _DashboardServicesSheetState extends State<DashboardServicesSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final groups = [
      (
        l10n.depositServices,
        DashboardService.deposits,
        AppAssets.dashboardDepositDivider,
      ),
      (
        l10n.cardServices,
        DashboardService.cards,
        AppAssets.dashboardCardDivider,
      ),
      (
        l10n.loanServices,
        DashboardService.loans,
        AppAssets.dashboardLoanDivider,
      ),
    ];
    final visible = groups
        .map(
          (group) => (
            group.$1,
            group.$2
                .where(
                  (service) =>
                      (widget.category == null ||
                          widget.category!.contains(service)) &&
                      service
                          .label(l10n)
                          .replaceAll('\u200c', ' ')
                          .contains(_query),
                )
                .toList(),
            group.$3,
          ),
        )
        .where((group) => group.$2.isNotEmpty)
        .toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .82,
          ),
          child: Material(
            key: const Key('dashboard_services_sheet'),
            color: context.colors.surfaceSubtle,
            borderRadius: const BorderRadius.vertical(top: AppRadius.xl),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBottomSheetHeader(
                    title: l10n.servicesList,
                    showRightIcon: false,
                    leftIcon: SvgPicture.asset(AppAssets.iconClose24Gray700),
                    onLeftAction: () => Navigator.of(context).pop(),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppSearchField(
                            key: const Key('dashboard_service_search'),
                            hintText: l10n.dashboardSearchHint,
                            textStyle: AppTypography.bodyMedium.copyWith(
                              height: 20 / 14,
                              letterSpacing: 0,
                            ),
                            searchIcon: SizedBox(
                              width: 48,
                              height: 44,
                              child: Center(
                                child: SizedBox.square(
                                  dimension: 20,
                                  child: SvgPicture.asset(
                                    AppAssets.dashboardCatalogSearch,
                                  ),
                                ),
                              ),
                            ),
                            focusRing: AppTextFieldFocusRing.subtle,
                            onChanged: (value) => setState(
                              () => _query = value.trim().replaceAll(
                                '\u200c',
                                ' ',
                              ),
                            ),
                          ),
                          if (visible.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: Text(
                                l10n.dashboardNoServices,
                                style: AppTypography.bodyMedium,
                              ),
                            ),
                          for (final group in visible) ...[
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Text(
                                  group.$1,
                                  style: AppTypography.titleSmall.copyWith(
                                    height: 20 / 14,
                                    letterSpacing: 0,
                                    color: context.colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SvgPicture.asset(
                                    group.$3,
                                    height: 1,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            LayoutBuilder(
                              builder: (context, constraints) => Wrap(
                                spacing: 0,
                                runSpacing: 16,
                                children: [
                                  for (final service in group.$2)
                                    SizedBox(
                                      width: constraints.maxWidth / 4,
                                      child: Center(
                                        child: AppServiceGridItemView(
                                          tileColor: AppPalette.gray25,
                                          item: AppServiceGridItem(
                                            id: 'catalog-${service.id}',
                                            label: service.label(l10n),
                                            icon: SvgPicture.asset(
                                              service.catalogAsset,
                                            ),
                                            enabled: !widget.excluded.contains(
                                              service.id,
                                            ),
                                            onTap: () =>
                                                Navigator.of(context)
                                                    .pop(service),
                                          ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool?> showDashboardResetSheet(BuildContext context) =>
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: context.colors.textSecondary.withValues(alpha: .65),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Material(
          key: const Key('dashboard_reset_sheet'),
          color: context.colors.surfaceSubtle,
          borderRadius: const BorderRadius.vertical(top: AppRadius.xl),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBottomSheetHeader(
                  title: context.l10n.dashboardResetTitle,
                  showRightIcon: false,
                  showLeftAction: false,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Text(
                    context.l10n.dashboardResetDescription,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 20 / 14,
                      letterSpacing: 0,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Row(
                    textDirection: TextDirection.ltr,
                    children: [
                      Expanded(
                        child: AppButton(
                          key: const Key('dashboard_reset_confirm'),
                          onPressed: () => Navigator.of(context).pop(true),
                          label: context.l10n.dashboardResetConfirm,
                          size: AppButtonSize.lg,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          key: const Key('dashboard_reset_cancel'),
                          onPressed: () => Navigator.of(context).pop(false),
                          label: context.l10n.dashboardCancel,
                          variant: AppButtonVariant.secondaryGray,
                          size: AppButtonSize.lg,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
