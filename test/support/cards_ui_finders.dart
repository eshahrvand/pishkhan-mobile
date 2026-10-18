import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/cards/domain/entities/listed_card.dart';
import 'package:pishkhan_mobile/features/cards/presentation/card_features/cubit/card_features_cubit.dart';
import 'package:pishkhan_mobile/features/cards/presentation/card_features/card_feature_action.dart';
import 'package:pishkhan_mobile/features/cards/presentation/card_features/widgets/card_features_content.dart';
import 'package:pishkhan_mobile/features/cards/presentation/card_features/widgets/card_features_ui.dart';
import 'package:pishkhan_mobile/features/cards/presentation/card_issuance/widgets/issuance_select.dart';
import 'package:pishkhan_mobile/features/cards/presentation/card_issuance/widgets/issuance_toggle_row.dart';
import 'package:pishkhan_mobile/features/cards/presentation/virtual_card_request/widgets/virtual_card_notice.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_cards_list.dart';
import 'package:pishkhan_mobile/shared/widgets/app_invoice.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';
import 'package:pishkhan_mobile/shared/widgets/app_address_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_delete_address_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/app_delete_address_button.dart';

/// Locate controls by their public content and widget structure, without UI keys.
Finder cardControl(WidgetTester tester, String name) {
  Finder button(String label) => find.byWidgetPredicate(
    (widget) => widget is AppButton && widget.label == label,
  );
  Finder input(String label) => find.byWidgetPredicate(
    (widget) => widget is AppTextField && widget.label == label,
  );
  Finder select(String label) => find.byWidgetPredicate(
    (widget) => widget is AppSelect && widget.label == label,
  );
  Finder issuanceSelect(List<String> labels) => find.byWidgetPredicate(
    (widget) => widget is IssuanceSelect && labels.contains(widget.label),
  );
  Finder toggle(String label) => find.byWidgetPredicate(
    (widget) => widget is IssuanceToggleRow && widget.label == label,
  );
  Finder containerAround(Finder child) =>
      find.ancestor(of: child, matching: find.byType(Container)).first;
  if (name.startsWith('card_category_')) {
    final category = CardCategory.values.byName(
      name.substring('card_category_'.length),
    );
    final label = categoryLabel(category);
    return find.byWidgetPredicate(
      (widget) => widget is AppChips && widget.label == label,
    );
  }
  if (name.startsWith('card_feature_action_')) {
    final action = CardFeatureAction.values.byName(
      name.substring('card_feature_action_'.length),
    );
    final label = actionLabel(action);
    return find
        .ancestor(of: find.text(label), matching: find.byType(InkWell))
        .first;
  }
  if (name.startsWith('listed_card_')) {
    final state = tester
        .element(find.byType(CardFeaturesContent))
        .read<CardFeaturesCubit>()
        .state;
    final index = state.visibleCards.indexWhere(
      (card) => card.id == name.substring('listed_card_'.length),
    );
    return index < 0
        ? find.byWidgetPredicate((_) => false)
        : find.byType(AppCardsList).at(index);
  }
  return switch (name) {
    'card_features_actions_sheet' ||
    'card_features_filter_sheet' ||
    'card_features_details_sheet' => find.byWidgetPredicate(
      (widget) =>
          widget is Column &&
          widget.children.isNotEmpty &&
          widget.children.first is AppBottomSheetHeader,
    ),
    'card_features_retry' ||
    'issuance_retry' => button(S.current.dashboardRetry),
    'card_features_search' => find.byType(AppSearchField),
    'card_features_filter_button' => find.byWidgetPredicate(
      (widget) =>
          widget is AppButton && widget.tooltip == S.current.cardFeatureFilter,
    ),
    'card_features_status_select' => select(S.current.cardFeatureCardStatus),
    'card_features_deposit_select' => select(S.current.cardFeatureDeposit),
    'card_features_apply_filter' => button(S.current.cardFeatureApplyFilter),
    'card_features_details_back' => button(S.current.backLabel),
    'card_features_footer' => find.byWidgetPredicate(
      (widget) =>
          widget is AppButton &&
          [
            S.current.cardFeatureGiftTransfer,
            S.current.cardFeatureVirtualRequest,
          ].contains(widget.label),
    ),
    'card_features_assistant' ||
    'issuance_assistant' => find.byType(AppAssistantButton),
    'card_features_list' => find.descendant(
      of: find.byType(CardFeaturesContent),
      matching: find.byType(ListView),
    ),
    'card_features_categories' => find.byWidgetPredicate(
      (widget) =>
          widget is SingleChildScrollView &&
          widget.scrollDirection == Axis.horizontal,
    ),
    'issuance_deposit' => issuanceSelect([S.current.issuanceDeposit]),
    'issuance_type' => issuanceSelect([S.current.issuanceType]),
    'issuance_address' => issuanceSelect([
      S.current.issuanceAddress,
      S.current.issuanceSelectAddress,
    ]),
    'issuance_address_card' => find.byType(AppAddressCard),
    'issuance_add_address' => button(S.current.issuanceAddAddress),
    'issuance_no_physical' => toggle(S.current.issuanceNoPhysical),
    'issuance_other_recipient' => toggle(S.current.issuanceOtherRecipient),
    'issuance_agent' => toggle(S.current.issuanceIncludeAgent),
    'issuance_new_address_title' => input(S.current.issuanceAddressTitle),
    'issuance_new_address_detail' => find.byWidgetPredicate(
      (widget) =>
          widget is AppTextArea &&
          widget.label == S.current.issuanceAddressDetail,
    ),
    'issuance_new_address_postal' => input(S.current.issuancePostalCode),
    'issuance_save_address' => button(S.current.issuanceSaveAddress),
    'issuance_recipient_name' => input(S.current.issuanceRecipientName),
    'issuance_recipient_national' => input(S.current.issuanceNationalId),
    'issuance_recipient_mobile' => input(S.current.issuanceRecipientMobile),
    'issuance_agent_name' => input(S.current.issuanceAgentName),
    'issuance_agent_code' => input(S.current.issuanceAgentCode),
    'issuance_continue' => find.byWidgetPredicate(
      (widget) =>
          widget is AppButton &&
          [
            S.current.issuanceNext,
            S.current.issuanceSubmit,
          ].contains(widget.label),
    ),
    'issuance_done' => button(S.current.issuanceDone),
    'issuance_stepper' => find.byType(AppStepper),
    'issuance_summary' => containerAround(find.text(S.current.issuanceSummary)),
    'issuance_summary_toggle' =>
      find
          .ancestor(
            of: find.text(S.current.issuanceSummary),
            matching: find.byType(InkWell),
          )
          .first,
    'issuance_terms_checkbox' => find.byType(AppCheckbox),
    'issuance_terms_link' =>
      find
          .ancestor(
            of: find.text(S.current.issuanceTerms),
            matching: find.byType(InkWell),
          )
          .first,
    'issuance_terms_row' => containerAround(find.byType(AppCheckbox)),
    'issuance_invoice' || 'virtual_invoice' => find.byType(AppInvoice),
    'virtual_notice' =>
      find
          .descendant(
            of: find.byType(VirtualCardNotice).first,
            matching: find.byType(Container),
          )
          .first,
    'virtual_deposit' => select(S.current.virtualRequestDepositLabel),
    'virtual_count' => find.byWidgetPredicate(
      (widget) =>
          widget is AppTextField &&
          widget.hintText == S.current.virtualRequestCountHint,
    ),
    'virtual_terms' => find.byType(AppCheckbox),
    'virtual_submit' => button(S.current.virtualRequestSubmit),
    'virtual_card_fee_art' => find.byWidgetPredicate(
      (widget) =>
          widget is AvpImage && widget.image == AppAssets.virtualRequestCard,
    ),
    // These controls belong to shared components, outside the Cards feature.
    'app_delete_address_cancel' => find.widgetWithText(
      AppDeleteAddressButton,
      tester
          .widget<AppDeleteAddressSheet>(find.byType(AppDeleteAddressSheet))
          .cancelLabel,
    ),
    'app_delete_address_confirm' => find.widgetWithText(
      AppDeleteAddressButton,
      tester
          .widget<AppDeleteAddressSheet>(find.byType(AppDeleteAddressSheet))
          .confirmLabel,
    ),
    _ => throw ArgumentError.value(name, 'name', 'Unknown card control'),
  };
}
