import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'presentation/features/home/screens/dashboard_screen.dart';
import 'presentation/shared/dashboard_services.dart';
import 'presentation/features/home/screens/dashboard_all_services_screen.dart';

class AllServicesRouteArguments {
  const AllServicesRouteArguments(this.onServiceRequested);
  final ValueChanged<DashboardService>? onServiceRequested;
}

List<RouteBase> buildDashboardRoutes({WidgetBuilder? homeBuilder}) => [
  GoRoute(
    path: DashboardRoutes.home,
    builder: (context, state) =>
        homeBuilder?.call(context) ?? const DashboardScreen(),
  ),
  GoRoute(
    path: DashboardRoutes.allServices,
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
