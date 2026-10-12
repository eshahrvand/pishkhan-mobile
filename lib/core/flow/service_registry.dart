import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/modules/auth/auth_routes.dart';
import 'package:pishkhan_mobile/modules/cards/cards_routes.dart';
import 'package:pishkhan_mobile/modules/cards/domain/entities/listed_card.dart';

abstract final class ServiceRegistry {
  static bool openCardService(
    BuildContext context,
    String id, {
    VoidCallback? onAssistantPressed,
    String? initialDepositNumber,
    String? initialCardNumber,
  }) {
    if (const {
      'card-password',
      'card-pin-second-set',
      'card-pin-second-forgot',
      'card-pin-second-change',
    }.contains(id)) {
      context.push<void>(
        AuthRoutes.passwords,
        extra: PasswordRouteArguments(
          initialCardNumber: initialCardNumber,
          selectOperation:
              id == 'card-pin-second-forgot' || id == 'card-pin-second-change',
        ),
      );
      return true;
    }
    final args = CardRouteArguments(
      initialDepositNumber: initialDepositNumber,
      onAssistantPressed: onAssistantPressed,
    );
    if (id == 'card-virtual' || id == 'card-virtual-request') {
      context.push<void>(CardsRoutes.virtualRequest, extra: args);
      return true;
    }
    if (id == 'card-issue' || id == 'card-reissue') {
      context.push<void>(CardsRoutes.issuance, extra: args);
      return true;
    }
    final category = switch (id) {
      'card-list' => CardCategory.resalat,
      'card-virtual-list' => CardCategory.virtual,
      'card-expired-gift' => CardCategory.gift,
      _ => null,
    };
    if (category == null) return false;
    context.push<void>(cardsListLocation(category), extra: args);
    return true;
  }

  static void returnHome(BuildContext context) =>
      context.go(DashboardRoutes.home);
}
