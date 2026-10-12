import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'domain/repositories/password_services_repository.dart';
import 'data/repositories/mock_password_repository.dart';
import 'presentation/features/login/cubit/auth_cubit.dart';
import 'presentation/features/login/screens/auth_screen.dart';
import 'presentation/features/password_services/screens/second_password_screen.dart';

class PasswordRouteArguments {
  const PasswordRouteArguments({
    this.initialCardNumber,
    this.selectOperation = false,
    this.repository,
  });
  final String? initialCardNumber;
  final bool selectOperation;
  final PasswordServicesRepository? repository;
}

List<RouteBase> buildAuthRoutes({
  required void Function(BuildContext, GoRouterState) onAuthenticated,
}) {
  // Retain mock receipts across entries, never PINs or identity serials.
  final repository = MockPasswordServicesRepository();
  return [
    GoRoute(
      path: AuthRoutes.login,
      builder: (context, state) => BlocProvider(
        create: (_) => AuthCubit(),
        child: AuthScreen(
          onAuthenticated: () => onAuthenticated(context, state),
        ),
      ),
    ),
    GoRoute(
      path: AuthRoutes.passwords,
      builder: (context, state) {
        final args = state.extra is PasswordRouteArguments
            ? state.extra as PasswordRouteArguments
            : null;
        return SecondPasswordScreen(
          repository: args?.repository ?? repository,
          initialCardNumber: args?.initialCardNumber,
          selectOperation: args?.selectOperation ?? false,
        );
      },
    ),
  ];
}
