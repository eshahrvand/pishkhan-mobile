import 'package:pishkhan_mobile/features/launch/presentation/shared/widgets/route_unavailable_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:pishkhan_mobile/features/launch/presentation/splash/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/screens/dashboard_screen.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/screens/dashboard_all_services_screen.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/screens/auth_screen.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/password_services_repository.dart';
import 'package:pishkhan_mobile/features/cards/data/repositories/mock_password_repository.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/screens/second_password_screen.dart';
import 'package:pishkhan_mobile/features/cards/domain/entities/listed_card.dart';
import 'package:pishkhan_mobile/features/cards/presentation/card_features/screens/card_features_screen.dart';
import 'package:pishkhan_mobile/features/cards/presentation/card_issuance/screens/card_issuance_screen.dart';
import 'package:pishkhan_mobile/features/cards/presentation/virtual_card_request/screens/virtual_card_request_screen.dart';
import 'package:pishkhan_mobile/features/cards/presentation/change_card_deposit/screens/change_card_deposit_screen.dart';
import 'package:pishkhan_mobile/features/cards/presentation/expired_gift_balance/screens/expired_gift_balance_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/deposit_list/screens/deposit_list_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/average_balance/screens/average_balance_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/financial_certificate/screens/financial_certificate_screen.dart';
import 'package:pishkhan_mobile/features/profile/domain/entities/notification_message.dart';
import 'package:pishkhan_mobile/features/profile/presentation/message_center/screens/notifications_screen.dart';
import 'package:pishkhan_mobile/features/profile/presentation/message_center/screens/notification_detail_screen.dart';

import 'router_session.dart';
import 'guards/auth_guard.dart';
import 'validated_return_location.dart';

export 'validated_return_location.dart' show validatedReturnLocation;

GoRouter createAppRouter({
  required RouterSession session,
  WidgetBuilder? homeBuilder,
  String initialLocation = AppRoutes.splash,
}) {
  // Retain mock receipts for this router's lifetime, never PINs or identity serials.
  final passwordRepository = MockPasswordServicesRepository();
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: session,
    redirect: (context, state) => globalRedirect(session, state),
    routes: [
      // Launch
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Dashboard
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) =>
            homeBuilder?.call(context) ?? const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.allServices,
        builder: (context, state) {
          final args = state.extra is AllServicesRouteArguments
              ? state.extra as AllServicesRouteArguments
              : null;
          return DashboardAllServicesScreen(
            onServiceRequested: args?.onServiceRequested,
          );
        },
      ),

      // Auth
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => AuthScreen(
          onAuthenticated: () {
            final destination = validatedReturnLocation(
              state.uri.queryParameters['from'],
            );
            final extra = session.takePendingExtra();
            session.signIn();
            context.go(destination, extra: extra);
          },
        ),
      ),

      // Cards
      GoRoute(
        path: AppRoutes.cardPasswords,
        builder: (context, state) {
          final args = state.extra is PasswordRouteArguments
              ? state.extra as PasswordRouteArguments
              : null;
          return SecondPasswordScreen(
            repository: args?.repository ?? passwordRepository,
            initialCardNumber: args?.initialCardNumber,
            selectOperation: args?.selectOperation ?? false,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.changeCardDeposit,
        builder: (context, state) => ChangeCardDepositScreen(
          initialCardNumber: state.extra is CardRouteArguments
              ? (state.extra as CardRouteArguments).initialCardNumber
              : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.expiredGiftBalance,
        builder: (context, state) => const ExpiredGiftBalanceScreen(),
      ),
      GoRoute(
        path: AppRoutes.cardList,
        builder: (context, state) {
          final category =
              CardCategory.values
                  .where((c) => c.name == state.uri.queryParameters['category'])
                  .firstOrNull ??
              CardCategory.resalat;
          final args = state.extra is CardRouteArguments
              ? state.extra as CardRouteArguments
              : null;
          return CardFeaturesScreen(
            initialCategory: category,
            onAssistantPressed: () {
              NavigationActions.back(context);
              args?.onAssistantPressed?.call();
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.cardIssuance,
        builder: (context, state) {
          final args = state.extra is CardRouteArguments
              ? state.extra as CardRouteArguments
              : null;
          return CardIssuanceScreen(
            initialDepositNumber: args?.initialDepositNumber,
            onAssistantPressed: () {
              NavigationActions.back(context);
              args?.onAssistantPressed?.call();
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.virtualCardRequest,
        builder: (context, state) {
          final args = state.extra is CardRouteArguments
              ? state.extra as CardRouteArguments
              : null;
          return VirtualCardRequestScreen(
            initialDepositNumber: args?.initialDepositNumber,
          );
        },
      ),

      // Deposits
      GoRoute(
        path: AppRoutes.financialCertificate,
        builder: (context, state) => FinancialCertificateScreen(
          initialDepositNumber: state.extra is CertificateRouteArguments
              ? (state.extra as CertificateRouteArguments).initialDepositNumber
              : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.averageBalance,
        builder: (context, state) => AverageBalanceScreen(
          initialDepositNumber: state.extra is CertificateRouteArguments
              ? (state.extra as CertificateRouteArguments).initialDepositNumber
              : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.depositList,
        builder: (context, state) => DepositListScreen(
          onAssistantPressed: state.extra is DepositListRouteArguments
              ? (state.extra as DepositListRouteArguments).onAssistantPressed
              : null,
        ),
      ),

      // Profile
      GoRoute(
        path: AppRoutes.messages,
        builder: (context, state) {
          final args = state.extra is MessageCenterRouteArguments
              ? state.extra as MessageCenterRouteArguments
              : null;
          return NotificationsScreen(
            messages: args?.messages ?? NotificationMessage.examples(),
            onChanged: args?.onChanged,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.messageDetail,
        builder: (context, state) {
          final message = state.extra is NotificationMessage
              ? state.extra as NotificationMessage
              : NotificationMessage.examples()
                    .where((m) => m.id == state.pathParameters['messageId'])
                    .firstOrNull;
          return message == null
              ? const NotificationsScreen(messages: [])
              : NotificationDetailScreen(message: message);
        },
      ),
    ],
    errorBuilder: (context, state) => const RouteUnavailableScreen(),
  );
}

String? globalRedirect(RouterSession session, GoRouterState state) =>
    authRedirect(session, state);

class AllServicesRouteArguments {
  const AllServicesRouteArguments(this.onServiceRequested);
  final ValueChanged<DashboardService>? onServiceRequested;
}

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

class CardRouteArguments {
  const CardRouteArguments({
    this.initialDepositNumber,
    this.initialCardNumber,
    this.onAssistantPressed,
  });
  final String? initialDepositNumber;
  final String? initialCardNumber;
  final VoidCallback? onAssistantPressed;
}

class CertificateRouteArguments {
  const CertificateRouteArguments({this.initialDepositNumber});
  final String? initialDepositNumber;
}

class DepositListRouteArguments {
  const DepositListRouteArguments({this.onAssistantPressed});
  final VoidCallback? onAssistantPressed;
}

class MessageCenterRouteArguments {
  const MessageCenterRouteArguments({required this.messages, this.onChanged});
  final List<NotificationMessage> messages;
  final ValueChanged<List<NotificationMessage>>? onChanged;
}
