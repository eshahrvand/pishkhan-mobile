import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/features/cards/cards.dart';
import 'package:pishkhan_mobile/features/card_issuance/card_issuance.dart';
import 'package:pishkhan_mobile/features/password_services/password_services.dart';

// Retains mock request status across route entries; never retains passwords.
final _passwordRepository = MockPasswordServicesRepository();

/// Allowlisted routes for the standalone card flow; the Dashboard remains independent.
bool openCardFeaturesService(
  BuildContext context,
  String serviceId, {
  VoidCallback? onAssistantPressed,
  String? initialDepositNumber,
  String? initialCardNumber,
}) {
  if (serviceId == 'card-password' || serviceId == 'card-pin-second-set') {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SecondPasswordScreen(
          repository: _passwordRepository,
          initialCardNumber: initialCardNumber,
        ),
      ),
    );
    return true;
  }
  if (serviceId == 'card-issue' || serviceId == 'card-reissue') {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (routeContext) => CardIssuanceScreen(
          initialDepositNumber: initialDepositNumber,
          onAssistantPressed: () {
            Navigator.of(routeContext).pop();
            onAssistantPressed?.call();
          },
        ),
      ),
    );
    return true;
  }
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
