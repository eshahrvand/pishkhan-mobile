import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

class DashboardBanner extends StatefulWidget {
  const DashboardBanner({
    required this.asset,
    this.showIndicators = false,
    this.sliderAssets = const [],
    this.onTap,
    super.key,
  });

  final String asset;
  final bool showIndicators;
  final List<String> sliderAssets;
  final VoidCallback? onTap;

  @override
  State<DashboardBanner> createState() => _DashboardBannerState();
}

class _DashboardBannerState extends State<DashboardBanner> {
  late final PageController _controller;
  var _activeIndex = 0;

  List<String> get _assets => [widget.asset, ...widget.sliderAssets];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final bannerHeight = (constraints.maxWidth - 32) / 3;
            if (!widget.showIndicators) {
              return SizedBox(
                height: bannerHeight,
                child: _BannerPage(
                  cardKey: const Key('dashboard_banner_card_static'),
                  asset: widget.asset,
                  onTap: widget.onTap,
                ),
              );
            }
            return SizedBox(
              key: const Key('dashboard_banner_viewport'),
              width: constraints.maxWidth,
              height: bannerHeight,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: PageView.builder(
                  key: const Key('dashboard_banner_slider'),
                  controller: _controller,
                  itemCount: _assets.length,
                  onPageChanged: (index) =>
                      setState(() => _activeIndex = index),
                  itemBuilder: (_, index) => _BannerPage(
                    cardKey: Key('dashboard_banner_card_$index'),
                    asset: _assets[index],
                    onTap: widget.onTap,
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.showIndicators) ...[
          const SizedBox(height: 12),
          _CarouselIndicators(
            count: _assets.length,
            activeIndex: _activeIndex,
            onSelected: (index) => _controller.animateToPage(
              index,
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOut,
            ),
          ),
        ],
      ],
    );
  }
}

class _BannerPage extends StatelessWidget {
  const _BannerPage({
    required this.cardKey,
    required this.asset,
    required this.onTap,
  });

  final Key cardKey;
  final String asset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      key: cardKey,
      borderRadius: AppRadius.borderLg,
      child: Image.asset(asset, width: double.infinity, fit: BoxFit.cover),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: onTap == null
          ? image
          : InkWell(
              onTap: onTap,
              borderRadius: AppRadius.borderLg,
              child: image,
            ),
    );
  }
}

class _CarouselIndicators extends StatelessWidget {
  const _CarouselIndicators({
    required this.count,
    required this.activeIndex,
    required this.onSelected,
  });

  final int count;
  final int activeIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.ltr,
    child: Row(
      key: const Key('dashboard_carousel_indicators'),
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < count; index++) ...[
          if (index > 0) const SizedBox(width: 6),
          GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: index == activeIndex ? 14 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: index == activeIndex
                    ? AppPalette.brand500
                    : AppPalette.gray300,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
