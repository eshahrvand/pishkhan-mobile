import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/features/auth/auth_routes.dart';
import 'package:pishkhan_mobile/features/cards/cards_routes.dart';
import 'package:pishkhan_mobile/features/profile/profile_routes.dart';
import 'package:pishkhan_mobile/features/dashboard/dashboard_routes.dart';
import 'package:pishkhan_mobile/features/launch/launch_routes.dart';
import 'package:pishkhan_mobile/features/launch/presentation/shared/widgets/route_unavailable_screen.dart';

import 'router_session.dart';
import 'guards/auth_guard.dart';
import 'validated_return_location.dart';

export 'validated_return_location.dart' show validatedReturnLocation;

List<RouteBase> buildAppRoutes({
  required RouterSession session,
  WidgetBuilder? homeBuilder,
}) => [
  ...buildLaunchRoutes(),
  ...buildDashboardRoutes(homeBuilder: homeBuilder),
  ...buildAuthRoutes(
    onAuthenticated: (context, state) {
      final destination = validatedReturnLocation(
        state.uri.queryParameters['from'],
      );
      final extra = session.takePendingExtra();
      session.signIn();
      context.go(destination, extra: extra);
    },
  ),
  ...buildCardsRoutes(),
  ...buildProfileRoutes(),
];

GoRouter createAppRouter({
  required RouterSession session,
  WidgetBuilder? homeBuilder,
  String initialLocation = LaunchRoutes.splash,
}) => GoRouter(
  initialLocation: initialLocation,
  refreshListenable: session,
  redirect: (context, state) => globalRedirect(session, state),
  routes: buildAppRoutes(session: session, homeBuilder: homeBuilder),
  errorBuilder: (context, state) => const RouteUnavailableScreen(),
);

String? globalRedirect(RouterSession session, GoRouterState state) =>
    authRedirect(session, state);
