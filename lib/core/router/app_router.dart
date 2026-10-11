import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/features/auth/auth_routes.dart';
import 'package:pishkhan_mobile/features/cards/cards_routes.dart';
import 'package:pishkhan_mobile/features/profile/profile_routes.dart';
import 'package:pishkhan_mobile/features/shell/shell_routes.dart';
import 'package:pishkhan_mobile/features/shell/presentation/shared/widgets/route_unavailable_screen.dart';

import 'router_session.dart';

/// Only implemented destinations are allowed after login; no external URLs.
String validatedReturnLocation(String? location) {
  final uri = location == null ? null : Uri.tryParse(location);
  if (uri == null || uri.hasScheme || uri.hasAuthority || uri.hasFragment) {
    return ShellRoutes.home;
  }
  const paths = {
    ShellRoutes.home,
    ShellRoutes.allServices,
    CardsRoutes.list,
    CardsRoutes.issuance,
    CardsRoutes.virtualRequest,
    AuthRoutes.passwords,
    ProfileRoutes.messages,
  };
  final detail =
      uri.pathSegments.length == 3 &&
      uri.pathSegments[0] == 'profile' &&
      uri.pathSegments[1] == 'messages' &&
      uri.pathSegments[2].isNotEmpty;
  if (!paths.contains(uri.path) && !detail) return ShellRoutes.home;
  if (uri.hasQuery) {
    if (uri.path != CardsRoutes.list ||
        uri.queryParametersAll.keys.any((k) => k != 'category') ||
        uri.queryParametersAll['category']?.length != 1 ||
        !const {
          'resalat',
          'gift',
          'virtual',
          'coupon',
          'family',
        }.contains(uri.queryParameters['category'])) {
      return ShellRoutes.home;
    }
  }
  return uri.toString();
}

List<RouteBase> buildAppRoutes({
  required RouterSession session,
  WidgetBuilder? homeBuilder,
}) => [
  ...AuthRoutes.build(
    onAuthenticated: (context, state) {
      final destination = validatedReturnLocation(
        state.uri.queryParameters['from'],
      );
      final extra = session.takePendingExtra();
      session.signIn();
      context.go(destination, extra: extra);
    },
  ),
  ...ShellRoutes.build(homeBuilder: homeBuilder),
  ...CardsRoutes.build(),
  ...ProfileRoutes.build(),
];

GoRouter createAppRouter({
  required RouterSession session,
  WidgetBuilder? homeBuilder,
  String initialLocation = ShellRoutes.home,
}) => GoRouter(
  initialLocation: initialLocation,
  refreshListenable: session,
  // One synchronous global redirect. Security/update/platform evaluations can
  // precede auth here when their bank-backed services exist.
  redirect: (context, state) {
    final login = state.matchedLocation == AuthRoutes.login;
    if (!session.isAuthenticated && !login) {
      session.pendingExtra = state.extra;
      return Uri(
        path: AuthRoutes.login,
        queryParameters: {
          'from': validatedReturnLocation(state.uri.toString()),
        },
      ).toString();
    }
    if (session.isAuthenticated && login) {
      return validatedReturnLocation(state.uri.queryParameters['from']);
    }
    return null;
  },
  routes: buildAppRoutes(session: session, homeBuilder: homeBuilder),
  errorBuilder: (context, state) => const RouteUnavailableScreen(),
);
