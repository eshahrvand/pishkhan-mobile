import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/shared/widgets/flow_exit_dialog.dart';

import '../../../domain/entities/deposit_restriction.dart';
import '../../deposit_list/widgets/deposit_ui.dart';
import '../cubit/deposit_restriction_cubit.dart';
import '../widgets/deposit_restriction_footer.dart';
import '../widgets/deposit_restriction_form.dart';
import '../widgets/deposit_restriction_receipt_dialog.dart';

class DepositRestrictionScreen extends StatelessWidget {
  const DepositRestrictionScreen({
    super.key,
    required this.operation,
    this.initialDepositNumber,
    this.onAssistantPressed,
  });
  final DepositRestrictionOperation operation;
  final String? initialDepositNumber;
  final VoidCallback? onAssistantPressed;

  Future<void> _handleEffect(
    BuildContext context,
    DepositRestrictionState state,
  ) async {
    switch (state.effect) {
      case DepositRestrictionEffect.confirmExit:
        final confirmed = await showFlowExitDialog(context);
        if (context.mounted) {
          context.read<DepositRestrictionCubit>().applyExitConfirmation(
            confirmed,
          );
        }
      case DepositRestrictionEffect.back:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) NavigationActions.back(context);
        });
      case DepositRestrictionEffect.home:
        NavigationActions.returnHome(context);
      case DepositRestrictionEffect.assistant:
        NavigationActions.returnHome(context);
        onAssistantPressed?.call();
      case DepositRestrictionEffect.termsUnavailable:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.issuanceTermsUnavailable)),
        );
      case null:
        break;
    }
  }

  Future<void> _handleReceipt(
    BuildContext context,
    DepositRestrictionState state,
  ) async {
    await showDepositRestrictionReceiptDialog(context, state.receipt!);
    if (context.mounted) {
      context.read<DepositRestrictionCubit>().applyReceiptDismissal();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DepositRestrictionCubit(
        operation: operation,
        initialDepositNumber: initialDepositNumber,
      )..fetchCatalog(),
      child: BlocListener<DepositRestrictionCubit, DepositRestrictionState>(
        listenWhen: (previous, current) =>
            previous.submissionStatus != current.submissionStatus &&
            current.submissionStatus == RequestStatus.success,
        listener: _handleReceipt,
        child: BlocConsumer<DepositRestrictionCubit, DepositRestrictionState>(
          listenWhen: (previous, current) =>
              previous.effectId != current.effectId,
          listener: _handleEffect,
          buildWhen: (previous, current) => previous.effect != current.effect,
          builder: (context, state) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: PopScope(
                canPop: state.effect == DepositRestrictionEffect.back,
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop) {
                    context.read<DepositRestrictionCubit>().requestBack();
                  }
                },
                child: Scaffold(
                  backgroundColor: context.colors.surfaceSubtle,
                  body: SafeArea(
                    child: Column(
                      children: [
                        AppTopBar(
                          title: switch (operation) {
                            DepositRestrictionOperation.block =>
                              S.current.depositBlockTitle,
                            DepositRestrictionOperation.unblock =>
                              S.current.depositUnblockTitle,
                          },
                          showLeadingActions: false,
                          leadingAction: const SizedBox.shrink(),
                          trailingIcon: depositIcon(
                            AppAssets.depositFeatureBack,
                          ),
                          trailingTooltip: S.current.backLabel,
                          onTrailingPressed: context
                              .read<DepositRestrictionCubit>()
                              .requestBack,
                        ),
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              DepositRestrictionForm(operation: operation),
                              Positioned(
                                left: 16,
                                bottom: 16,
                                child: AppAssistantButton(
                                  onPressed: context
                                      .read<DepositRestrictionCubit>()
                                      .requestAssistant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const DepositRestrictionFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
