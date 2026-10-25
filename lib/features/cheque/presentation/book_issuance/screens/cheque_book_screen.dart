import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/flow/service_registry.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/platform/external_links.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
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
    if (state.message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.message!)));
      return;
    }

    switch (state.effect) {
      case ChequeBookEffect.confirmExit:
        context.read<ChequeBookCubit>().consumeChequeBookInteraction();
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
        context.read<ChequeBookCubit>().consumeChequeBookInteraction();
        NavigationActions.returnHome(context);
        onAssistantPressed?.call();
      case ChequeBookEffect.deleteAddress:
        context.read<ChequeBookCubit>().consumeChequeBookInteraction();
        await showChequeBookDeleteSheet(context, state.pendingAddress!);
      case ChequeBookEffect.addAddress:
        context.read<ChequeBookCubit>().consumeChequeBookInteraction();
        final address = await ServiceRegistry.openAddressEditor(context);
        if (context.mounted) {
          context.read<ChequeBookCubit>().applyAddressResult(address);
        }
      case ChequeBookEffect.registry:
        context.read<ChequeBookCubit>().consumeChequeBookInteraction();
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
        context.read<ChequeBookCubit>().consumeChequeBookInteraction();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.chequeContentUnavailable)),
        );
      case ChequeBookEffect.receipt:
        context.read<ChequeBookCubit>().consumeChequeBookInteraction();
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
            (previous.effect != current.effect && current.effect != null) ||
            ((previous.catalogStatus != current.catalogStatus &&
                    current.catalogStatus == RequestStatus.failure) ||
                (previous.residencyStatus != current.residencyStatus &&
                    current.residencyStatus == RequestStatus.failure) ||
                (previous.addressDeletionStatus !=
                        current.addressDeletionStatus &&
                    current.addressDeletionStatus == RequestStatus.failure) ||
                (previous.addressSaveStatus != current.addressSaveStatus &&
                    current.addressSaveStatus == RequestStatus.failure) ||
                (previous.quoteStatus != current.quoteStatus &&
                    current.quoteStatus == RequestStatus.failure) ||
                (previous.submissionStatus != current.submissionStatus &&
                    current.submissionStatus == RequestStatus.failure)),
        listener: _handleEffect,

        builder: (context, state) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: PopScope(
              canPop:
                  (state.catalogStatus != RequestStatus.loading &&
                      state.residencyStatus != RequestStatus.loading &&
                      state.addressDeletionStatus != RequestStatus.loading &&
                      state.addressSaveStatus != RequestStatus.loading &&
                      state.quoteStatus != RequestStatus.loading &&
                      state.submissionStatus != RequestStatus.loading) &&
                  (state.effect == ChequeBookEffect.back),
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop &&
                    state.catalogStatus != RequestStatus.loading &&
                    state.residencyStatus != RequestStatus.loading &&
                    state.addressDeletionStatus != RequestStatus.loading &&
                    state.addressSaveStatus != RequestStatus.loading &&
                    state.quoteStatus != RequestStatus.loading &&
                    state.submissionStatus != RequestStatus.loading) {
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
                                image:
                                    '${AppConstants.baseImage}deposit_list_back.svg',
                                width: 24,
                                height: 24,
                              ),
                              trailingTooltip: S.current.backLabel,
                              onTrailingPressed:
                                  (state.catalogStatus !=
                                          RequestStatus.loading &&
                                      state.residencyStatus !=
                                          RequestStatus.loading &&
                                      state.addressDeletionStatus !=
                                          RequestStatus.loading &&
                                      state.addressSaveStatus !=
                                          RequestStatus.loading &&
                                      state.quoteStatus !=
                                          RequestStatus.loading &&
                                      state.submissionStatus !=
                                          RequestStatus.loading)
                                  ? context.read<ChequeBookCubit>().requestBack
                                  : null,
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
