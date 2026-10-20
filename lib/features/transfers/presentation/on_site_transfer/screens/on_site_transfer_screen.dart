import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/flow/service_registry.dart';
import 'package:pishkhan_mobile/core/platform/document_picker.dart';
import 'package:pishkhan_mobile/core/platform/selected_document.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
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
    switch (state.effect) {
      case OnSiteTransferEffect.addressEditor:
        final address = await ServiceRegistry.openAddressEditor(context);
        if (context.mounted) {
          context.read<OnSiteTransferCubit>().applyAddressResult(address);
        }
      case OnSiteTransferEffect.deleteAddress:
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
        await showTransferDestinationSheet(context);
        if (context.mounted) {
          context.read<OnSiteTransferCubit>().cancelDestinationEditor();
        }
      case OnSiteTransferEffect.closeDestination:
        Navigator.of(context).pop();
      case OnSiteTransferEffect.uploadSheet:
        final confirmed = await showTransferUploadSheet(context);
        if (context.mounted) {
          context.read<OnSiteTransferCubit>().applyUploadSheetResult(confirmed);
        }
      case OnSiteTransferEffect.pickFile:
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
        FocusManager.instance.primaryFocus?.unfocus();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scroll.hasClients) _scroll.jumpTo(0);
        });
      case OnSiteTransferEffect.confirmExit:
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
        NavigationActions.returnHome(context);
        widget.onAssistantPressed?.call();
      case OnSiteTransferEffect.unavailable:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.cardFeatureUnavailable)),
        );
      case OnSiteTransferEffect.receipt:
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
            previous.effectId != current.effectId,
        listener: _handleEffect,
        child: BlocBuilder<OnSiteTransferCubit, OnSiteTransferState>(
          buildWhen: (previous, current) => previous.effect != current.effect,
          builder: (context, state) {
            return PopScope(
              canPop: state.effect == OnSiteTransferEffect.back,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) context.read<OnSiteTransferCubit>().requestBack();
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
                              image: AppAssets.depositFeatureBack,
                            ),
                            trailingTooltip: S.current.backLabel,
                            onTrailingPressed: () {
                              context.read<OnSiteTransferCubit>().requestBack();
                            },
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
