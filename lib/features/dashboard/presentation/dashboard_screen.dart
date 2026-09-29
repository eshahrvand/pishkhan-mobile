import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_assets.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_banner.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_header.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_latest_requests.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_service_sections.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_wallet_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_welcome_card.dart';

enum DashboardVariant { withAds, withoutAds }

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    this.variant = DashboardVariant.withAds,
    this.onMenuPressed,
  });

  final DashboardVariant variant;
  final VoidCallback? onMenuPressed;

  bool get _showsAds => variant == DashboardVariant.withAds;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppPalette.gray100,
    body: SafeArea(
      child: Column(
        children: [
          DashboardHeader(onMenuPressed: onMenuPressed),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SvgPicture.asset(
                          DashboardAssets.patternUp,
                          height: 122,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Positioned(
                        top: _showsAds ? 1313 : 1035,
                        left: 0,
                        right: 0,
                        child: SvgPicture.asset(
                          DashboardAssets.patternDown,
                          height: 122,
                          fit: BoxFit.fill,
                        ),
                      ),
                      _DashboardContent(showsAds: _showsAds),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.showsAds});

  final bool showsAds;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        _HorizontalInset(
          child: AppWelcomeCard(
            greeting: l10n.dashboardGreeting,
            message: l10n.dashboardWelcomeMessage,
          ),
        ),
        const SizedBox(height: 16),
        _HorizontalInset(
          child: AppWalletCard(
            title: l10n.walletBalanceTitle,
            balance: l10n.dashboardWalletBalance,
            currencyLabel: l10n.rialCurrency,
          ),
        ),
        const SizedBox(height: 16),
        const _HorizontalInset(child: DashboardServiceSections()),
        if (showsAds) ...[
          const SizedBox(height: 16),
          const DashboardBanner(asset: DashboardAssets.bannerYellow),
        ],
        const SizedBox(height: 16),
        const _HorizontalInset(child: DashboardSelectedServices()),
        if (showsAds) ...[
          const SizedBox(height: 16),
          const DashboardBanner(
            asset: DashboardAssets.bannerBlue,
            showIndicators: true,
            sliderAssets: [
              DashboardAssets.bannerYellow,
              DashboardAssets.bannerBlue,
              DashboardAssets.bannerYellow,
            ],
          ),
        ],
        const SizedBox(height: 16),
        const _HorizontalInset(child: DashboardLatestRequests()),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _HorizontalInset extends StatelessWidget {
  const _HorizontalInset({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: child,
  );
}
