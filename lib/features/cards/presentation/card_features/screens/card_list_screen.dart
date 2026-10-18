import '../widgets/card_features_content.dart';
import '../widgets/card_features_filters.dart';

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

class CardListScreen extends StatelessWidget {
  const CardListScreen({
    super.key,
    this.initialCategory = CardCategory.resalat,
    this.onActionRequested,
    this.onAssistantPressed,
  });

  final CardCategory initialCategory;
  final ValueChanged<CardFeatureRequest>? onActionRequested;
  final VoidCallback? onAssistantPressed;

  Future<void> _handleEffect(
    BuildContext context,
    CardFeaturesState state,
  ) async {
    switch (state.effect) {
      case CardFilterRequested():
        final applied = await showCardFilter(
          context,
          context.read<CardFeaturesCubit>(),
        );
        if (context.mounted) {
          context.read<CardFeaturesCubit>().applyFilterSheetResult(applied);
        }
      case CardActionsRequested(:final card):
        final action = await showCardActions(context, card);
        if (!context.mounted) return;
        context.read<CardFeaturesCubit>().selectCardAction(action, card: card);
      case CardDetailsRequested(:final card):
        await showCardDetails(context, card);
      case CardServiceRequested(:final request, :final serviceId):
        if (onActionRequested != null) {
          onActionRequested!(request);
        } else if (serviceId != null) {
          openCardFeaturesService(
            context,
            serviceId,
            initialCardNumber: request.card?.number,
            initialDepositNumber: request.card?.linkedDeposit,
            onAssistantPressed: onAssistantPressed,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.current.cardFeatureUnavailable)),
          );
        }
      case CardCategoryRevealRequested():
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CardFeaturesCubit>(
      create: (providerContext) {
        final cubit = CardFeaturesCubit(initialCategory: initialCategory)
          ..fetchCards();
        // Initial reveal needs the chip layout and a subscribed listener.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (providerContext.mounted) {
            cubit.requestSelectedCategoryReveal();
          }
        });
        return cubit;
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<CardFeaturesCubit, CardFeaturesState>(
          listenWhen: (previous, current) =>
              previous.effectId != current.effectId &&
              current.effect is! CardCategoryRevealRequested,
          listener: _handleEffect,
          buildWhen: (previous, current) =>
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
                              const CardFeaturesFilters(),
                              Expanded(
                                child: CardFeaturesContent(
                                  hasFooter: state.footerAction != null,
                                  onMore: (card) => context
                                      .read<CardFeaturesCubit>()
                                      .requestCardActions(card),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            left: 16,
                            bottom: state.footerAction == null ? 16 : 76,
                            child: AppAssistantButton(
                              onPressed:
                                  onAssistantPressed ??
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
