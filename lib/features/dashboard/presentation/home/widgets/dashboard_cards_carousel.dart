import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cards_cubit.dart';

import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_card.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

export '../../shared/card_actions.dart';

/// Second primary tab. Service execution and card fetching belong to the caller.
import 'dashboard_card_tile.dart';

class DashboardCardsCarousel extends StatefulWidget {
  const DashboardCardsCarousel({
    super.key,
    this.onCopyNumber,
    this.onCopyIban,
    this.onMorePressed,
    this.onSelectedCardChanged,
  });
  final ValueChanged<String>? onCopyNumber;
  final ValueChanged<String>? onCopyIban;
  final ValueChanged<BankCard>? onMorePressed;
  final ValueChanged<BankCard>? onSelectedCardChanged;

  @override
  State<DashboardCardsCarousel> createState() => _DashboardCardsCarouselState();
}

class _DashboardCardsCarouselState extends State<DashboardCardsCarousel> {
  PageController? _pages;
  double? _viewport;
  String? _controllerItems;

  @override
  void dispose() {
    _pages?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CardsCubit, CardsState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.selectedIndex != current.selectedIndex ||
          previous.items != current.items,
      listener: (context, state) {
        if (state.status == RequestStatus.loading) _controllerItems = null;
        if (state.status == RequestStatus.success && state.items != null) {
          if (_pages?.hasClients == true &&
              !_pages!.position.isScrollingNotifier.value &&
              ((_pages!.page ?? 0) - state.selectedIndex).abs() > .01) {
            _pages!.jumpToPage(state.selectedIndex);
          }
        }
      },
      buildWhen: (previous, current) =>
          previous.visibleItems != current.visibleItems ||
          previous.selectedIndex != current.selectedIndex ||
          previous.visibility != current.visibility,
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final single = state.visibleItems.length == 1;
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
                        state.visibleItems.map((item) => item.id).join("|"))) {
              _pages?.dispose();
              _pages = PageController(
                initialPage: state.selectedIndex,
                keepPage: false,
                viewportFraction: fraction,
              );
              _viewport = fraction;
              _controllerItems = state.visibleItems
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
                      image: AppAssets.cardsPatternUp,
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
                              card: state.visibleItems[0],
                              width: width,
                              isSingle: state.visibleItems.length == 1,
                              onCopyNumber: widget.onCopyNumber,
                              onCopyIban: widget.onCopyIban,
                              onMorePressed: widget.onMorePressed,
                              isVisible:
                                  state.visibility[state.visibleItems[0].id] ??
                                  state.visibleItems.length == 1,
                              onVisibilityChanged: (value) =>
                                  context.read<CardsCubit>().setVisibility(
                                    state.visibleItems[0].id,
                                    value,
                                  ),
                            ),
                          )
                        : KeyedSubtree(
                            key: ObjectKey(_pages),
                            child: PageView.builder(
                              clipBehavior: Clip.none,
                              key: const Key('cards_carousel'),
                              controller: _pages,
                              itemCount: state.visibleItems.length,
                              onPageChanged: (index) {
                                context.read<CardsCubit>().select(index);
                                widget.onSelectedCardChanged?.call(
                                  context
                                      .read<CardsCubit>()
                                      .state
                                      .selectedCard!,
                                );
                              },
                              itemBuilder: (context, index) => Center(
                                child: DashboardCardTile(
                                  card: state.visibleItems[index],
                                  width: width,
                                  isSingle: state.visibleItems.length == 1,
                                  onCopyNumber: widget.onCopyNumber,
                                  onCopyIban: widget.onCopyIban,
                                  onMorePressed: widget.onMorePressed,
                                  isVisible:
                                      state.visibility[state
                                          .visibleItems[index]
                                          .id] ??
                                      state.visibleItems.length == 1,
                                  onVisibilityChanged: (value) =>
                                      context.read<CardsCubit>().setVisibility(
                                        state.visibleItems[index].id,
                                        value,
                                      ),
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
                            index < state.visibleItems.length;
                            index++
                          ) ...[
                            if (index > 0) const SizedBox(width: 6),
                            Semantics(
                              button: true,
                              selected: index == state.selectedIndex,
                              label: state.visibleItems[index].id,
                              child: InkWell(
                                key: Key('cards_indicator_$index'),
                                onTap: () => _pages!.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                ),
                                child: Container(
                                  width: index == state.selectedIndex ? 14 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: index == state.selectedIndex
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
