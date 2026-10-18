import 'package:go_router/go_router.dart';

import '../app_routes.dart';
import '../router_session.dart';
import '../validated_return_location.dart';

String? authRedirect(RouterSession session, GoRouterState state) {
  if (state.matchedLocation == AppRoutes.splash) return null;
  final login = state.matchedLocation == AppRoutes.login;
  if (!session.isAuthenticated && !login) {
    session.pendingExtra = state.extra;
    return Uri(
      path: AppRoutes.login,
      queryParameters: {'from': validatedReturnLocation(state.uri.toString())},
    ).toString();
  }
  if (session.isAuthenticated && login) {
    return validatedReturnLocation(state.uri.queryParameters['from']);
  }
  return null;
}
