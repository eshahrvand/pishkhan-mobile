import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';

import '../widgets/deposit_list_content.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/core/flow/service_registry.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../../../domain/entities/listed_deposit.dart';
import '../cubit/deposit_list_cubit.dart';
import '../widgets/deposit_account_details_sheet.dart';
import '../widgets/deposit_actions_sheet.dart';
import '../widgets/deposit_filters.dart';
import '../widgets/deposit_ui.dart';

class DepositListScreen extends StatelessWidget {
  const DepositListScreen({
    super.key,
    this.onActionRequested,
    this.onAssistantPressed,
  });
  final ValueChanged<DepositListActionRequest>? onActionRequested;
  final VoidCallback? onAssistantPressed;
  void _showRequestFailure(BuildContext context, DepositListState state) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(state.message!)));
  }

  Future<void> _handleEffect(
    BuildContext context,
    DepositListState state,
  ) async {
    switch (state.effect) {
      case DepositActionsRequested(:final deposit):
        context.read<DepositListCubit>().consumeDepositListInteraction();
        final action = await showDepositActionsSheet(context);
        if (context.mounted) {
          context.read<DepositListCubit>().applyActionSelection(
            deposit,
            action,
          );
        }
      case DepositDetailsRequested(:final deposit):
        context.read<DepositListCubit>().consumeDepositListInteraction();
        await showDepositAccountDetailsSheet(context, deposit);
      case DepositServiceRequested(:final request, :final serviceId):
        context.read<DepositListCubit>().consumeDepositListInteraction();
        if (onActionRequested != null) {
          onActionRequested!(request);
        } else if (serviceId != null) {
          ServiceRegistry.openCardService(
            context,
            serviceId,
            initialDepositNumber: request.deposit.number,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.current.depositListServiceUnavailable)),
          );
        }
      case DepositKindFilterRequested():
        context.read<DepositListCubit>().consumeDepositListInteraction();
        final value = await showAppSelectSheet<DepositKind>(
          context,
          title: S.current.depositListAccountType,
          selected: state.kind,
          options: [
            for (final kind in DepositKind.values)
              AppSelectOption(value: kind, label: depositKindLabel(kind)),
          ],
        );
        if (context.mounted) {
          context.read<DepositListCubit>().applyKindFilterSelection(value);
        }
      case DepositStatusFilterRequested():
        context.read<DepositListCubit>().consumeDepositListInteraction();
        final value = await showAppSelectSheet<DepositStatus>(
          context,
          title: S.current.depositListStatus,
          selected: state.depositStatus,
          options: [
            for (final status in DepositStatus.values)
              AppSelectOption(value: status, label: depositStatusLabel(status)),
          ],
        );
        if (context.mounted) {
          context.read<DepositListCubit>().applyStatusFilterSelection(value);
        }
      case DepositListBackRequested():
        NavigationActions.back(context);
      case DepositListAssistantRequested():
        context.read<DepositListCubit>().consumeDepositListInteraction();
        if (onAssistantPressed != null) {
          onAssistantPressed!();
        } else {
          NavigationActions.returnHome(context);
        }
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DepositListCubit()..fetchDeposits(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<DepositListCubit, DepositListState>(
            listenWhen: (previous, current) =>
                previous.depositsStatus != current.depositsStatus &&
                current.depositsStatus == RequestStatus.failure,
            listener: _showRequestFailure,
          ),
          BlocListener<DepositListCubit, DepositListState>(
            listenWhen: (previous, current) =>
                previous.effect != current.effect && current.effect != null,
            listener: _handleEffect,
          ),
        ],
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocBuilder<DepositListCubit, DepositListState>(
            builder: (context, state) {
              return PopScope(
                canPop: state.depositsStatus != RequestStatus.loading,
                child: Scaffold(
                  backgroundColor: context.colors.surfaceSubtle,
                  body: SafeArea(
                    child: Column(
                      children: [
                        AppTopBar(
                          title: S.current.dashboardDepositsList,
                          showLeadingActions: false,
                          trailingIcon: depositIcon(
                            '${AppConstants.baseImage}deposit_list_back.svg',
                          ),
                          trailingTooltip: S.current.backLabel,
                          onTrailingPressed: () =>
                              context.read<DepositListCubit>().requestBack(),
                          isTrailingActive:
                              (state.depositsStatus != RequestStatus.loading),
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  12,
                                  16,
                                  80,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const DepositFilters(),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      height: 0,
                                      child: OverflowBox(
                                        minHeight: 1,
                                        maxHeight: 1,
                                        child: AvpImage(
                                          image:
                                              '${AppConstants.baseImage}card_features_separator.png',
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const DepositListContent(),
                                  ],
                                ),
                              ),
                              Positioned(
                                left: 16,
                                bottom: 16,
                                child: AppAssistantButton(
                                  onPressed: () => context
                                      .read<DepositListCubit>()
                                      .requestAssistant(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
