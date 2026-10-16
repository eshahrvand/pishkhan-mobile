import '../widgets/card_features_content.dart';

import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/core/router/card_features_navigation.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../../../data/repositories/mock_cards_repository.dart';
import '../../../domain/entities/listed_card.dart';
import '../../../domain/repositories/cards_repository.dart';
import '../widgets/card_feature_actions.dart';
import '../widgets/card_features_ui.dart';
import '../cubit/card_features_cubit.dart';
import '../widgets/card_feature_sheets.dart';

class CardFeaturesScreen extends StatefulWidget {
  const CardFeaturesScreen({
    super.key,
    this.repository,
    this.initialCategory = CardCategory.resalat,
    this.onActionRequested,
    this.onAssistantPressed,
  });
  final CardsRepository? repository;
  final CardCategory initialCategory;
  final ValueChanged<CardFeatureRequest>? onActionRequested;
  final VoidCallback? onAssistantPressed;
  @override
  State<CardFeaturesScreen> createState() => _CardFeaturesScreenState();
}

class _CardFeaturesScreenState extends State<CardFeaturesScreen> {
  // Retained only to synchronize this screen's existing runtime repository API.
  // BlocProvider owns and closes the instance; rendering/actions use context.read.
  CardFeaturesCubit? _repositoryScope;
  final _search = TextEditingController();
  final _chips = ScrollController();
  @override
  void didUpdateWidget(covariant CardFeaturesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      _repositoryScope?.changeRepository(
        widget.repository ?? MockCardsRepository(),
      );
    }
  }

  @override
  void dispose() {
    _search.dispose();
    _chips.dispose();
    super.dispose();
  }

  Future<void> _revealCategory(
    CardFeaturesCubit cubit, {
    BuildContext? target,
  }) async {
    if (!mounted || !_chips.hasClients) return;
    final category = cubit.state.category;
    await _chips.animateTo(
      category.index >= 3 ? _chips.position.maxScrollExtent : 0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
    if (!mounted || cubit.state.category != category) {
      return;
    }
    if (target != null && target.mounted && category.index < 3) {
      await Scrollable.ensureVisible(
        target,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        duration: const Duration(milliseconds: 200),
      );
    }
  }

  void _request(
    BuildContext context,
    CardFeatureAction action, {
    ListedCard? card,
  }) {
    final request = CardFeatureRequest(
      action: action,
      card: card,
      category: context.read<CardFeaturesCubit>().state.category,
    );
    if (widget.onActionRequested != null) {
      widget.onActionRequested!(request);
    } else if (action == CardFeatureAction.requestVirtual) {
      openCardFeaturesService(context, 'card-virtual-request');
    } else if (action == CardFeatureAction.changeDeposit) {
      openCardFeaturesService(
        context,
        'card-deposit',
        initialCardNumber: card?.number,
      );
    } else if (action == CardFeatureAction.expiredGiftBalance) {
      openCardFeaturesService(context, 'card-expired-gift');
    } else if (action == CardFeatureAction.reissue) {
      openCardFeaturesService(
        context,
        'card-reissue',
        initialDepositNumber: card?.linkedDeposit,
        onAssistantPressed: widget.onAssistantPressed,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.current.cardFeatureUnavailable)));
    }
  }

  Future<void> _more(BuildContext context, ListedCard card) async {
    context.read<CardFeaturesCubit>().selectCard(card.id);
    final action = await showCardActions(context, card);
    if (!context.mounted || action == null) return;
    if (action == CardFeatureAction.details) {
      await showCardDetails(context, card);
    } else {
      _request(context, action, card: card);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (providerContext) {
        final cubit = CardFeaturesCubit(
          repository: widget.repository ?? MockCardsRepository(),
          initialCategory: widget.initialCategory,
        );
        _repositoryScope = cubit;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _revealCategory(cubit);
        });
        return cubit..load();
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocBuilder<CardFeaturesCubit, CardFeaturesState>(
          builder: (context, state) {
            final footerAction = switch (state.category) {
              CardCategory.gift => CardFeatureAction.expiredGiftBalance,
              CardCategory.virtual => CardFeatureAction.requestVirtual,
              _ => null,
            };
            return Scaffold(
              backgroundColor: context.colors.surfaceSubtle,
              body: SafeArea(
                child: Column(
                  children: [
                    AppTopBar(
                      title: S.current.dashboardCardsList,
                      showLeadingActions: false,
                      trailingIcon: cardFeatureIcon(
                        AppAssets.cardFeaturesBack,
                        size: 24,
                      ),
                      trailingTooltip: S.current.backLabel,
                      onTrailingPressed: () => NavigationActions.back(context),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: SingleChildScrollView(
                                  controller: _chips,
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsetsDirectional.only(
                                    start: 16,
                                    end: 0,
                                    top: 4,
                                    bottom: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      for (final category
                                          in CardCategory.values) ...[
                                        if (category != CardCategory.resalat)
                                          const SizedBox(width: 12),
                                        Builder(
                                          builder: (chipContext) => AppChips(
                                            label: categoryLabel(
                                              context,
                                              category,
                                            ),
                                            labelStyle: category.index >= 3
                                                ? AppTypography.labelLarge
                                                      .copyWith(
                                                        color: context
                                                            .colors
                                                            .textSecondary,
                                                      )
                                                : null,
                                            selected:
                                                state.category == category,
                                            onPressed: () {
                                              context
                                                  .read<CardFeaturesCubit>()
                                                  .selectCategory(category);
                                              _revealCategory(
                                                context
                                                    .read<CardFeaturesCubit>(),
                                                target: chipContext,
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: AppSearchField(
                                        controller: _search,
                                        hintText: S.current.dashboardSearchHint,
                                        hintColor:
                                            AppCardFeatureColors.searchHint,
                                        focusRing: AppTextFieldFocusRing.none,
                                        textStyle: AppTypography.bodyMedium
                                            .copyWith(
                                              height: 20 / 14,
                                              letterSpacing: 0,
                                            ),
                                        searchIcon: cardFeatureIcon(
                                          AppAssets.cardFeaturesSearch,
                                        ),
                                        clearIcon: cardFeatureIcon(
                                          AppAssets.dashboardSearchClear,
                                        ),
                                        onChanged: context
                                            .read<CardFeaturesCubit>()
                                            .search,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    AppButton(
                                      onPressed: () => showCardFilter(
                                        context,
                                        context.read<CardFeaturesCubit>(),
                                      ),
                                      size: AppButtonSize.lg,
                                      backgroundColor:
                                          AppCardFeatureColors.filterButton,
                                      tooltip: S.current.cardFeatureFilter,
                                      icon: cardFeatureIcon(
                                        AppAssets.cardFeaturesFilter,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: AvpImage(
                                  image: AppAssets.cardFeaturesSeparator,
                                  height: 1,
                                  width: double.infinity,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Expanded(
                                child: CardFeaturesContent(
                                  hasFooter: footerAction != null,
                                  onMore: (card) => _more(context, card),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            left: 16,
                            bottom: footerAction == null ? 16 : 76,
                            child: AppAssistantButton(
                              onPressed:
                                  widget.onAssistantPressed ??
                                  () => NavigationActions.back(context),
                            ),
                          ),
                          if (footerAction != null)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: ColoredBox(
                                color: context.colors.surface,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  child: AppButton(
                                    size: AppButtonSize.lg,
                                    label: actionLabel(context, footerAction),
                                    labelStyle: AppTypography.titleMedium
                                        .copyWith(
                                          height: 24 / 16,
                                          letterSpacing: 0,
                                        ),
                                    contentGap: 10,
                                    constrainLabel: true,
                                    leadingIcon: cardFeatureIcon(
                                      actionAsset(footerAction),
                                    ),
                                    onPressed: () =>
                                        _request(context, footerAction),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
