import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/home_cubit.dart';

import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

export '../../shared/card_actions.dart';

/// Second primary tab. Service execution and card fetching belong to the caller.
import 'dashboard_card_tile.dart';

class DashboardCardsCarousel extends StatefulWidget {
  const DashboardCardsCarousel({super.key});

  @override
  State<DashboardCardsCarousel> createState() => _DashboardCardsCarouselState();
}

class _DashboardCardsCarouselState extends State<DashboardCardsCarousel> {
  PageController? _pages;
  bool _syncingPages = false;
  double? _viewport;
  String? _controllerItems;

  @override
  void dispose() {
    _pages?.dispose();
    super.dispose();
  }

  void _syncSelectedPage(BuildContext context, HomeState state) {
    if (state.cardsStatus == RequestStatus.loading) _controllerItems = null;
    if (state.cardsStatus == RequestStatus.success &&
        state.visibleCards.isNotEmpty &&
        _controllerItems ==
            state.visibleCards.map((item) => item.id).join('|')) {
      if (_pages?.hasClients == true &&
          !_pages!.position.isScrollingNotifier.value &&
          ((_pages!.page ?? 0) - state.selectedCardIndex).abs() > .01) {
        _pages!.jumpToPage(state.selectedCardIndex);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listenWhen: (previous, current) =>
          previous.cardsStatus != current.cardsStatus ||
          previous.selectedCardIndex != current.selectedCardIndex ||
          previous.visibleCards != current.visibleCards,
      listener: _syncSelectedPage,
      buildWhen: (previous, current) =>
          previous.visibleCards != current.visibleCards ||
          previous.selectedCardIndex != current.selectedCardIndex ||
          previous.cardVisibility != current.cardVisibility,
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final single = state.visibleCards.length == 1;
            final width = math.min(
              single ? 335.0 : 316.0,
              constraints.maxWidth - (single ? 40 : 59),
            );
            final extra =
                math.max(0.0, MediaQuery.textScalerOf(context).scale(1) - 1) *
                50;
            final height = (single ? 202.0 : 191.0) + extra;
            final fraction = (width + 12) / constraints.maxWidth;
            if (!single &&
                (_pages == null ||
                    _viewport != fraction ||
                    _controllerItems !=
                        state.visibleCards.map((item) => item.id).join("|"))) {
              _pages?.dispose();
              _pages = PageController(
                initialPage: state.selectedCardIndex,
                keepPage: false,
                viewportFraction: fraction,
              );
              // Reposition the attached scroll view explicitly when its controller changes.
              _syncingPages = true;
              final controller = _pages!;
              final selectedIndex = state.selectedCardIndex;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted || !identical(_pages, controller)) return;
                if (controller.hasClients) controller.jumpToPage(selectedIndex);
                _syncingPages = false;
              });
              _viewport = fraction;
              _controllerItems = state.visibleCards
                  .map((item) => item.id)
                  .join("|");
            }
            return SizedBox(
              height: 237 + extra,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 122,
                    child: AvpImage(
                      image: '${AppConstants.baseImage}cards_pattern_up.svg',
                      fit: BoxFit.fill,
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    height: height,
                    child: single
                        ? Center(
                            child: DashboardCardTile(
                              card: state.visibleCards[0],
                              width: width,
                              isSingle: state.visibleCards.length == 1,
                              onCopyNumber: (_) => context
                                  .read<HomeCubit>()
                                  .requestCardNumberCopy(state.visibleCards[0]),
                              onCopyIban: (_) => context
                                  .read<HomeCubit>()
                                  .requestCardIbanCopy(state.visibleCards[0]),
                              onMorePressed: (_) => context
                                  .read<HomeCubit>()
                                  .requestCardMore(state.visibleCards[0]),
                              isVisible:
                                  state.cardVisibility[state
                                      .visibleCards[0]
                                      .id] ??
                                  state.visibleCards.length == 1,
                              onVisibilityChanged: (value) => context
                                  .read<HomeCubit>()
                                  .updateCardVisibility(
                                    state.visibleCards[0],
                                    value,
                                  ),
                            ),
                          )
                        : PageView.builder(
                            clipBehavior: Clip.none,
                            controller: _pages,
                            itemCount: state.visibleCards.length,
                            onPageChanged: (index) {
                              if (_syncingPages) return;
                              context.read<HomeCubit>().selectCard(
                                state.visibleCards[index],
                              );
                            },
                            itemBuilder: (context, index) => Center(
                              child: DashboardCardTile(
                                card: state.visibleCards[index],
                                width: width,
                                isSingle: state.visibleCards.length == 1,
                                onCopyNumber: (_) => context
                                    .read<HomeCubit>()
                                    .requestCardNumberCopy(
                                      state.visibleCards[index],
                                    ),
                                onCopyIban: (_) => context
                                    .read<HomeCubit>()
                                    .requestCardIbanCopy(
                                      state.visibleCards[index],
                                    ),
                                onMorePressed: (_) => context
                                    .read<HomeCubit>()
                                    .requestCardMore(state.visibleCards[index]),
                                isVisible:
                                    state.cardVisibility[state
                                        .visibleCards[index]
                                        .id] ??
                                    state.visibleCards.length == 1,
                                onVisibilityChanged: (value) => context
                                    .read<HomeCubit>()
                                    .updateCardVisibility(
                                      state.visibleCards[index],
                                      value,
                                    ),
                              ),
                            ),
                          ),
                  ),
                  if (!single)
                    Positioned(
                      top: 16 + height + 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (
                            var index = 0;
                            index < state.visibleCards.length;
                            index++
                          ) ...[
                            if (index > 0) const SizedBox(width: 6),
                            Semantics(
                              button: true,
                              selected: index == state.selectedCardIndex,
                              label: state.visibleCards[index].id,
                              child: InkWell(
                                onTap: () => _pages!.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                ),
                                child: Container(
                                  width: index == state.selectedCardIndex
                                      ? 14
                                      : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: index == state.selectedCardIndex
                                        ? AppDashboardColors.navActive
                                        : context.colors.border,
                                    borderRadius: AppRadius.borderFull,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
