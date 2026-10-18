import '../widgets/deposit_list_content.dart';
import '../widgets/deposit_sheet.dart';
import '../widgets/deposit_filter_options.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/core/flow/service_registry.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
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
    switch (state.effect) {
      case DepositActionsRequested(:final deposit):
        final action = await showDepositActionsSheet(context);
        if (context.mounted) {
          context.read<DepositListCubit>().applyActionSelection(
            deposit,
            action,
          );
        }
      case DepositDetailsRequested(:final deposit):
        await showDepositAccountDetailsSheet(context, deposit);
      case DepositServiceRequested(:final request, :final serviceId):
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
            previous.effectId != current.effectId,
        listener: _handleEffect,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: context.colors.surfaceSubtle,
            body: SafeArea(
              child: Column(
                children: [
                  AppTopBar(
                    title: S.current.dashboardDepositsList,
                    showLeadingActions: false,
                    trailingIcon: depositIcon(AppAssets.depositFeatureBack),
                    trailingTooltip: S.current.backLabel,
                    onTrailingPressed: () => NavigationActions.back(context),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const DepositFilters(),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 0,
                                child: OverflowBox(
                                  minHeight: 1,
                                  maxHeight: 1,
                                  child: AvpImage(
                                    image: AppAssets.cardFeaturesSeparator,
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
                                () => NavigationActions.returnHome(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
