import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'domain/repositories/password_services_repository.dart';
import 'data/repositories/mock_password_repository.dart';
import 'presentation/flows/login/cubit/auth_cubit.dart';
import 'presentation/flows/login/screens/auth_screen.dart';
import 'presentation/flows/password_services/screens/second_password_screen.dart';

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

abstract final class AuthRoutes {
  static const login = '/auth/login';
  static const passwords = '/auth/password-services';
  static List<RouteBase> build({
    required void Function(BuildContext, GoRouterState) onAuthenticated,
  }) {
    // Retain mock receipts across entries, never PINs or identity serials.
    final repository = MockPasswordServicesRepository();
    return [
      GoRoute(
        path: login,
        builder: (context, state) => BlocProvider(
          create: (_) => AuthCubit(),
          child: AuthScreen(
            onAuthenticated: () => onAuthenticated(context, state),
          ),
        ),
      ),
      GoRoute(
        path: passwords,
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
}
