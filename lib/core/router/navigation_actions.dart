import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract final class NavigationActions {
  static void returnHome(BuildContext context) => context.go(AppRoutes.home);
  static void back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      returnHome(context);
    }
  }
}
