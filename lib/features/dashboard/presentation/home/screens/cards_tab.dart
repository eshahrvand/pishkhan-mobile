import '../widgets/dashboard_cards_carousel.dart';
import '../widgets/dashboard_cards_service_group.dart';

import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_async_view.dart';

import '../cubit/home_cubit.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/app_primary_navigation.dart';

export '../../shared/card_actions.dart';

/// Card data and available operations are owned by HomeCubit.
class CardsTab extends StatelessWidget {
  const CardsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) {
        return previous.cardsStatus != current.cardsStatus ||
            previous.visibleCards != current.visibleCards ||
            previous.cardActions != current.cardActions ||
            previous.pinActions != current.pinActions ||
            previous.cardQuickActions != current.cardQuickActions;
      },
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: context.colors.surfaceSubtle,
            body: SafeArea(
              child: Column(
                children: [
                  AppTopBar(
                    title: S.current.cardsMyTitle,
                    showLeadingActions: false,
                    onMenuPressed: () =>
                        context.read<HomeCubit>().requestMenu(),
                  ),
                  if (state.visibleCards.isNotEmpty)
                    const DashboardCardsCarousel(),
                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (state.cardsStatus == RequestStatus.initial ||
                                  state.cardsStatus == RequestStatus.loading)
                                const DashboardAsyncView(loading: true)
                              else if (state.cardsStatus ==
                                  RequestStatus.failure)
                                DashboardAsyncView(
                                  onRetry: context.read<HomeCubit>().loadCards,
                                )
                              else if (state.visibleCards.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    S.current.cardsEmpty,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.bodyMedium,
                                  ),
                                ),
                              if (state.visibleCards.isNotEmpty) ...[
                                DashboardCardsServiceGroup(
                                  title: S.current.cardsOperations,
                                  actions: state.cardActions,
                                  onActionRequested: (action) => context
                                      .read<HomeCubit>()
                                      .requestCardAction(action),
                                ),
                                const SizedBox(height: 16),
                                DashboardCardsServiceGroup(
                                  title: S.current.cardsPinOperations,
                                  actions: state.pinActions,
                                  onActionRequested: (action) => context
                                      .read<HomeCubit>()
                                      .requestCardAction(action),
                                ),
                                const SizedBox(height: 16),
                                DashboardCardsServiceGroup(
                                  title: S.current.cardsQuickAccess,
                                  actions: state.cardQuickActions,
                                  onActionRequested: (action) => context
                                      .read<HomeCubit>()
                                      .requestCardAction(action),
                                  quick: true,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Positioned(
                          left: 16,
                          bottom: 84,
                          child: AppAssistantButton(
                            onPressed: () =>
                                context.read<HomeCubit>().requestAssistant(),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: AppPrimaryNavigation(
                            selectedTab: AppPrimaryTab.cards,
                            onSelected: (tab) =>
                                context.read<HomeCubit>().selectTab(tab),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
