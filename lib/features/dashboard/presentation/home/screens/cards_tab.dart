import '../widgets/dashboard_cards_carousel.dart';
import '../widgets/dashboard_cards_service_group.dart';

import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/repositories/dashboard_repositories.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_async_view.dart';

import '../cubit/cards_cubit.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/app_primary_navigation.dart';

export '../../shared/card_actions.dart';

/// Second primary tab. Service execution and card fetching belong to the caller.
class CardsTab extends StatefulWidget {
  const CardsTab({
    super.key,
    required this.repository,
    this.onActionRequested,
    this.onMorePressed,
    this.onCopyNumber,
    this.onCopyIban,
    this.onSelectedCardChanged,
    this.onTabSelected,
    this.onMenuPressed,
    this.onAssistantPressed,
  });
  final DashboardCardsRepository repository;
  final ValueChanged<CardActionRequest>? onActionRequested;
  final ValueChanged<BankCard>? onMorePressed, onSelectedCardChanged;
  final ValueChanged<String>? onCopyNumber, onCopyIban;
  final ValueChanged<AppPrimaryTab>? onTabSelected;
  final VoidCallback? onMenuPressed, onAssistantPressed;
  @override
  State<CardsTab> createState() => _CardsTabState();
}

class _CardsTabState extends State<CardsTab> {
  // Only used by the existing runtime repository update API.
  // Provider owns the instance; UI actions and rendering read the scope directly.
  CardsCubit? _repositoryScope;
  @override
  void didUpdateWidget(covariant CardsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.repository != oldWidget.repository) {
      _repositoryScope?.changeRepository(widget.repository);
    }
  }

  void _request(BuildContext context, CardAction action) =>
      widget.onActionRequested?.call(
        CardActionRequest(
          action: action,
          card: context.read<CardsCubit>().state.selectedCard!,
        ),
      );
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = CardsCubit(repository: widget.repository);
        _repositoryScope = cubit;
        return cubit..load();
      },
      child: BlocBuilder<CardsCubit, CardsState>(
        builder: (context, state) => Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: context.colors.surfaceSubtle,
            body: SafeArea(
              child: Column(
                children: [
                  AppTopBar(
                    title: S.current.cardsMyTitle,
                    showLeadingActions: false,
                    onMenuPressed: widget.onMenuPressed,
                  ),
                  if (state.visibleItems.isNotEmpty)
                    DashboardCardsCarousel(
                      onCopyNumber: widget.onCopyNumber,
                      onCopyIban: widget.onCopyIban,
                      onMorePressed: widget.onMorePressed,
                      onSelectedCardChanged: widget.onSelectedCardChanged,
                    ),
                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          key: const Key('cards_services_scroll'),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (state.status == RequestStatus.initial ||
                                  state.status == RequestStatus.loading)
                                const DashboardAsyncView(
                                  key: Key("cards_loading"),
                                  loading: true,
                                )
                              else if (state.status == RequestStatus.failure)
                                DashboardAsyncView(
                                  key: const Key("cards_error"),
                                  onRetry: context.read<CardsCubit>().load,
                                )
                              else if (state.visibleItems.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    S.current.cardsEmpty,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.bodyMedium,
                                  ),
                                ),
                              if (state.visibleItems.isNotEmpty) ...[
                                DashboardCardsServiceGroup(
                                  groupId: 'cards_operations',
                                  title: S.current.cardsOperations,
                                  actions: [
                                    CardAction.reissue,
                                    CardAction.changeDeposit,
                                    CardAction.block,
                                  ],
                                  onActionRequested: (action) =>
                                      _request(context, action),
                                ),
                                const SizedBox(height: 16),
                                DashboardCardsServiceGroup(
                                  groupId: 'cards_pin_operations',
                                  title: S.current.cardsPinOperations,
                                  actions: [
                                    CardAction.changeFirstPin,
                                    state.selectedCard!.canSetSecondPin
                                        ? CardAction.setSecondPin
                                        : CardAction.forgotSecondPin,
                                    CardAction.forgotFirstPin,
                                  ],
                                  onActionRequested: (action) =>
                                      _request(context, action),
                                ),
                                const SizedBox(height: 16),
                                DashboardCardsServiceGroup(
                                  groupId: 'cards_quick_access',
                                  title: S.current.cardsQuickAccess,
                                  actions: [
                                    CardAction.issue,
                                    CardAction.virtualCard,
                                    CardAction.giftPurchase,
                                    CardAction.giftBalance,
                                  ],
                                  onActionRequested: (action) =>
                                      _request(context, action),
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
                            key: const Key('cards_assistant_button'),
                            onPressed: widget.onAssistantPressed ?? () {},
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: AppPrimaryNavigation(
                            key: const Key('cards_navigation'),
                            selectedTab: AppPrimaryTab.cards,
                            onSelected: (tab) =>
                                widget.onTabSelected?.call(tab),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
