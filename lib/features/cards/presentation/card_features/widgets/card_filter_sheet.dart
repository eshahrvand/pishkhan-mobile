import 'package:pishkhan_mobile/core/config/constant.dart';

import 'card_feature_divider.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../../../domain/entities/listed_card.dart';
import 'card_features_ui.dart';
import '../cubit/card_features_cubit.dart';

class CardFilterSheet extends StatelessWidget {
  const CardFilterSheet({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CardFeaturesCubit, CardFeaturesState>(
      buildWhen: (previous, current) =>
          previous.draftFilter != current.draftFilter ||
          previous.depositNumbers != current.depositNumbers,
      builder: (context, state) {
        if (state.draftFilter == null) return const SizedBox.shrink();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBottomSheetHeader(
              title: S.current.cardFeatureFilter,
              rightIcon: cardFeatureIcon(
                '${AppConstants.baseImage}card_features_filter_header.svg',
              ),
              showLeftAction: state.draftFilter!.isActive,
              showTextAction: true,
              textActionLabel: S.current.cardFeatureRemoveFilter,
              textActionColor: AppCardFeatureColors.destructiveAction,
              onLeftAction: context.read<CardFeaturesCubit>().resetDraftFilter,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppSelect<String>(
                    value: state.draftFilter!.status?.name ?? 'all',
                    label: S.current.cardFeatureCardStatus,
                    labelSpacing: 8,
                    labelStyle: _label(context),
                    textStyle: _value(context),
                    trailing: cardFeatureIcon(
                      '${AppConstants.baseImage}card_features_chevron.svg',
                    ),
                    options: [
                      AppSelectOption(
                        value: 'all',
                        label: S.current.cardFeatureAll,
                      ),
                      for (final status in CardStatus.values)
                        AppSelectOption(
                          value: status.name,
                          label: statusLabel(status),
                        ),
                    ],
                    onChanged: (value) {
                      context.read<CardFeaturesCubit>().selectDraftCardStatus(
                        value,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const CardFeatureDivider(),
                  const SizedBox(height: 16),
                  AppSelect<String>(
                    value: state.draftFilter!.deposit ?? 'all',
                    label: S.current.cardFeatureDeposit,
                    labelSpacing: 8,
                    labelStyle: _label(context),
                    textStyle: _value(context),
                    trailing: cardFeatureIcon(
                      '${AppConstants.baseImage}card_features_chevron.svg',
                    ),
                    options: [
                      AppSelectOption(
                        value: 'all',
                        label: S.current.cardFeatureAll,
                      ),
                      for (final deposit in state.depositNumbers)
                        AppSelectOption(value: deposit, label: deposit),
                    ],
                    onChanged: (value) {
                      context
                          .read<CardFeaturesCubit>()
                          .selectDraftDepositNumber(value);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: AppButton(
                size: AppButtonSize.lg,
                label: S.current.cardFeatureApplyFilter,
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

TextStyle _label(BuildContext context) => AppTypography.labelMedium.copyWith(
  height: 18 / 12,
  letterSpacing: 0,
  color: context.colors.textSecondary,
);
TextStyle _value(BuildContext context) => AppTypography.bodyMedium.copyWith(
  height: 20 / 14,
  letterSpacing: 0,
  color: context.colors.textPrimary,
);
