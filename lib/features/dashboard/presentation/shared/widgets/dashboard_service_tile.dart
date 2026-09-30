import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

/// The exact Figma service artwork, including the tile's exported shadow.
class DashboardServiceTile extends StatelessWidget {
  const DashboardServiceTile({
    super.key,
    required this.service,
    this.fixed = false,
    this.editing = false,
    this.full = false,
  });
  final DashboardService service;
  final bool fixed;
  final bool editing;
  final bool full;

  @override
  Widget build(BuildContext context) {
    final asset = service.tileAsset(fixed: fixed, editing: editing, full: full);
    if (asset != null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadius.borderMd,
          boxShadow: AppShadows.sm,
        ),
        child: SizedBox.square(
          dimension: 64,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(left: -3, top: -2, child: SvgPicture.asset(asset)),
            ],
          ),
        ),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.gray25,
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
                left: service == DashboardService.assistant ? -.38 : .38,
                top: 27.5,
                width: 64,
                height: 37,
                child: SvgPicture.asset(AppAssets.dashboardTileWave),
              ),
              Center(
                child: service == DashboardService.assistant
                    ? const DashboardAssistantIcon()
                    : service == DashboardService.sms
                    ? SizedBox.square(
                        dimension: 32,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 32 * .0417,
                              top: 32 * .0417,
                              right: 32 * .0628,
                              bottom: 32 * .0627,
                              child: SvgPicture.asset(AppAssets.dashboardSms),
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
    );
  }
}

class DashboardAssistantIcon extends StatelessWidget {
  const DashboardAssistantIcon({super.key, this.floating = false});
  final bool floating;

  @override
  Widget build(BuildContext context) {
    final size = floating ? 24.0 : 32.0;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        children: [
          Positioned(
            left: size * (floating ? .534 : .5079),
            top: size * (floating ? .125 : .099),
            right: size * (floating ? .1175 : .0915),
            bottom: size * (floating ? .5265 : .5005),
            child: SvgPicture.asset(
              floating
                  ? AppAssets.dashboardFabStar
                  : AppAssets.dashboardAssistantStar,
            ),
          ),
          Positioned(
            left: size * (floating ? .1175 : .0915),
            top: size * (floating ? .3035 : .2774),
            right: size * (floating ? .296 : .27),
            bottom: size * (floating ? .1101 : .084),
            child: SvgPicture.asset(
              floating
                  ? AppAssets.dashboardFabSpark
                  : AppAssets.dashboardAssistantSpark,
            ),
          ),
        ],
      ),
    );
  }
}
