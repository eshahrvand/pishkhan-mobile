import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';

import '../widgets/deposit_list_content.dart';
import '../widgets/deposit_sheet.dart';
import '../widgets/deposit_filter_options.dart';

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
  Future<void> _handleEffect(
    BuildContext context,
    DepositListState state,
  ) async {
    if (state.message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.message!)));
      return;
    }

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
        final value = await showDepositSheet<DepositKind>(
          context,
          DepositFilterOptions(
            title: S.current.depositListAccountType,
            labels: [
              for (final kind in DepositKind.values) depositKindLabel(kind),
            ],
            onSelected: (sheetContext, i) =>
                Navigator.of(sheetContext).pop(DepositKind.values[i]),
          ),
        );
        if (context.mounted) {
          context.read<DepositListCubit>().applyKindFilterSelection(value);
        }
      case DepositStatusFilterRequested():
        context.read<DepositListCubit>().consumeDepositListInteraction();
        final value = await showDepositSheet<DepositStatus>(
          context,
          DepositFilterOptions(
            title: S.current.depositListStatus,
            labels: [
              for (final status in DepositStatus.values)
                depositStatusLabel(status),
            ],
            onSelected: (sheetContext, i) =>
                Navigator.of(sheetContext).pop(DepositStatus.values[i]),
          ),
        );
        if (context.mounted) {
          context.read<DepositListCubit>().applyStatusFilterSelection(value);
        }
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DepositListCubit()..fetchDeposits(),
      child: BlocListener<DepositListCubit, DepositListState>(
        listenWhen: (previous, current) =>
            (previous.effect != current.effect && current.effect != null) ||
            ((previous.depositsStatus != current.depositsStatus &&
                current.depositsStatus == RequestStatus.failure)),
        listener: _handleEffect,
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
                          onTrailingPressed:
                              (state.depositsStatus != RequestStatus.loading)
                              ? () => NavigationActions.back(context)
                              : null,
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
                                  onPressed:
                                      onAssistantPressed ??
                                      () =>
                                          NavigationActions.returnHome(context),
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
