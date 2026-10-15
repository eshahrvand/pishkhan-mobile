import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'domain/repositories/password_services_repository.dart';
import 'data/repositories/mock_password_repository.dart';
import 'presentation/password_services/screens/second_password_screen.dart';
import 'domain/entities/listed_card.dart';
import 'presentation/card_features/screens/card_features_screen.dart';
import 'presentation/card_issuance/screens/card_issuance_screen.dart';
import 'presentation/virtual_card_request/screens/virtual_card_request_screen.dart';
import 'presentation/change_card_deposit/screens/change_card_deposit_screen.dart';
import 'presentation/expired_gift_balance/screens/expired_gift_balance_screen.dart';

class PasswordRouteArguments {
  const PasswordRouteArguments({
    this.initialCardNumber,
    this.selectOperation = false,
    this.repository,
  });
  final String? initialCardNumber;
  final bool selectOperation;
  final PasswordServicesRepository? repository;
}

class CardRouteArguments {
  const CardRouteArguments({
    this.initialDepositNumber,
    this.initialCardNumber,
    this.onAssistantPressed,
  });
  final String? initialDepositNumber;
  final String? initialCardNumber;
  final VoidCallback? onAssistantPressed;
}

List<RouteBase> buildCardsRoutes() {
  // Retain mock receipts across entries, never PINs or identity serials.
  final repository = MockPasswordServicesRepository();
  return [
    GoRoute(
      path: CardsRoutes.passwords,
      builder: (context, state) {
        final args = state.extra is PasswordRouteArguments
            ? state.extra as PasswordRouteArguments
            : null;
        return SecondPasswordScreen(
          repository: args?.repository ?? repository,
          initialCardNumber: args?.initialCardNumber,
          selectOperation: args?.selectOperation ?? false,
        );
      },
    ),

    GoRoute(
      path: CardsRoutes.changeDeposit,
      builder: (context, state) => ChangeCardDepositScreen(
        initialCardNumber: state.extra is CardRouteArguments
            ? (state.extra as CardRouteArguments).initialCardNumber
            : null,
      ),
    ),
    GoRoute(
      path: CardsRoutes.expiredGiftBalance,
      builder: (context, state) => const ExpiredGiftBalanceScreen(),
    ),
    GoRoute(
      path: CardsRoutes.list,
      builder: (context, state) {
        final category =
            CardCategory.values
                .where((c) => c.name == state.uri.queryParameters['category'])
                .firstOrNull ??
            CardCategory.resalat;
        final args = state.extra is CardRouteArguments
            ? state.extra as CardRouteArguments
            : null;
        return CardFeaturesScreen(
          initialCategory: category,
          onAssistantPressed: () {
            NavigationActions.back(context);
            args?.onAssistantPressed?.call();
          },
        );
      },
    ),
    GoRoute(
      path: CardsRoutes.issuance,
      builder: (context, state) {
        final args = state.extra is CardRouteArguments
            ? state.extra as CardRouteArguments
            : null;
        return CardIssuanceScreen(
          initialDepositNumber: args?.initialDepositNumber,
          onAssistantPressed: () {
            NavigationActions.back(context);
            args?.onAssistantPressed?.call();
          },
        );
      },
    ),
    GoRoute(
      path: CardsRoutes.virtualRequest,
      builder: (context, state) {
        final args = state.extra is CardRouteArguments
            ? state.extra as CardRouteArguments
            : null;
        return VirtualCardRequestScreen(
          initialDepositNumber: args?.initialDepositNumber,
        );
      },
    ),
  ];
}

String cardsListLocation(CardCategory category) => Uri(
  path: CardsRoutes.list,
  queryParameters: {'category': category.name},
).toString();
