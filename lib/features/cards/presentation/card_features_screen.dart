import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_cards_list.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../data/mock/mock_cards_repository.dart';
import '../domain/entities/listed_card.dart';
import '../domain/repositories/cards_repository.dart';
import 'card_feature_actions.dart';
import 'card_features_ui.dart';
import 'cubit/card_features_cubit.dart';
import 'widgets/card_feature_sheets.dart';

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
  late final CardFeaturesCubit _cubit;
  final _search = TextEditingController();
  final _chips = ScrollController();
  final _chipKeys = {for (final c in CardCategory.values) c: GlobalKey()};
  @override
  void initState() {
    super.initState();
    _cubit = CardFeaturesCubit(
      repository: widget.repository ?? MockCardsRepository(),
      initialCategory: widget.initialCategory,
    )..load();
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealCategory());
  }

  @override
  void didUpdateWidget(covariant CardFeaturesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      _cubit.changeRepository(widget.repository ?? MockCardsRepository());
    }
  }

  @override
  void dispose() {
    _cubit.close();
    _search.dispose();
    _chips.dispose();
    super.dispose();
  }

  Future<void> _revealCategory() async {
    if (!mounted || !_chips.hasClients) return;
    final category = _cubit.state.category;
    await _chips.animateTo(
      category.index >= 3 ? _chips.position.maxScrollExtent : 0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
    if (!mounted || _cubit.state.category != category) return;
    final target = _chipKeys[category]?.currentContext;
    if (target != null && target.mounted && category.index < 3) {
      await Scrollable.ensureVisible(
        target,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        duration: const Duration(milliseconds: 200),
      );
    }
  }

  void _request(CardFeatureAction action, {ListedCard? card}) {
    final request = CardFeatureRequest(
      action: action,
      card: card,
      category: _cubit.state.category,
    );
    if (widget.onActionRequested != null) {
      widget.onActionRequested!(request);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.cardFeatureUnavailable)),
      );
    }
  }

  Future<void> _more(ListedCard card) async {
    _cubit.selectCard(card.id);
    final action = await showCardActions(context, card);
    if (!mounted || action == null) return;
    if (action == CardFeatureAction.details) {
      await showCardDetails(context, card);
    } else {
      _request(action, card: card);
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: BlocBuilder<CardFeaturesCubit, CardFeaturesState>(
      bloc: _cubit,
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
                  title: context.l10n.dashboardCardsList,
                  showLeadingActions: false,
                  trailingIcon: cardFeatureIcon(
                    AppAssets.cardFeaturesBack,
                    size: 24,
                  ),
                  trailingTooltip: context.l10n.backLabel,
                  onTrailingPressed: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: SingleChildScrollView(
                              key: const Key('card_features_categories'),
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
                                    KeyedSubtree(
                                      key: _chipKeys[category],
                                      child: AppChips(
                                        key: Key(
                                          'card_category_${category.name}',
                                        ),
                                        label: categoryLabel(context, category),
                                        labelStyle: category.index >= 3
                                            ? AppTypography.labelLarge.copyWith(
                                                color: context
                                                    .colors
                                                    .textSecondary,
                                              )
                                            : null,
                                        selected: state.category == category,
                                        onPressed: () {
                                          _cubit.selectCategory(category);
                                          _revealCategory();
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
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: AppSearchField(
                                    key: const Key('card_features_search'),
                                    controller: _search,
                                    hintText: context.l10n.dashboardSearchHint,
                                    hintColor: AppCardFeatureColors.searchHint,
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
                                    onChanged: _cubit.search,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AppButton(
                                  key: const Key('card_features_filter_button'),
                                  onPressed: () =>
                                      showCardFilter(context, _cubit),
                                  size: AppButtonSize.lg,
                                  backgroundColor:
                                      AppCardFeatureColors.filterButton,
                                  tooltip: context.l10n.cardFeatureFilter,
                                  icon: cardFeatureIcon(
                                    AppAssets.cardFeaturesFilter,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Image.asset(
                              AppAssets.cardFeaturesSeparator,
                              height: 1,
                              width: double.infinity,
                              fit: BoxFit.fill,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Expanded(
                            child: _content(
                              context,
                              state,
                              footerAction != null,
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        left: 16,
                        bottom: footerAction == null ? 16 : 76,
                        child: AppAssistantButton(
                          key: const Key('card_features_assistant'),
                          onPressed:
                              widget.onAssistantPressed ??
                              () => Navigator.of(context).maybePop(),
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
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: AppButton(
                                key: const Key('card_features_footer'),
                                size: AppButtonSize.lg,
                                label: actionLabel(context, footerAction),
                                labelStyle: AppTypography.titleMedium.copyWith(
                                  height: 24 / 16,
                                  letterSpacing: 0,
                                ),
                                contentGap: 10,
                                constrainLabel: true,
                                leadingIcon: cardFeatureIcon(
                                  actionAsset(footerAction),
                                ),
                                onPressed: () => _request(footerAction),
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
  );
  Widget _content(
    BuildContext context,
    CardFeaturesState state,
    bool hasFooter,
  ) {
    if (state.status == CardsLoadStatus.loading ||
        state.status == CardsLoadStatus.initial) {
      return Center(
        child: AppButton(
          onPressed: null,
          label: context.l10n.dashboardLoading,
          isLoading: true,
        ),
      );
    }
    if (state.status == CardsLoadStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.dashboardLoadError),
            AppButton(
              key: const Key('card_features_retry'),
              onPressed: _cubit.load,
              label: context.l10n.dashboardRetry,
            ),
          ],
        ),
      );
    }
    final cards = state.visibleCards;
    if (cards.isEmpty) {
      return Center(
        child: Text(
          state.status == CardsLoadStatus.empty
              ? context.l10n.cardsEmpty
              : context.l10n.cardFeatureNoResults,
        ),
      );
    }
    return ListView.separated(
      key: const Key('card_features_list'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(16, 0, 16, hasFooter ? 120 : 70),
      itemCount: cards.length,
      separatorBuilder: (_, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) => AppCardsList(
        key: ValueKey('listed_card_${cards[index].id}'),
        type: listType(state.category),
        coloredHeader: true,
        cardIcon: cardCategoryIcon(state.category),
        title: categoryLabel(context, state.category),
        cardNumber: cards[index].number,
        linkedDeposit: cards[index].linkedDeposit,
        cardNumberLabel: context.l10n.cardFeatureNumber,
        linkedDepositLabel: context.l10n.cardFeatureDeposit,
        onMoreTap: () => _more(cards[index]),
      ),
    );
  }
}
