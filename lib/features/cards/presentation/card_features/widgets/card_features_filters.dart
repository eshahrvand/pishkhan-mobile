import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/listed_card.dart';
import '../cubit/card_features_cubit.dart';
import 'card_features_ui.dart';

class CardFeaturesFilters extends StatefulWidget {
  const CardFeaturesFilters({super.key});

  @override
  State<CardFeaturesFilters> createState() => _CardFeaturesFiltersState();
}

class _CardFeaturesFiltersState extends State<CardFeaturesFilters> {
  final _search = TextEditingController();
  final _chips = ScrollController();
  // Rendered chip contexts are needed by ensureVisible and stay in UI.
  final _categoryContexts = <CardCategory, BuildContext>{};

  @override
  void dispose() {
    _search.dispose();
    _chips.dispose();
    _categoryContexts.clear();
    super.dispose();
  }

  Future<void> _revealCategory(
    BuildContext context,
    CardFeaturesState state,
  ) async {
    context.read<CardFeaturesCubit>().consumeCardFeaturesInteraction();

    if (state.effect case CardCategoryRevealRequested(
      :final category,
      :final scrollToEnd,
    )) {
      if (!_chips.hasClients) return;
      if (scrollToEnd) {
        await _chips.animateTo(
          _chips.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      } else {
        final target = _categoryContexts[category];
        if (target != null && target.mounted) {
          await Scrollable.ensureVisible(
            target,
            alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
            duration: const Duration(milliseconds: 200),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CardFeaturesCubit, CardFeaturesState>(
      listenWhen: (previous, current) =>
          (previous.effect != current.effect && current.effect != null) &&
          current.effect is CardCategoryRevealRequested,
      listener: _revealCategory,
      buildWhen: (previous, current) => previous.category != current.category,
      builder: (context, state) {
        return Column(
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
                    for (final category in CardCategory.values) ...[
                      if (category != CardCategory.resalat)
                        const SizedBox(width: 12),
                      Builder(
                        builder: (chipContext) {
                          _categoryContexts[category] = chipContext;
                          return AppChips(
                            label: categoryLabel(category),
                            labelStyle:
                                (category == CardCategory.coupon ||
                                    category == CardCategory.family)
                                ? AppTypography.labelLarge.copyWith(
                                    color: context.colors.textSecondary,
                                  )
                                : null,
                            selected: state.category == category,
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: AppSearchField(
                      controller: _search,
                      hintText: S.current.dashboardSearchHint,
                      hintColor: AppCardFeatureColors.searchHint,
                      focusRing: AppTextFieldFocusRing.none,
                      textStyle: AppTypography.bodyMedium.copyWith(
                        height: 20 / 14,
                        letterSpacing: 0,
                      ),
                      searchIcon: cardFeatureIcon(
                        '${AppConstants.baseImage}card_features_search.svg',
                      ),
                      clearIcon: cardFeatureIcon(
                        '${AppConstants.baseImage}dashboard_search_clear.svg',
                      ),
                      onChanged: context
                          .read<CardFeaturesCubit>()
                          .updateSearchQuery,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    onPressed: () =>
                        context.read<CardFeaturesCubit>().requestFilter(),
                    size: AppButtonSize.lg,
                    backgroundColor: AppCardFeatureColors.filterButton,
                    tooltip: S.current.cardFeatureFilter,
                    icon: cardFeatureIcon(
                      '${AppConstants.baseImage}card_features_filter.svg',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AvpImage(
                image: '${AppConstants.baseImage}card_features_separator.png',
                height: 1,
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(height: 15),
          ],
        );
      },
    );
  }
}
