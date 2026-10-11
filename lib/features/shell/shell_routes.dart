import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'presentation/flows/home/screens/dashboard_screen.dart';
import 'presentation/shared/dashboard_services.dart';
import 'presentation/shared/widgets/dashboard_all_services_screen.dart';

class AllServicesRouteArguments {
  const AllServicesRouteArguments(this.onServiceRequested);
  final ValueChanged<DashboardService>? onServiceRequested;
}

abstract final class ShellRoutes {
  static const home = '/shell/home';
  static const allServices = '/shell/services';
  static List<RouteBase> build({WidgetBuilder? homeBuilder}) => [
    GoRoute(
      path: home,
      builder: (context, state) =>
          homeBuilder?.call(context) ?? const DashboardScreen(),
    ),
    GoRoute(
      path: allServices,
      builder: (context, state) {
        final args = state.extra is AllServicesRouteArguments
            ? state.extra as AllServicesRouteArguments
            : null;
        return DashboardAllServicesScreen(
          onServiceRequested: args?.onServiceRequested,
        );
      },
    ),
  ];
}
