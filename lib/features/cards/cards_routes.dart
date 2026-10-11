import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'domain/entities/listed_card.dart';
import 'presentation/flows/card_features/screens/card_features_screen.dart';
import 'presentation/flows/card_issuance/screens/card_issuance_screen.dart';
import 'presentation/flows/virtual_card_request/screens/virtual_card_request_screen.dart';

class CardRouteArguments {
  const CardRouteArguments({
    this.initialDepositNumber,
    this.onAssistantPressed,
  });
  final String? initialDepositNumber;
  final VoidCallback? onAssistantPressed;
}

abstract final class CardsRoutes {
  static const list = '/cards/list';
  static const issuance = '/cards/issuance';
  static const virtualRequest = '/cards/virtual-request';
  static String listLocation(CardCategory category) =>
      Uri(path: list, queryParameters: {'category': category.name}).toString();
  static List<RouteBase> build() => [
    GoRoute(
      path: list,
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
      path: issuance,
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
      path: virtualRequest,
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
