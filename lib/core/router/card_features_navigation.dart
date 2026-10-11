import 'package:flutter/material.dart';

import '../flow/service_registry.dart';

/// Compatibility entry point for callers; navigation is owned by GoRouter.
bool openCardFeaturesService(
  BuildContext context,
  String serviceId, {
  VoidCallback? onAssistantPressed,
  String? initialDepositNumber,
  String? initialCardNumber,
}) => ServiceRegistry.openCardService(
  context,
  serviceId,
  onAssistantPressed: onAssistantPressed,
  initialDepositNumber: initialDepositNumber,
  initialCardNumber: initialCardNumber,
);
