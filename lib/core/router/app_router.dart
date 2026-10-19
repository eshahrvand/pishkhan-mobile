import 'package:pishkhan_mobile/features/cheque/presentation/cancellation/screens/cheque_cancellation_screen.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/book_issuance/screens/cheque_book_screen.dart';
import 'package:pishkhan_mobile/features/cheque/presentation/clearance/screens/cheque_clearance_screen.dart';
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
import 'package:pishkhan_mobile/features/cards/presentation/password_services/screens/second_password_screen.dart';
import 'package:pishkhan_mobile/features/cards/domain/entities/listed_card.dart';
import 'package:pishkhan_mobile/features/cards/presentation/card_features/screens/card_list_screen.dart';
import 'package:pishkhan_mobile/features/cards/presentation/card_issuance/screens/card_issuance_screen.dart';
import 'package:pishkhan_mobile/features/cards/presentation/virtual_card_request/screens/virtual_card_request_screen.dart';
import 'package:pishkhan_mobile/features/cards/presentation/change_card_deposit/screens/change_card_deposit_screen.dart';
import 'package:pishkhan_mobile/features/cards/presentation/expired_gift_balance/screens/expired_gift_balance_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/deposit_list/screens/deposit_list_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/average_balance/screens/average_balance_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/financial_certificate/screens/financial_certificate_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/introduce_agent/screens/introduce_agent_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/agent_settings/screens/agent_settings_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/close_surplus_deposits/screens/close_surplus_deposits_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/deposit_restriction/screens/deposit_restriction_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/proxy_deposit/screens/proxy_deposit_screen.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/deposit_restriction.dart';
import 'package:pishkhan_mobile/core/notifications/notification_message.dart';
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

      GoRoute(
        path: AppRoutes.chequeCancellation,
        builder: (context, state) {
          final args = state.extra is ChequeCancellationRouteArguments
              ? state.extra as ChequeCancellationRouteArguments
              : null;
          return ChequeCancellationScreen(
            initialDepositNumber: args?.initialDepositNumber,
            onAssistantPressed: args?.onAssistantPressed,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.chequeBook,
        builder: (context, state) {
          final args = state.extra is ChequeBookRouteArguments
              ? state.extra as ChequeBookRouteArguments
              : null;
          return ChequeBookScreen(
            initialDepositNumber: args?.initialDepositNumber,
            onAssistantPressed: args?.onAssistantPressed,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.chequeClearance,
        builder: (context, state) {
          final args = state.extra is ChequeClearanceRouteArguments
              ? state.extra as ChequeClearanceRouteArguments
              : null;
          return ChequeClearanceScreen(
            onAssistantPressed: args?.onAssistantPressed,
          );
        },
      ),

      // Auth
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => AuthScreen(
          onAuthenticated: () async {
            final destination = validatedReturnLocation(
              state.uri.queryParameters['from'],
            );
            final extra = session.takePendingExtra();
            await session.signIn();
            if (context.mounted) context.go(destination, extra: extra);
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
          return CardListScreen(
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
        path: AppRoutes.proxyDeposit,
        builder: (context, state) {
          final args = state.extra is ProxyDepositRouteArguments
              ? state.extra as ProxyDepositRouteArguments
              : null;
          return ProxyDepositScreen(
            initialDepositNumber: args?.initialDepositNumber,
            onAssistantPressed: args?.onAssistantPressed,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.blockDeposit,
        builder: (context, state) {
          final args = state.extra is DepositRestrictionRouteArguments
              ? state.extra as DepositRestrictionRouteArguments
              : null;
          return DepositRestrictionScreen(
            operation: DepositRestrictionOperation.block,
            initialDepositNumber: args?.initialDepositNumber,
            onAssistantPressed: args?.onAssistantPressed,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.unblockDeposit,
        builder: (context, state) {
          final args = state.extra is DepositRestrictionRouteArguments
              ? state.extra as DepositRestrictionRouteArguments
              : null;
          return DepositRestrictionScreen(
            operation: DepositRestrictionOperation.unblock,
            initialDepositNumber: args?.initialDepositNumber,
            onAssistantPressed: args?.onAssistantPressed,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.closeSurplusDeposits,
        builder: (context, state) {
          final args = state.extra is CloseSurplusDepositsRouteArguments
              ? state.extra as CloseSurplusDepositsRouteArguments
              : null;
          return CloseSurplusDepositsScreen(
            initialDepositNumber: args?.initialDepositNumber,
            onAssistantPressed: args?.onAssistantPressed,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.agentSettings,
        builder: (context, state) {
          final args = state.extra is AgentSettingsRouteArguments
              ? state.extra as AgentSettingsRouteArguments
              : null;
          return AgentSettingsScreen(
            initialDepositNumber: args?.initialDepositNumber,
            onAssistantPressed: args?.onAssistantPressed,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.introduceAgent,
        builder: (context, state) => IntroduceAgentScreen(
          initialDepositNumber: state.extra is AgentRouteArguments
              ? (state.extra as AgentRouteArguments).initialDepositNumber
              : null,
        ),
      ),
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

class ProxyDepositRouteArguments {
  const ProxyDepositRouteArguments({
    this.initialDepositNumber,
    this.onAssistantPressed,
  });
  final String? initialDepositNumber;
  final VoidCallback? onAssistantPressed;
}

class DepositRestrictionRouteArguments {
  const DepositRestrictionRouteArguments({
    this.initialDepositNumber,
    this.onAssistantPressed,
  });
  final String? initialDepositNumber;
  final VoidCallback? onAssistantPressed;
}

class CloseSurplusDepositsRouteArguments {
  const CloseSurplusDepositsRouteArguments({
    this.initialDepositNumber,
    this.onAssistantPressed,
  });
  final String? initialDepositNumber;
  final VoidCallback? onAssistantPressed;
}

class AgentSettingsRouteArguments {
  const AgentSettingsRouteArguments({
    this.initialDepositNumber,
    this.onAssistantPressed,
  });
  final String? initialDepositNumber;
  final VoidCallback? onAssistantPressed;
}

class PasswordRouteArguments {
  const PasswordRouteArguments({
    this.initialCardNumber,
    this.selectOperation = false,
  });
  final String? initialCardNumber;
  final bool selectOperation;
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

class AgentRouteArguments {
  const AgentRouteArguments({this.initialDepositNumber});
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

class ChequeClearanceRouteArguments {
  const ChequeClearanceRouteArguments({this.onAssistantPressed});
  final VoidCallback? onAssistantPressed;
}

class ChequeBookRouteArguments {
  const ChequeBookRouteArguments({
    this.initialDepositNumber,
    this.onAssistantPressed,
  });
  final String? initialDepositNumber;
  final VoidCallback? onAssistantPressed;
}

class ChequeCancellationRouteArguments {
  const ChequeCancellationRouteArguments({
    this.initialDepositNumber,
    this.onAssistantPressed,
  });
  final String? initialDepositNumber;
  final VoidCallback? onAssistantPressed;
}
