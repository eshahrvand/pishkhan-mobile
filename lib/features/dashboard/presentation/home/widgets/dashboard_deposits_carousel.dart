import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/home_cubit.dart';

import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

/// Deposit fetching, persistence and service execution are caller-owned.
import 'dashboard_deposit_tile.dart';

class DashboardDepositsCarousel extends StatefulWidget {
  const DashboardDepositsCarousel({super.key});
  @override
  State<DashboardDepositsCarousel> createState() =>
      _DashboardDepositsCarouselState();
}

class _DashboardDepositsCarouselState extends State<DashboardDepositsCarousel> {
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
    if (state.depositsStatus == RequestStatus.loading) {
      _controllerItems = null;
    }
    if (state.depositsStatus == RequestStatus.success &&
        state.visibleDeposits.isNotEmpty &&
        _controllerItems ==
            state.visibleDeposits.map((item) => item.id).join('|')) {
      if (_pages?.hasClients == true &&
          !_pages!.position.isScrollingNotifier.value &&
          ((_pages!.page ?? 0) - state.selectedDepositIndex).abs() > .01) {
        _pages!.jumpToPage(state.selectedDepositIndex);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listenWhen: (previous, current) =>
          previous.depositsStatus != current.depositsStatus ||
          previous.selectedDepositIndex != current.selectedDepositIndex ||
          previous.visibleDeposits != current.visibleDeposits,
      listener: _syncSelectedPage,
      buildWhen: (previous, current) =>
          previous.visibleDeposits != current.visibleDeposits ||
          previous.selectedDepositIndex != current.selectedDepositIndex,
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final single = state.visibleDeposits.length == 1;
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
                        state.visibleDeposits
                            .map((item) => item.id)
                            .join("|"))) {
              _pages?.dispose();
              _pages = PageController(
                initialPage: state.selectedDepositIndex,
                keepPage: false,
                viewportFraction: fraction,
              );
              // Reposition the attached scroll view explicitly when its controller changes.
              _syncingPages = true;
              final controller = _pages!;
              final selectedIndex = state.selectedDepositIndex;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted || !identical(_pages, controller)) return;
                if (controller.hasClients) controller.jumpToPage(selectedIndex);
                _syncingPages = false;
              });
              _viewport = fraction;
              _controllerItems = state.visibleDeposits
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
                    child: AvpImage(
                      image: '${AppConstants.baseImage}deposits_pattern_up.svg',
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
                              deposit: state.visibleDeposits[0],
                              width: width,
                              isSingle: state.visibleDeposits.length == 1,
                              height: height,
                              onCopyNumber: (_) => context
                                  .read<HomeCubit>()
                                  .requestDepositNumberCopy(
                                    state.visibleDeposits[0],
                                  ),
                              onCopyIban: (_) => context
                                  .read<HomeCubit>()
                                  .requestDepositIbanCopy(
                                    state.visibleDeposits[0],
                                  ),
                            ),
                          )
                        : PageView.builder(
                            controller: _pages,
                            itemCount: state.visibleDeposits.length,
                            onPageChanged: (index) {
                              if (_syncingPages) return;
                              context.read<HomeCubit>().selectDeposit(
                                state.visibleDeposits[index],
                              );
                            },
                            itemBuilder: (context, index) => Center(
                              child: DashboardDepositTile(
                                deposit: state.visibleDeposits[index],
                                width: width,
                                isSingle: state.visibleDeposits.length == 1,
                                height: height,
                                onCopyNumber: (_) => context
                                    .read<HomeCubit>()
                                    .requestDepositNumberCopy(
                                      state.visibleDeposits[index],
                                    ),
                                onCopyIban: (_) => context
                                    .read<HomeCubit>()
                                    .requestDepositIbanCopy(
                                      state.visibleDeposits[index],
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
                            index < state.visibleDeposits.length;
                            index++
                          ) ...[
                            if (index > 0) const SizedBox(width: 6),
                            Semantics(
                              button: true,
                              selected: index == state.selectedDepositIndex,
                              label: state.visibleDeposits[index].number,
                              child: InkWell(
                                onTap: () => _pages!.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                ),
                                child: Container(
                                  width: index == state.selectedDepositIndex
                                      ? 14
                                      : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: index == state.selectedDepositIndex
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
