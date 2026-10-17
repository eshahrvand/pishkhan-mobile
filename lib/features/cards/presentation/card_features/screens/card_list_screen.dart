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

import '../../../domain/entities/listed_card.dart';
import '../card_feature_action.dart';
import '../widgets/card_features_ui.dart';
import '../cubit/card_features_cubit.dart';
import '../widgets/card_feature_sheets.dart';

class CardListScreen extends StatefulWidget {
  const CardListScreen({
    super.key,
    this.initialCategory = CardCategory.resalat,
    this.onActionRequested,
    this.onAssistantPressed,
  });
  final CardCategory initialCategory;
  final ValueChanged<CardFeatureRequest>? onActionRequested;
  final VoidCallback? onAssistantPressed;
  @override
  State<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  final _search = TextEditingController();
  final _chips = ScrollController();
  // Chip contexts are layout resources; they never enter Cubit or State.
  final _categoryContexts = <CardCategory, BuildContext>{};

  @override
  void dispose() {
    _search.dispose();
    _chips.dispose();
    _categoryContexts.clear();
    super.dispose();
  }

  Future<void> _handleEffect(
    BuildContext context,
    CardFeaturesState state,
  ) async {
    switch (state.effect) {
      case CardCategoryRevealRequested(:final category, :final scrollToEnd):
        if (!_chips.hasClients) return;
        await _chips.animateTo(
          scrollToEnd ? _chips.position.maxScrollExtent : 0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
        if (!context.mounted ||
            context.read<CardFeaturesCubit>().state.category != category) {
          return;
        }
        final target = _categoryContexts[category];
        if (target != null && target.mounted && !scrollToEnd) {
          await Scrollable.ensureVisible(
            target,
            alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
            duration: const Duration(milliseconds: 200),
          );
        }
      case CardFilterRequested():
        final applied = await showCardFilter(
          context,
          context.read<CardFeaturesCubit>(),
        );
        if (context.mounted) {
          context.read<CardFeaturesCubit>().handleFilterSheetResult(applied);
        }
      case CardActionsRequested(:final card):
        final action = await showCardActions(context, card);
        if (!context.mounted) return;
        context.read<CardFeaturesCubit>().handleCardActionSelection(
          action,
          card: card,
        );
      case CardDetailsRequested(:final card):
        await showCardDetails(context, card);
      case CardServiceRequested(:final request, :final serviceId):
        if (widget.onActionRequested != null) {
          widget.onActionRequested!(request);
        } else if (serviceId != null) {
          openCardFeaturesService(
            context,
            serviceId,
            initialCardNumber: request.card?.number,
            initialDepositNumber: request.card?.linkedDeposit,
            onAssistantPressed: widget.onAssistantPressed,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.current.cardFeatureUnavailable)),
          );
        }
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CardFeaturesCubit>(
      create: (_) {
        final cubit = CardFeaturesCubit(initialCategory: widget.initialCategory)
          ..fetchCards();
        // Initial reveal needs the chip layout and a subscribed listener.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!cubit.isClosed) cubit.requestSelectedCategoryReveal();
        });
        return cubit;
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<CardFeaturesCubit, CardFeaturesState>(
          listenWhen: (previous, current) =>
              previous.effectId != current.effectId,
          listener: _handleEffect,
          buildWhen: (previous, current) =>
              previous.category != current.category ||
              previous.footerAction != current.footerAction,
          builder: (context, state) {
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
                      // The assistant and footer overlay the scroll viewport; a Column
                      // would change its height and the scroll/empty-state geometry.
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
                                          builder: (chipContext) {
                                            _categoryContexts[category] =
                                                chipContext;
                                            return AppChips(
                                              label: categoryLabel(category),
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
                                              onPressed: () => context
                                                  .read<CardFeaturesCubit>()
                                                  .selectCategory(category),
                                            );
                                          },
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
                                            .updateSearchQuery,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    AppButton(
                                      onPressed: () => context
                                          .read<CardFeaturesCubit>()
                                          .requestFilter(),
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
                                  hasFooter: state.footerAction != null,
                                  onMore: (card) => context
                                      .read<CardFeaturesCubit>()
                                      .requestCardActions(card.id),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            left: 16,
                            bottom: state.footerAction == null ? 16 : 76,
                            child: AppAssistantButton(
                              onPressed:
                                  widget.onAssistantPressed ??
                                  () => NavigationActions.back(context),
                            ),
                          ),
                          if (state.footerAction != null)
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
                                    label: actionLabel(state.footerAction!),
                                    labelStyle: AppTypography.titleMedium
                                        .copyWith(
                                          height: 24 / 16,
                                          letterSpacing: 0,
                                        ),
                                    contentGap: 10,
                                    constrainLabel: true,
                                    leadingIcon: cardFeatureIcon(
                                      actionAsset(state.footerAction!),
                                    ),
                                    onPressed: context
                                        .read<CardFeaturesCubit>()
                                        .requestFooterAction,
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
