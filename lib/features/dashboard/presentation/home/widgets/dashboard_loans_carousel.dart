import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/home_cubit.dart';

import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

/// Loan fetching, persistence, details and service execution are caller-owned.
import 'dashboard_loan_tile.dart';

class DashboardLoansCarousel extends StatefulWidget {
  const DashboardLoansCarousel({super.key});

  @override
  State<DashboardLoansCarousel> createState() => _DashboardLoansCarouselState();
}

class _DashboardLoansCarouselState extends State<DashboardLoansCarousel> {
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
    if (state.loansStatus == RequestStatus.loading) _controllerItems = null;
    if (state.loansStatus == RequestStatus.success &&
        state.visibleLoans.isNotEmpty &&
        _controllerItems ==
            state.visibleLoans.map((item) => item.id).join('|')) {
      if (_pages?.hasClients == true &&
          !_pages!.position.isScrollingNotifier.value &&
          ((_pages!.page ?? 0) - state.selectedLoanIndex).abs() > .01) {
        _pages!.jumpToPage(state.selectedLoanIndex);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listenWhen: (previous, current) =>
          previous.loansStatus != current.loansStatus ||
          previous.selectedLoanIndex != current.selectedLoanIndex ||
          previous.visibleLoans != current.visibleLoans,
      listener: _syncSelectedPage,
      buildWhen: (previous, current) =>
          previous.visibleLoans != current.visibleLoans ||
          previous.selectedLoanIndex != current.selectedLoanIndex,
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final single = state.visibleLoans.length == 1;
            final nativeWidth = single ? 335.0 : 316.0;
            const nativeHeight = 236.0;
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
                        state.visibleLoans.map((item) => item.id).join("|"))) {
              _pages?.dispose();
              _pages = PageController(
                initialPage: state.selectedLoanIndex,
                keepPage: false,
                viewportFraction: fraction,
              );
              // Reposition the attached scroll view explicitly when its controller changes.
              _syncingPages = true;
              final controller = _pages!;
              final selectedIndex = state.selectedLoanIndex;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted || !identical(_pages, controller)) return;
                if (controller.hasClients) controller.jumpToPage(selectedIndex);
                _syncingPages = false;
              });
              _viewport = fraction;
              _controllerItems = state.visibleLoans
                  .map((item) => item.id)
                  .join("|");
            }
            return SizedBox(
              height: height + 46,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 122,
                    child: AvpImage(
                      image: '${AppConstants.baseImage}loans_pattern_up.svg',
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
                            child: DashboardLoanTile(
                              loan: state.visibleLoans[0],
                              width: width,
                              isSingle: state.visibleLoans.length == 1,
                              height: height,
                              onCopyNumber: (_) => context
                                  .read<HomeCubit>()
                                  .requestLoanNumberCopy(state.visibleLoans[0]),
                              onDetailsRequested: (_) => context
                                  .read<HomeCubit>()
                                  .requestLoanDetails(state.visibleLoans[0]),
                            ),
                          )
                        : PageView.builder(
                            controller: _pages,
                            itemCount: state.visibleLoans.length,
                            onPageChanged: (index) {
                              if (_syncingPages) return;
                              context.read<HomeCubit>().selectLoan(
                                state.visibleLoans[index],
                              );
                            },
                            itemBuilder: (context, index) => Center(
                              child: DashboardLoanTile(
                                loan: state.visibleLoans[index],
                                width: width,
                                isSingle: state.visibleLoans.length == 1,
                                height: height,
                                onCopyNumber: (_) => context
                                    .read<HomeCubit>()
                                    .requestLoanNumberCopy(
                                      state.visibleLoans[index],
                                    ),
                                onDetailsRequested: (_) => context
                                    .read<HomeCubit>()
                                    .requestLoanDetails(
                                      state.visibleLoans[index],
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
                            index < state.visibleLoans.length;
                            index++
                          ) ...[
                            if (index > 0) const SizedBox(width: 6),
                            Semantics(
                              button: true,
                              selected: index == state.selectedLoanIndex,
                              label: state.visibleLoans[index].number,
                              child: InkWell(
                                onTap: () => _pages!.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                ),
                                child: Container(
                                  width: index == state.selectedLoanIndex
                                      ? 14
                                      : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: index == state.selectedLoanIndex
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
