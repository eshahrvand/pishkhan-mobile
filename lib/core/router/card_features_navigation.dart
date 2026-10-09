import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/features/cards/cards.dart';

/// Allowlisted routes for the standalone card flow; the Dashboard remains independent.
bool openCardFeaturesService(
  BuildContext context,
  String serviceId, {
  VoidCallback? onAssistantPressed,
}) {
  final category = switch (serviceId) {
    'card-list' => CardCategory.resalat,
    'card-virtual' => CardCategory.virtual,
    'card-expired-gift' => CardCategory.gift,
    _ => null,
  };
  if (category == null) return false;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (routeContext) => CardFeaturesScreen(
        initialCategory: category,
        onAssistantPressed: () {
          Navigator.of(routeContext).pop();
          onAssistantPressed?.call();
        },
      ),
    ),
  );
  return true;
}
