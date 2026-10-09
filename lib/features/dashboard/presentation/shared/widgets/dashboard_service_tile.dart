import 'package:pishkhan_mobile/shared/widgets/app_service_artwork_tile.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

class DashboardServiceTile extends StatelessWidget {
  const DashboardServiceTile({
    super.key,
    required this.service,
    this.fixed = false,
    this.editing = false,
    this.full = false,
  });
  final DashboardService service;
  final bool fixed, editing, full;

  @override
  Widget build(BuildContext context) {
    final asset = service.tileAsset(editing: editing, full: full);
    final tile = asset == null
        ? DecoratedBox(
            decoration: BoxDecoration(
              color: AppDashboardColors.tileSurface,
              borderRadius: AppRadius.borderMd,
              boxShadow: AppShadows.sm,
            ),
            child: ClipRRect(
              borderRadius: AppRadius.borderMd,
              child: SizedBox.square(
                dimension: 64,
                child: Stack(
                  children: [
                    Positioned(
                      left: .13,
                      top: 27.5,
                      width: 64,
                      height: 37,
                      child: SvgPicture.asset(AppAssets.dashboardTileWave),
                    ),
                    Center(
                      child: service == DashboardService.issueCheque
                          ? SizedBox.square(
                              dimension: 32,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 32 * .0836,
                                    top: 32 * .2083,
                                    right: 32 * .1432,
                                    bottom: 32 * .127,
                                    child: SvgPicture.asset(
                                      AppAssets.dashboardFavoriteChequeIcon,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SvgPicture.asset(
                              service.catalogAsset,
                              width: 32,
                              height: 32,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : AppServiceArtworkTile(asset: asset);
    if (!editing) return tile;
    return Container(
      width: 66,
      height: 66,
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppRadius.borderMd,
      ),
      child: tile,
    );
  }
}

typedef DashboardAssistantIcon = AppAssistantIcon;
