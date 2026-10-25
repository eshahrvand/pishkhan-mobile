import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/flow/service_registry.dart';
import 'package:pishkhan_mobile/core/platform/document_picker.dart';
import 'package:pishkhan_mobile/core/platform/selected_document.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_delete_address_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/shared/widgets/flow_exit_dialog.dart';

import '../cubit/on_site_transfer_cubit.dart';
import '../widgets/transfer_destination_sheet.dart';
import '../widgets/transfer_upload_sheet.dart';
import '../widgets/transfer_footer.dart';
import '../widgets/transfer_form.dart';
import '../widgets/transfer_receipt_dialog.dart';

class OnSiteTransferScreen extends StatefulWidget {
  const OnSiteTransferScreen({
    super.key,
    this.initialDepositNumber,
    this.onAssistantPressed,
  });
  final String? initialDepositNumber;
  final VoidCallback? onAssistantPressed;
  @override
  State<OnSiteTransferScreen> createState() => _OnSiteTransferScreenState();
}

class _OnSiteTransferScreenState extends State<OnSiteTransferScreen> {
  final _scroll = ScrollController();
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _handleEffect(
    BuildContext context,
    OnSiteTransferState state,
  ) async {
    if (state.message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.message!)));
      return;
    }

    switch (state.effect) {
      case OnSiteTransferEffect.addressEditor:
        context.read<OnSiteTransferCubit>().consumeOnSiteTransferInteraction();
        final address = await ServiceRegistry.openAddressEditor(context);
        if (context.mounted) {
          context.read<OnSiteTransferCubit>().applyAddressResult(address);
        }
      case OnSiteTransferEffect.deleteAddress:
        context.read<OnSiteTransferCubit>().consumeOnSiteTransferInteraction();
        await showAppServiceSheet<void>(
          context,
          AppDeleteAddressSheet(
            address: state.address!.detail,
            postalCode: state.address!.postalCode,
            title: S.current.issuanceDeleteAddress,
            prompt: S.current.certificateDeleteAddressPrompt,
            confirmLabel: S.current.issuanceDeleteAddress,
            cancelLabel: S.current.dashboardCancel,
            postalCodeLabel: S.current.issuancePostalCode,
            onConfirm: () {
              context.read<OnSiteTransferCubit>().removeAddress();
              Navigator.of(context).pop();
            },
            onCancel: () {
              Navigator.of(context).pop();
            },
          ),
        );
      case OnSiteTransferEffect.destinationEditor:
        context.read<OnSiteTransferCubit>().consumeOnSiteTransferInteraction();
        await showTransferDestinationSheet(context);
        if (context.mounted) {
          context.read<OnSiteTransferCubit>().cancelDestinationEditor();
        }
      case OnSiteTransferEffect.closeDestination:
        context.read<OnSiteTransferCubit>().consumeOnSiteTransferInteraction();
        Navigator.of(context).pop();
      case OnSiteTransferEffect.uploadSheet:
        context.read<OnSiteTransferCubit>().consumeOnSiteTransferInteraction();
        final confirmed = await showTransferUploadSheet(context);
        if (context.mounted) {
          context.read<OnSiteTransferCubit>().applyUploadSheetResult(confirmed);
        }
      case OnSiteTransferEffect.pickFile:
        context.read<OnSiteTransferCubit>().consumeOnSiteTransferInteraction();
        SelectedDocument? file;
        try {
          file = await DocumentPicker.pickSpreadsheet();
        } catch (_) {
          if (context.mounted) {
            context.read<OnSiteTransferCubit>().applyFilePickerFailure(
              state.filePickerRequestId,
            );
          }
          return;
        }
        if (context.mounted) {
          context.read<OnSiteTransferCubit>().applyFileSelection(
            file,
            requestId: state.filePickerRequestId,
          );
        }
      case OnSiteTransferEffect.reveal:
        context.read<OnSiteTransferCubit>().consumeOnSiteTransferInteraction();
        FocusManager.instance.primaryFocus?.unfocus();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scroll.hasClients) _scroll.jumpTo(0);
        });
      case OnSiteTransferEffect.confirmExit:
        context.read<OnSiteTransferCubit>().consumeOnSiteTransferInteraction();
        final confirmed = await showFlowExitDialog(context);
        if (context.mounted) {
          context.read<OnSiteTransferCubit>().applyExitConfirmation(confirmed);
        }
      case OnSiteTransferEffect.back:
        // PopScope first rebuilds with canPop=true before executing the approved exit.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) NavigationActions.back(context);
        });
      case OnSiteTransferEffect.home:
        NavigationActions.returnHome(context);
      case OnSiteTransferEffect.assistant:
        context.read<OnSiteTransferCubit>().consumeOnSiteTransferInteraction();
        NavigationActions.returnHome(context);
        widget.onAssistantPressed?.call();
      case OnSiteTransferEffect.unavailable:
        context.read<OnSiteTransferCubit>().consumeOnSiteTransferInteraction();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.cardFeatureUnavailable)),
        );
      case OnSiteTransferEffect.receipt:
        context.read<OnSiteTransferCubit>().consumeOnSiteTransferInteraction();
        await showTransferReceiptDialog(context, state.receipt!);
        if (context.mounted) {
          context.read<OnSiteTransferCubit>().applyReceiptDismissal();
        }
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          OnSiteTransferCubit(initialDepositNumber: widget.initialDepositNumber)
            ..fetchCatalog(),
      child: BlocListener<OnSiteTransferCubit, OnSiteTransferState>(
        listenWhen: (previous, current) =>
            (previous.effect != current.effect && current.effect != null) ||
            ((previous.catalogStatus != current.catalogStatus &&
                    current.catalogStatus == RequestStatus.failure) ||
                (previous.destinationStatus != current.destinationStatus &&
                    current.destinationStatus == RequestStatus.failure) ||
                (previous.uploadStatus != current.uploadStatus &&
                    current.uploadStatus == RequestStatus.failure) ||
                (previous.submissionStatus != current.submissionStatus &&
                    current.submissionStatus == RequestStatus.failure)),
        listener: _handleEffect,
        child: BlocBuilder<OnSiteTransferCubit, OnSiteTransferState>(
          builder: (context, state) {
            return PopScope(
              canPop:
                  (state.catalogStatus != RequestStatus.loading &&
                      state.destinationStatus != RequestStatus.loading &&
                      state.uploadStatus != RequestStatus.loading &&
                      state.submissionStatus != RequestStatus.loading) &&
                  (state.effect == OnSiteTransferEffect.back),
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop &&
                    state.catalogStatus != RequestStatus.loading &&
                    state.destinationStatus != RequestStatus.loading &&
                    state.uploadStatus != RequestStatus.loading &&
                    state.submissionStatus != RequestStatus.loading) {
                  context.read<OnSiteTransferCubit>().requestBack();
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
                            title: S.current.mobileBank,
                            showLeadingActions: false,
                            trailingIcon: AvpImage(
                              image:
                                  '${AppConstants.baseImage}deposit_list_back.svg',
                            ),
                            trailingTooltip: S.current.backLabel,
                            onTrailingPressed:
                                (state.catalogStatus != RequestStatus.loading &&
                                    state.destinationStatus !=
                                        RequestStatus.loading &&
                                    state.uploadStatus !=
                                        RequestStatus.loading &&
                                    state.submissionStatus !=
                                        RequestStatus.loading)
                                ? () {
                                    context
                                        .read<OnSiteTransferCubit>()
                                        .requestBack();
                                  }
                                : null,
                          ),
                          Expanded(child: TransferForm(controller: _scroll)),
                          const TransferFooter(),
                        ],
                      ),
                      Positioned(
                        left: 16,
                        bottom: 76,
                        child: AppAssistantButton(
                          onPressed: () {
                            context
                                .read<OnSiteTransferCubit>()
                                .requestAssistant();
                          },
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
    );
  }
}
