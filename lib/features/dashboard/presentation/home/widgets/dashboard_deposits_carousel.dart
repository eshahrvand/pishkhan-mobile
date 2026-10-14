import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/deposits_cubit.dart';

import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_deposit.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

/// Deposit fetching, persistence and service execution are caller-owned.
import 'dashboard_deposit_tile.dart';

class DashboardDepositsCarousel extends StatefulWidget {
  const DashboardDepositsCarousel({
    super.key,
    this.onCopyNumber,
    this.onCopyIban,
    this.onSelectedDepositChanged,
  });
  final ValueChanged<String>? onCopyNumber;
  final ValueChanged<String>? onCopyIban;
  final ValueChanged<BankDeposit>? onSelectedDepositChanged;

  @override
  State<DashboardDepositsCarousel> createState() =>
      _DashboardDepositsCarouselState();
}

class _DashboardDepositsCarouselState extends State<DashboardDepositsCarousel> {
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
    return BlocConsumer<DepositsCubit, DepositsState>(
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
          previous.selectedIndex != current.selectedIndex,
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final single = state.visibleItems.length == 1;
            final nativeWidth = single ? 335.0 : 316.0;
            final nativeHeight = single ? 202.0 : 191.0;
            final width = math.min(
              nativeWidth,
              constraints.maxWidth - (single ? 40 : 59),
            );
            // Fit the existing component as a whole; its design is deliberately unchanged.
            final height = nativeHeight * width / nativeWidth;
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
              height: single ? height + 35 : height + 46,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 122,
                    child: SvgPicture.asset(
                      AppAssets.depositsPatternUp,
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
                            child: DashboardDepositTile(
                              deposit: state.visibleItems[0],
                              width: width,
                              isSingle: state.visibleItems.length == 1,
                              height: height,
                              onCopyNumber: widget.onCopyNumber,
                              onCopyIban: widget.onCopyIban,
                            ),
                          )
                        : KeyedSubtree(
                            key: ObjectKey(_pages),
                            child: PageView.builder(
                              key: const Key('deposits_carousel'),
                              controller: _pages,
                              itemCount: state.visibleItems.length,
                              onPageChanged: (index) {
                                context.read<DepositsCubit>().select(index);
                                widget.onSelectedDepositChanged?.call(
                                  context
                                      .read<DepositsCubit>()
                                      .state
                                      .selectedDeposit!,
                                );
                              },
                              itemBuilder: (context, index) => Center(
                                child: DashboardDepositTile(
                                  deposit: state.visibleItems[index],
                                  width: width,
                                  isSingle: state.visibleItems.length == 1,
                                  height: height,
                                  onCopyNumber: widget.onCopyNumber,
                                  onCopyIban: widget.onCopyIban,
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
                              label: state.visibleItems[index].number,
                              child: InkWell(
                                key: Key('deposits_indicator_$index'),
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
