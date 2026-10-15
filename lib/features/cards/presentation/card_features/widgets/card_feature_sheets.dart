import 'card_details_sheet.dart';
import 'card_feature_divider.dart';

import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../../../domain/entities/listed_card.dart';
import 'card_feature_actions.dart';
import 'card_features_ui.dart';
import '../cubit/card_features_cubit.dart';

Future<T?> _sheet<T>(BuildContext context, WidgetBuilder panel) {
  FocusManager.instance.primaryFocus?.unfocus();
  final insets = MediaQuery.viewPaddingOf(context);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent,
    enableDrag: false,
    builder: (sheetContext) => Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height,
        child: Stack(
          children: [
            Positioned.fill(
              top: insets.top,
              bottom: insets.bottom,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(sheetContext).pop(),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: AvpImage(
                      image: AppAssets.cardFeaturesScrim,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: insets.bottom,
              child: Material(
                color: sheetContext.colors.surfaceSubtle,
                borderRadius: const BorderRadius.vertical(top: AppRadius.xl),
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight:
                        MediaQuery.sizeOf(sheetContext).height -
                        insets.top -
                        insets.bottom -
                        16,
                  ),
                  child: SingleChildScrollView(child: panel(sheetContext)),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<CardFeatureAction?> showCardActions(
  BuildContext context,
  ListedCard card,
) => _sheet<CardFeatureAction>(
  context,
  (context) => Column(
    key: const Key('card_features_actions_sheet'),
    mainAxisSize: MainAxisSize.min,
    children: [
      const AppBottomSheetHeader(type: AppBottomSheetHeaderType.handleOnly),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final action in const [
              CardFeatureAction.details,
              CardFeatureAction.reissue,
              CardFeatureAction.changeDeposit,
              CardFeatureAction.block,
            ]) ...[
              if (action != CardFeatureAction.details)
                const CardFeatureDivider(),
              InkWell(
                key: Key('card_feature_action_${action.name}'),
                onTap: () => Navigator.of(context).pop(action),
                child: SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      cardFeatureIcon(actionAsset(action), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          actionLabel(context, action),
                          style: AppTypography.labelLarge.copyWith(
                            height: 18 / 14,
                            letterSpacing: 0,
                            color: AppDashboardColors.sectionText,
                          ),
                        ),
                      ),
                    ],
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

Future<void> showCardDetails(BuildContext context, ListedCard card) =>
    _sheet<void>(
      context,
      (context) => CardDetailsSheet(card: card),
    ).then((_) {});

Future<void> showCardFilter(
  BuildContext context,
  CardFeaturesCubit cubit,
) async {
  cubit.beginFilter();
  await _sheet<void>(
    context,
    (context) => BlocBuilder<CardFeaturesCubit, CardFeaturesState>(
      bloc: cubit,
      builder: (context, state) {
        final draft = state.draftFilter ?? state.filter;
        return Column(
          key: const Key('card_features_filter_sheet'),
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBottomSheetHeader(
              title: S.current.cardFeatureFilter,
              rightIcon: cardFeatureIcon(AppAssets.cardFeaturesFilterHeader),
              showLeftAction: draft.isActive,
              showTextAction: true,
              textActionLabel: S.current.cardFeatureRemoveFilter,
              textActionColor: AppCardFeatureColors.destructiveAction,
              onLeftAction: cubit.clearDraftFilter,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppSelect<String>(
                    key: const Key('card_features_status_select'),
                    value: draft.status?.name ?? 'all',
                    label: S.current.cardFeatureCardStatus,
                    labelSpacing: 8,
                    labelStyle: _label(context),
                    textStyle: _value(context),
                    trailing: cardFeatureIcon(AppAssets.cardFeaturesChevron),
                    options: [
                      AppSelectOption(
                        value: 'all',
                        label: S.current.cardFeatureAll,
                      ),
                      for (final status in CardStatus.values)
                        AppSelectOption(
                          value: status.name,
                          label: statusLabel(context, status),
                        ),
                    ],
                    onChanged: (value) => cubit.setDraft(
                      CardFilter(
                        status: value == 'all'
                            ? null
                            : CardStatus.values.byName(value),
                        deposit: draft.deposit,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const CardFeatureDivider(),
                  const SizedBox(height: 16),
                  AppSelect<String>(
                    key: const Key('card_features_deposit_select'),
                    value: draft.deposit ?? 'all',
                    label: S.current.cardFeatureDeposit,
                    labelSpacing: 8,
                    labelStyle: _label(context),
                    textStyle: _value(context),
                    trailing: cardFeatureIcon(AppAssets.cardFeaturesChevron),
                    options: [
                      AppSelectOption(
                        value: 'all',
                        label: S.current.cardFeatureAll,
                      ),
                      for (final deposit in state.deposits)
                        AppSelectOption(value: deposit, label: deposit),
                    ],
                    onChanged: (value) => cubit.setDraft(
                      CardFilter(
                        status: draft.status,
                        deposit: value == 'all' ? null : value,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: AppButton(
                key: const Key('card_features_apply_filter'),
                size: AppButtonSize.lg,
                label: S.current.cardFeatureApplyFilter,
                onPressed: () {
                  cubit.applyFilter();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    ),
  );
  if (!cubit.isClosed) cubit.cancelFilter();
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
