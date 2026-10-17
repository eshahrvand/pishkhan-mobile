import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_cards_list.dart';

import '../../../domain/entities/listed_card.dart';
import '../widgets/card_features_ui.dart';
import '../cubit/card_features_cubit.dart';

class CardFeaturesContent extends StatelessWidget {
  const CardFeaturesContent({
    super.key,
    required this.hasFooter,
    required this.onMore,
  });
  final bool hasFooter;
  final ValueChanged<ListedCard> onMore;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CardFeaturesCubit, CardFeaturesState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.cards != current.cards ||
          previous.visibleCards != current.visibleCards ||
          previous.category != current.category,
      builder: (context, state) {
        if (state.status == RequestStatus.loading ||
            state.status == RequestStatus.initial) {
          return Center(
            child: AppButton(
              onPressed: null,
              label: S.current.dashboardLoading,
              isLoading: true,
            ),
          );
        }
        if (state.status == RequestStatus.failure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(S.current.dashboardLoadError),
                AppButton(
                  onPressed: context.read<CardFeaturesCubit>().fetchCards,
                  label: S.current.dashboardRetry,
                ),
              ],
            ),
          );
        }
        if (state.visibleCards.isEmpty) {
          return Center(
            child: Text(
              state.cards?.isEmpty == true
                  ? S.current.cardsEmpty
                  : S.current.cardFeatureNoResults,
            ),
          );
        }
        return ListView.separated(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(16, 0, 16, hasFooter ? 120 : 70),
          itemCount: state.visibleCards.length,
          separatorBuilder: (_, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) => AppCardsList(
            type: listType(state.category),
            coloredHeader: true,
            cardIcon: cardCategoryIcon(state.category),
            title: categoryLabel(state.category),
            cardNumber: state.visibleCards[index].number,
            linkedDeposit: state.visibleCards[index].linkedDeposit,
            cardNumberLabel: S.current.cardFeatureNumber,
            linkedDepositLabel: S.current.cardFeatureDeposit,
            onMoreTap: () => onMore(state.visibleCards[index]),
          ),
        );
      },
    );
  }
}
