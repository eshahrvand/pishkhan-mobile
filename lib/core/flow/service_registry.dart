import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';
import 'package:pishkhan_mobile/features/address/address.dart';
import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/router/app_router.dart';
import 'package:pishkhan_mobile/features/cards/domain/entities/listed_card.dart';

abstract final class ServiceRegistry {
  static Future<DeliveryAddress?> openAddressEditor(
    BuildContext context, {
    DeliveryAddress? initialAddress,
    bool includeContact = false,
    bool retainHomeAddress = false,
  }) {
    return showAddressEditorSheet(
      context,
      initialAddress: initialAddress,
      includeContact: includeContact,
      retainHomeAddress: retainHomeAddress,
    );
  }

  static bool openCardService(
    BuildContext context,
    String id, {
    VoidCallback? onAssistantPressed,
    String? initialDepositNumber,
    String? initialCardNumber,
  }) {
    if (id == 'identity-phone' ||
        id == 'identity-addresses' ||
        id == 'identity-occupation') {
      context.push<void>(
        switch (id) {
          'identity-phone' => AppRoutes.changePhone,
          'identity-addresses' => AppRoutes.addresses,
          _ => AppRoutes.occupations,
        },
        extra: PersonalInformationRouteArguments(
          onAssistantPressed: onAssistantPressed,
        ),
      );
      return true;
    }
    if (id == 'requests-list') {
      context.push<void>(
        AppRoutes.requestReports,
        extra: RequestReportsRouteArguments(
          onAssistantPressed: onAssistantPressed,
        ),
      );
      return true;
    }
    if (id == 'transfer-local') {
      context.push<void>(
        AppRoutes.onSiteTransfer,
        extra: OnSiteTransferRouteArguments(
          initialDepositNumber: initialDepositNumber,
          onAssistantPressed: onAssistantPressed,
        ),
      );
      return true;
    }
    if (id == 'cheque-cancel') {
      context.push<void>(
        AppRoutes.chequeCancellation,
        extra: ChequeCancellationRouteArguments(
          initialDepositNumber: initialDepositNumber,
          onAssistantPressed: onAssistantPressed,
        ),
      );
      return true;
    }
    if (id == 'cheque-issue') {
      context.push<void>(
        AppRoutes.chequeBook,
        extra: ChequeBookRouteArguments(
          initialDepositNumber: initialDepositNumber,
          onAssistantPressed: onAssistantPressed,
        ),
      );
      return true;
    }
    if (id == 'cheque-clear') {
      context.push<void>(
        AppRoutes.chequeClearance,
        extra: ChequeClearanceRouteArguments(
          onAssistantPressed: onAssistantPressed,
        ),
      );
      return true;
    }
    if (id == 'deposit-list') {
      context.push<void>(
        AppRoutes.depositList,
        extra: DepositListRouteArguments(
          onAssistantPressed: onAssistantPressed,
        ),
      );
      return true;
    }
    if (id == 'deposit-proxy') {
      context.push<void>(
        AppRoutes.proxyDeposit,
        extra: ProxyDepositRouteArguments(
          initialDepositNumber: initialDepositNumber,
          onAssistantPressed: onAssistantPressed,
        ),
      );
      return true;
    }
    if (id == 'deposit-block') {
      context.push<void>(
        AppRoutes.blockDeposit,
        extra: DepositRestrictionRouteArguments(
          initialDepositNumber: initialDepositNumber,
          onAssistantPressed: onAssistantPressed,
        ),
      );
      return true;
    }
    if (id == 'deposit-unblock') {
      context.push<void>(
        AppRoutes.unblockDeposit,
        extra: DepositRestrictionRouteArguments(
          initialDepositNumber: initialDepositNumber,
          onAssistantPressed: onAssistantPressed,
        ),
      );
      return true;
    }
    if (id == 'deposit-close-extras') {
      context.push<void>(
        AppRoutes.closeSurplusDeposits,
        extra: CloseSurplusDepositsRouteArguments(
          initialDepositNumber: initialDepositNumber,
          onAssistantPressed: onAssistantPressed,
        ),
      );
      return true;
    }
    if (id == 'deposit-representation-settings') {
      context.push<void>(
        AppRoutes.agentSettings,
        extra: AgentSettingsRouteArguments(
          initialDepositNumber: initialDepositNumber,
          onAssistantPressed: onAssistantPressed,
        ),
      );
      return true;
    }
    if (id == 'deposit-representative') {
      context.push<void>(
        AppRoutes.introduceAgent,
        extra: AgentRouteArguments(initialDepositNumber: initialDepositNumber),
      );
      return true;
    }
    if (id == 'deposit-certificate') {
      context.push<void>(
        AppRoutes.financialCertificate,
        extra: CertificateRouteArguments(
          initialDepositNumber: initialDepositNumber,
        ),
      );
      return true;
    }
    if (id == 'deposit-statement') {
      context.push<void>(
        AppRoutes.averageBalance,
        extra: CertificateRouteArguments(
          initialDepositNumber: initialDepositNumber,
        ),
      );
      return true;
    }
    if (id == 'deposit-list') {
      context.push<void>(
        AppRoutes.depositList,
        extra: DepositListRouteArguments(
          onAssistantPressed: () {
            context.go(AppRoutes.home);
            onAssistantPressed?.call();
          },
        ),
      );
      return true;
    }
    if (const {
      'card-password',
      'card-pin-second-set',
      'card-pin-second-forgot',
      'card-pin-second-change',
    }.contains(id)) {
      context.push<void>(
        AppRoutes.cardPasswords,
        extra: PasswordRouteArguments(
          initialCardNumber: initialCardNumber,
          selectOperation:
              id == 'card-pin-second-forgot' || id == 'card-pin-second-change',
        ),
      );
      return true;
    }
    final args = CardRouteArguments(
      initialDepositNumber: initialDepositNumber,
      initialCardNumber: initialCardNumber,
      onAssistantPressed: onAssistantPressed,
    );
    if (id == 'card-deposit') {
      context.push<void>(AppRoutes.changeCardDeposit, extra: args);
      return true;
    }
    if (id == 'card-expired-gift') {
      context.push<void>(AppRoutes.expiredGiftBalance, extra: args);
      return true;
    }
    if (id == 'card-virtual' || id == 'card-virtual-request') {
      context.push<void>(AppRoutes.virtualCardRequest, extra: args);
      return true;
    }
    if (id == 'card-issue' || id == 'card-reissue') {
      context.push<void>(AppRoutes.cardIssuance, extra: args);
      return true;
    }
    final category = switch (id) {
      'card-list' => CardCategory.resalat,
      'card-virtual-list' => CardCategory.virtual,
      _ => null,
    };
    if (category == null) return false;
    context.push<void>(AppRoutes.cardListLocation(category.name), extra: args);
    return true;
  }

  static void returnHome(BuildContext context) => context.go(AppRoutes.home);
}
