import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/shared/widgets/flow_exit_dialog.dart';

import '../../shared/postal/widgets/cheque_postal_sheet.dart';
import '../cubit/cheque_cancellation_cubit.dart';
import '../widgets/cheque_cancellation_content.dart';
import '../widgets/cheque_cancellation_delete_sheet.dart';
import '../widgets/cheque_cancellation_footer.dart';
import '../widgets/cheque_cancellation_reason_sheet.dart';
import '../widgets/cheque_cancellation_receipt_dialog.dart';
import '../widgets/cheque_cancellation_review_sheet.dart';

class ChequeCancellationScreen extends StatelessWidget {
  const ChequeCancellationScreen({
    super.key,
    this.initialDepositNumber,
    this.onAssistantPressed,
  });
  final String? initialDepositNumber;
  final VoidCallback? onAssistantPressed;
  Future<void> _handleEffect(
    BuildContext context,
    ChequeCancellationState state,
  ) async {
    switch (state.effect) {
      case ChequeCancellationEffect.review:
        final continued = await showChequeCancellationReviewSheet(context);
        if (context.mounted) {
          context.read<ChequeCancellationCubit>().applyReviewDismissal(
            continued,
          );
        }
      case ChequeCancellationEffect.reason:
        await showChequeCancellationReasonSheet(context);
      case ChequeCancellationEffect.deleteCheque:
        await showChequeCancellationDeleteSheet(context, state.pendingCheque!);
      case ChequeCancellationEffect.postalOffices:
        await showChequePostalSheet(context);
      case ChequeCancellationEffect.contentUnavailable:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.chequeContentUnavailable)),
        );
      case ChequeCancellationEffect.receipt:
        await showChequeCancellationReceiptDialog(context, state.receipt!);
        if (context.mounted) {
          context.read<ChequeCancellationCubit>().applyReceiptDismissal();
        }
      case ChequeCancellationEffect.confirmExit:
        final confirmed = await showFlowExitDialog(context);
        if (context.mounted) {
          context.read<ChequeCancellationCubit>().applyExitConfirmation(
            confirmed,
          );
        }
      case ChequeCancellationEffect.back:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) NavigationActions.back(context);
        });
      case ChequeCancellationEffect.home:
        NavigationActions.returnHome(context);
      case ChequeCancellationEffect.assistant:
        NavigationActions.returnHome(context);
        onAssistantPressed?.call();
      case ChequeCancellationEffect.deleteReviewCheque:
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ChequeCancellationCubit(initialDepositNumber: initialDepositNumber)
            ..fetchCatalog(),
      child: BlocConsumer<ChequeCancellationCubit, ChequeCancellationState>(
        listenWhen: (previous, current) =>
            previous.effectId != current.effectId,
        listener: _handleEffect,
        buildWhen: (previous, current) =>
            previous.step != current.step || previous.effect != current.effect,
        builder: (context, state) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: PopScope(
              canPop: state.effect == ChequeCancellationEffect.back,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) {
                  context.read<ChequeCancellationCubit>().requestBack();
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
                            title: S.current.chequeCancelTitle,
                            showLeadingActions: false,
                            leadingAction:
                                state.step == ChequeCancellationStep.cheques
                                ? BlocBuilder<
                                    ChequeCancellationCubit,
                                    ChequeCancellationState
                                  >(
                                    buildWhen: (previous, current) =>
                                        previous.selectedEntries !=
                                            current.selectedEntries ||
                                        previous.isEditable !=
                                            current.isEditable,
                                    builder: (context, state) {
                                      return Semantics(
                                        button: true,
                                        label: S.current.chequeCancelReview,
                                        child: InkWell(
                                          onTap: state.isEditable
                                              ? context
                                                    .read<
                                                      ChequeCancellationCubit
                                                    >()
                                                    .requestSelectedCheques
                                              : null,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: AvpImage(
                                              image:
                                                  state.selectedEntries.isEmpty
                                                  ? AppAssets
                                                        .chequeCancelFileList
                                                  : AppAssets
                                                        .chequeCancelFileListSelected,
                                              width: 24,
                                              height: 24,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : const SizedBox.shrink(),
                            trailingIcon: const AvpImage(
                              image: AppAssets.depositFeatureBack,
                              width: 24,
                              height: 24,
                            ),
                            trailingTooltip: S.current.backLabel,
                            onTrailingPressed: context
                                .read<ChequeCancellationCubit>()
                                .requestBack,
                          ),
                          const Expanded(child: ChequeCancellationContent()),
                          const ChequeCancellationFooter(),
                        ],
                      ),
                      Positioned(
                        left: 16,
                        bottom: 76,
                        child: AppAssistantButton(
                          onPressed: context
                              .read<ChequeCancellationCubit>()
                              .requestAssistant,
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
    );
  }
}
