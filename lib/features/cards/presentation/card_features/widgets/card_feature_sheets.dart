import 'card_feature_sheet_frame.dart';
import 'card_filter_sheet.dart';
import 'card_actions_sheet.dart';
import 'card_details_sheet.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/listed_card.dart';
import '../card_feature_action.dart';
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
    builder: (sheetContext) =>
        CardFeatureSheetFrame(insets: insets, child: panel(sheetContext)),
  );
}

Future<CardFeatureAction?> showCardActions(
  BuildContext context,
  ListedCard card,
) => _sheet<CardFeatureAction>(context, (context) => const CardActionsSheet());

Future<void> showCardDetails(BuildContext context, ListedCard card) async {
  await _sheet<void>(context, (context) => CardDetailsSheet(card: card));
}

Future<bool?> showCardFilter(BuildContext context, CardFeaturesCubit cubit) {
  return _sheet<bool>(
    context,
    (context) =>
        BlocProvider.value(value: cubit, child: const CardFilterSheet()),
  );
}
