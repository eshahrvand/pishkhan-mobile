import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'presentation/login/screens/auth_screen.dart';

List<RouteBase> buildAuthRoutes({
  required void Function(BuildContext, GoRouterState) onAuthenticated,
}) {
  return [
    GoRoute(
      path: AuthRoutes.login,
      builder: (context, state) =>
          AuthScreen(onAuthenticated: () => onAuthenticated(context, state)),
    ),
  ];
}
