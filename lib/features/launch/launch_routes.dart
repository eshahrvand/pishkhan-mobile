import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/router/app_routes.dart';

import 'presentation/splash/screens/splash_screen.dart';

List<RouteBase> buildLaunchRoutes() => [
  GoRoute(
    path: LaunchRoutes.splash,
    builder: (context, state) => const SplashScreen(),
  ),
];
