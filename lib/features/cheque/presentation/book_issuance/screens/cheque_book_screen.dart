import 'package:pishkhan_mobile/core/flow/service_registry.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/platform/external_links.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/shared/widgets/flow_exit_dialog.dart';

import '../cubit/cheque_book_cubit.dart';
import '../widgets/cheque_book_content.dart';
import '../widgets/cheque_book_delete_sheet.dart';
import '../widgets/cheque_book_footer.dart';
import '../widgets/cheque_book_receipt_dialog.dart';

class ChequeBookScreen extends StatelessWidget {
  const ChequeBookScreen({
    super.key,
    this.initialDepositNumber,
    this.onAssistantPressed,
  });
  final String? initialDepositNumber;
  final VoidCallback? onAssistantPressed;

  Future<void> _handleEffect(
    BuildContext context,
    ChequeBookState state,
  ) async {
    switch (state.effect) {
      case ChequeBookEffect.confirmExit:
        final confirmed = await showFlowExitDialog(context);
        if (context.mounted) {
          context.read<ChequeBookCubit>().applyExitConfirmation(confirmed);
        }
      case ChequeBookEffect.back:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) NavigationActions.back(context);
        });
      case ChequeBookEffect.home:
        NavigationActions.returnHome(context);
      case ChequeBookEffect.assistant:
        NavigationActions.returnHome(context);
        onAssistantPressed?.call();
      case ChequeBookEffect.deleteAddress:
        await showChequeBookDeleteSheet(context, state.pendingAddress!);
      case ChequeBookEffect.addAddress:
        final address = await ServiceRegistry.openAddressEditor(context);
        if (context.mounted) {
          context.read<ChequeBookCubit>().applyAddressResult(address);
        }
      case ChequeBookEffect.registry:
        try {
          await ExternalLinks.openRegistry();
        } on PlatformException {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.chequeBookLinkUnavailable)),
            );
          }
        } on MissingPluginException {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.chequeBookLinkUnavailable)),
            );
          }
        }
      case ChequeBookEffect.contentUnavailable:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.chequeContentUnavailable)),
        );
      case ChequeBookEffect.receipt:
        await showChequeBookReceiptDialog(context, state.receipt!);
        if (context.mounted) {
          context.read<ChequeBookCubit>().applyReceiptDismissal();
        }
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ChequeBookCubit(initialDepositNumber: initialDepositNumber)
            ..fetchCatalog(),
      child: BlocConsumer<ChequeBookCubit, ChequeBookState>(
        listenWhen: (previous, current) =>
            previous.effectId != current.effectId,
        listener: _handleEffect,
        buildWhen: (previous, current) =>
            previous.step != current.step || previous.effect != current.effect,
        builder: (context, state) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: PopScope(
              canPop: state.effect == ChequeBookEffect.back,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) {
                  context.read<ChequeBookCubit>().requestBack();
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
                          if (state.step != ChequeBookStep.checking)
                            AppTopBar(
                              title: S.current.chequeBookTitle,
                              showLeadingActions: false,
                              leadingAction: const SizedBox.shrink(),
                              trailingIcon: const AvpImage(
                                image: AppAssets.depositFeatureBack,
                                width: 24,
                                height: 24,
                              ),
                              trailingTooltip: S.current.backLabel,
                              onTrailingPressed: context
                                  .read<ChequeBookCubit>()
                                  .requestBack,
                            ),
                          const Expanded(child: ChequeBookContent()),
                          if (state.step != ChequeBookStep.checking)
                            const ChequeBookFooter(),
                        ],
                      ),
                      Positioned(
                        left: 16,
                        bottom: 76,
                        child: AppAssistantButton(
                          onPressed: context
                              .read<ChequeBookCubit>()
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
