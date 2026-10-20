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

import '../cubit/cheque_clearance_cubit.dart';
import '../widgets/cheque_clearance_form.dart';
import '../widgets/cheque_clearance_footer.dart';
import '../widgets/cheque_clearance_receipt_dialog.dart';
import '../../shared/postal/widgets/cheque_postal_sheet.dart';

class ChequeClearanceScreen extends StatelessWidget {
  const ChequeClearanceScreen({super.key, this.onAssistantPressed});
  final VoidCallback? onAssistantPressed;

  Future<void> _handleEffect(
    BuildContext context,
    ChequeClearanceState state,
  ) async {
    switch (state.effect) {
      case ChequeClearanceEffect.confirmExit:
        final confirmed = await showFlowExitDialog(context);
        if (context.mounted) {
          context.read<ChequeClearanceCubit>().applyExitConfirmation(confirmed);
        }
      case ChequeClearanceEffect.back:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) NavigationActions.back(context);
        });
      case ChequeClearanceEffect.home:
        NavigationActions.returnHome(context);
      case ChequeClearanceEffect.assistant:
        NavigationActions.returnHome(context);
        onAssistantPressed?.call();
      case ChequeClearanceEffect.postalOffices:
        await showChequePostalSheet(context);
      case ChequeClearanceEffect.contentUnavailable:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.chequeContentUnavailable)),
        );
      case null:
        break;
    }
  }

  Future<void> _handleSubmission(
    BuildContext context,
    ChequeClearanceState state,
  ) async {
    switch (state.submissionStatus) {
      case RequestStatus.loading:
        FocusManager.instance.primaryFocus?.unfocus();
      case RequestStatus.success:
        await showChequeClearanceReceiptDialog(context, state.receipt!);
        if (context.mounted) {
          context.read<ChequeClearanceCubit>().applyReceiptDismissal();
        }
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChequeClearanceCubit()..fetchCatalog(),
      child: BlocListener<ChequeClearanceCubit, ChequeClearanceState>(
        listenWhen: (previous, current) =>
            previous.submissionStatus != current.submissionStatus &&
            (current.submissionStatus == RequestStatus.success ||
                current.submissionStatus == RequestStatus.loading),
        listener: _handleSubmission,
        child: BlocConsumer<ChequeClearanceCubit, ChequeClearanceState>(
          listenWhen: (previous, current) =>
              previous.effectId != current.effectId,
          listener: _handleEffect,
          buildWhen: (previous, current) => previous.effect != current.effect,
          builder: (context, state) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: PopScope(
                canPop: state.effect == ChequeClearanceEffect.back,
                onPopInvokedWithResult: (didPop, result) {
                  if (!didPop) {
                    context.read<ChequeClearanceCubit>().requestBack();
                  }
                },
                child: Scaffold(
                  backgroundColor: context.colors.surfaceSubtle,
                  body: SafeArea(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Column(
                          children: [
                            AppTopBar(
                              title: S.current.chequeClearanceTitle,
                              showLeadingActions: false,
                              leadingAction: const SizedBox.shrink(),
                              trailingIcon: const AvpImage(
                                image: AppAssets.depositFeatureBack,
                                width: 24,
                                height: 24,
                              ),
                              trailingTooltip: S.current.backLabel,
                              onTrailingPressed: () {
                                context
                                    .read<ChequeClearanceCubit>()
                                    .requestBack();
                              },
                            ),
                            const Expanded(child: ChequeClearanceForm()),
                            const ChequeClearanceFooter(),
                          ],
                        ),
                        Positioned(
                          left: 16,
                          bottom: 76,
                          child: AppAssistantButton(
                            onPressed: () {
                              context
                                  .read<ChequeClearanceCubit>()
                                  .requestAssistant();
                            },
                          ),
                        ),
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
