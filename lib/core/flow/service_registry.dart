import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/features/cards/cards_routes.dart';
import 'package:pishkhan_mobile/features/deposits/deposits_routes.dart';
import 'package:pishkhan_mobile/features/cards/domain/entities/listed_card.dart';

abstract final class ServiceRegistry {
  static bool openCardService(
    BuildContext context,
    String id, {
    VoidCallback? onAssistantPressed,
    String? initialDepositNumber,
    String? initialCardNumber,
  }) {
    if (id == 'deposit-certificate') {
      context.push<void>(
        DepositsRoutes.financialCertificate,
        extra: CertificateRouteArguments(
          initialDepositNumber: initialDepositNumber,
        ),
      );
      return true;
    }
    if (id == 'deposit-statement') {
      context.push<void>(
        DepositsRoutes.averageBalance,
        extra: CertificateRouteArguments(
          initialDepositNumber: initialDepositNumber,
        ),
      );
      return true;
    }
    if (id == 'deposit-list') {
      context.push<void>(
        DepositsRoutes.list,
        extra: DepositListRouteArguments(
          onAssistantPressed: () {
            context.go(DashboardRoutes.home);
            onAssistantPressed?.call();
          },
        ),
      );
      return true;
    }
    if (const {
      'card-password',
      'card-pin-second-set',
      'card-pin-second-forgot',
      'card-pin-second-change',
    }.contains(id)) {
      context.push<void>(
        CardsRoutes.passwords,
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
      initialCardNumber: initialCardNumber,
      onAssistantPressed: onAssistantPressed,
    );
    if (id == 'card-deposit') {
      context.push<void>(CardsRoutes.changeDeposit, extra: args);
      return true;
    }
    if (id == 'card-expired-gift') {
      context.push<void>(CardsRoutes.expiredGiftBalance, extra: args);
      return true;
    }
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
      _ => null,
    };
    if (category == null) return false;
    context.push<void>(cardsListLocation(category), extra: args);
    return true;
  }

  static void returnHome(BuildContext context) =>
      context.go(DashboardRoutes.home);
}
