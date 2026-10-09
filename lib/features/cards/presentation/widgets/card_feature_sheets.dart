import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../../domain/entities/listed_card.dart';
import '../card_feature_actions.dart';
import '../card_features_ui.dart';
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
                    child: SvgPicture.asset(
                      AppAssets.cardFeaturesScrim,
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

/// A half-pixel authored separator painted without changing row layout.
Widget _divider() => SizedBox(
  width: double.infinity,
  height: 0,
  child: OverflowBox(
    minHeight: .5,
    maxHeight: .5,
    alignment: Alignment.center,
    child: SvgPicture.asset(AppAssets.cardFeaturesDivider, fit: BoxFit.fill),
  ),
);

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
              if (action != CardFeatureAction.details) _divider(),
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
    _sheet<void>(context, (context) {
      final rows = [
        (context.l10n.cardFeatureNumber, card.number),
        (context.l10n.cardFeatureIban, card.iban),
        (context.l10n.cardFeatureDeposit, card.linkedDeposit),
        (
          context.l10n.cardFeatureDepositType,
          card.depositTypeKey == 'qarz'
              ? context.l10n.cardFeatureQarz
              : card.depositTypeKey,
        ),
        (context.l10n.cardFeatureExpiry, card.expiry),
        (context.l10n.cardFeatureStatus, statusLabel(context, card.status)),
      ];
      return Column(
        key: const Key('card_features_details_sheet'),
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppBottomSheetHeader(type: AppBottomSheetHeaderType.handleOnly),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var index = 0; index < rows.length; index++) ...[
                  if (index > 0) _divider(),
                  SizedBox(
                    height: 56,
                    child: Row(
                      children: [
                        Text(
                          rows[index].$1,
                          style: AppTypography.bodySmall.copyWith(
                            height: 18 / 12,
                            letterSpacing: 0,
                            color: context.colors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            rows[index].$2,
                            textAlign: TextAlign.left,
                            textDirection: index < 3
                                ? TextDirection.ltr
                                : TextDirection.rtl,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.labelMedium.copyWith(
                              height: 18 / 12,
                              letterSpacing: 0,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: AppButton(
              key: const Key('card_features_details_back'),
              onPressed: () => Navigator.of(context).pop(),
              label: context.l10n.backLabel,
              size: AppButtonSize.lg,
            ),
          ),
        ],
      );
    }).then((_) {});

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
              title: context.l10n.cardFeatureFilter,
              rightIcon: cardFeatureIcon(AppAssets.cardFeaturesFilterHeader),
              showLeftAction: draft.isActive,
              showTextAction: true,
              textActionLabel: context.l10n.cardFeatureRemoveFilter,
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
                    label: context.l10n.cardFeatureCardStatus,
                    labelSpacing: 8,
                    labelStyle: _label(context),
                    textStyle: _value(context),
                    trailing: cardFeatureIcon(AppAssets.cardFeaturesChevron),
                    options: [
                      AppSelectOption(
                        value: 'all',
                        label: context.l10n.cardFeatureAll,
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
                  _divider(),
                  const SizedBox(height: 16),
                  AppSelect<String>(
                    key: const Key('card_features_deposit_select'),
                    value: draft.deposit ?? 'all',
                    label: context.l10n.cardFeatureDeposit,
                    labelSpacing: 8,
                    labelStyle: _label(context),
                    textStyle: _value(context),
                    trailing: cardFeatureIcon(AppAssets.cardFeaturesChevron),
                    options: [
                      AppSelectOption(
                        value: 'all',
                        label: context.l10n.cardFeatureAll,
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
                label: context.l10n.cardFeatureApplyFilter,
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
