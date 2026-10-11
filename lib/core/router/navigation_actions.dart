import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/features/shell/shell_routes.dart';

abstract final class NavigationActions {
  static void returnHome(BuildContext context) => context.go(ShellRoutes.home);
  static void back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      returnHome(context);
    }
  }
}
