import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/router/app_routes.dart';

import 'presentation/deposit_list/screens/deposit_list_screen.dart';

class DepositListRouteArguments {
  const DepositListRouteArguments({this.onAssistantPressed});
  final VoidCallback? onAssistantPressed;
}

List<RouteBase> buildDepositsRoutes() => [
  GoRoute(
    path: DepositsRoutes.list,
    builder: (context, state) => DepositListScreen(
      onAssistantPressed: state.extra is DepositListRouteArguments
          ? (state.extra as DepositListRouteArguments).onAssistantPressed
          : null,
    ),
  ),
];
