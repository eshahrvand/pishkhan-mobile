import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/router/app_routes.dart';

import 'presentation/deposit_list/screens/deposit_list_screen.dart';
import 'presentation/average_balance/screens/average_balance_screen.dart';
import 'presentation/financial_certificate/screens/financial_certificate_screen.dart';

class CertificateRouteArguments {
  const CertificateRouteArguments({this.initialDepositNumber});
  final String? initialDepositNumber;
}

class DepositListRouteArguments {
  const DepositListRouteArguments({this.onAssistantPressed});
  final VoidCallback? onAssistantPressed;
}

List<RouteBase> buildDepositsRoutes() => [
  GoRoute(
    path: DepositsRoutes.financialCertificate,
    builder: (context, state) => FinancialCertificateScreen(
      initialDepositNumber: state.extra is CertificateRouteArguments
          ? (state.extra as CertificateRouteArguments).initialDepositNumber
          : null,
    ),
  ),
  GoRoute(
    path: DepositsRoutes.averageBalance,
    builder: (context, state) => AverageBalanceScreen(
      initialDepositNumber: state.extra is CertificateRouteArguments
          ? (state.extra as CertificateRouteArguments).initialDepositNumber
          : null,
    ),
  ),
  GoRoute(
    path: DepositsRoutes.list,
    builder: (context, state) => DepositListScreen(
      onAssistantPressed: state.extra is DepositListRouteArguments
          ? (state.extra as DepositListRouteArguments).onAssistantPressed
          : null,
    ),
  ),
];
