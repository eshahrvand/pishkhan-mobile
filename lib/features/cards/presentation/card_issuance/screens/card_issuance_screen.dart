import '../widgets/issuance_footer.dart';
import '../widgets/issuance_content.dart';

import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_delete_address_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../../../data/repositories/mock_card_issuance_repository.dart';
import '../../../domain/entities/issuance_data.dart';
import '../../../domain/repositories/card_issuance_repository.dart';
import '../cubit/card_issuance_cubit.dart';
import '../widgets/issuance_sections.dart';

class CardIssuanceScreen extends StatefulWidget {
  const CardIssuanceScreen({
    super.key,
    this.repository,
    this.initialDepositNumber,
    this.onAssistantPressed,
    this.onTermsRequested,
    this.onCompleted,
  });
  final CardIssuanceRepository? repository;
  final String? initialDepositNumber;
  final VoidCallback? onAssistantPressed, onTermsRequested;
  final ValueChanged<IssuanceReceipt>? onCompleted;
  @override
  State<CardIssuanceScreen> createState() => _CardIssuanceScreenState();
}

class _CardIssuanceScreenState extends State<CardIssuanceScreen> {
  // This State owns the Cubit; input changes restart the flow without widget keys.
  late CardIssuanceCubit _cubit;
  CardIssuanceCubit _createCubit() => CardIssuanceCubit(
    repository: widget.repository ?? MockCardIssuanceRepository(),
    initialDepositNumber: widget.initialDepositNumber,
  )..load();

  @override
  void didUpdateWidget(covariant CardIssuanceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.initialDepositNumber != widget.initialDepositNumber) {
      _cubit.close();
      _cubit = _createCubit();
    }
  }

  @override
  void initState() {
    super.initState();
    _cubit = _createCubit();
  }

  final scroll = ScrollController();
  @override
  void dispose() {
    _cubit.close();
    scroll.dispose();
    super.dispose();
  }

  void _back(BuildContext context) {
    if (context.read<CardIssuanceCubit>().state.submissionStatus ==
        RequestStatus.loading) {
      return;
    }
    if (!context.read<CardIssuanceCubit>().back()) {
      NavigationActions.back(context);
    }
  }

  void _terms() {
    if (widget.onTermsRequested != null) {
      widget.onTermsRequested!();
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(S.current.issuanceTermsUnavailable)));
  }

  Future<void> _deleteAddress(
    BuildContext context,
    IssuanceAddress address,
  ) async {
    final remove = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surfaceSubtle,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          child: AppDeleteAddressSheet(
            address: address.detail,
            postalCode: address.postalCode,
            onConfirm: () => Navigator.of(sheetContext).pop(true),
            onCancel: () => Navigator.of(sheetContext).pop(false),
          ),
        ),
      ),
    );
    if (context.mounted && remove == true) {
      context.read<CardIssuanceCubit>().removeAddress(address.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CardIssuanceCubit>.value(
      value: _cubit,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<CardIssuanceCubit, CardIssuanceState>(
          listenWhen: (old, next) =>
              old.step != next.step ||
              old.status != next.status ||
              old.submissionStatus != next.submissionStatus,
          listener: (context, state) {
            if (scroll.hasClients &&
                state.submissionStatus != RequestStatus.loading) {
              scroll.jumpTo(0);
            }
            if (state.submissionStatus == RequestStatus.success &&
                state.receipt != null) {
              widget.onCompleted?.call(state.receipt!);
            }
          },
          builder: (context, state) {
            final stepNumber = state.step.index + 1;
            final title = switch (state.step) {
              IssuanceStep.selection => S.current.issuanceSelectionTitle,
              IssuanceStep.delivery => S.current.issuanceDeliveryTitle,
              IssuanceStep.confirmation => S.current.issuanceConfirmTitle,
            };
            final next = switch (state.step) {
              IssuanceStep.selection =>
                state.draft.noPhysicalCard
                    ? S.current.issuanceNextConfirm
                    : S.current.issuanceNextDelivery,
              IssuanceStep.delivery => S.current.issuanceNextConfirm,
              IssuanceStep.confirmation => S.current.issuanceEnd,
            };
            return PopScope<void>(
              canPop:
                  state.submissionStatus != RequestStatus.loading &&
                  (state.step == IssuanceStep.selection ||
                      state.submissionStatus == RequestStatus.success),
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) context.read<CardIssuanceCubit>().back();
              },
              child: Scaffold(
                backgroundColor: context.colors.surfaceSubtle,
                body: SafeArea(
                  child: Column(
                    children: [
                      AppTopBar(
                        title: S.current.issuanceTitle,
                        showLeadingActions: false,
                        trailingIcon: issuanceIcon(
                          AppAssets.cardFeaturesBack,
                          size: 24,
                        ),
                        trailingTooltip: S.current.backLabel,
                        onTrailingPressed: () => _back(context),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    16,
                                    16,
                                    26,
                                  ),
                                  child: AppStepper(
                                    currentStep: stepNumber,
                                    totalSteps: 3,
                                    progress: switch (state.step) {
                                      IssuanceStep.selection => .3,
                                      IssuanceStep.delivery => .6,
                                      IssuanceStep.confirmation => 1,
                                    },
                                    title: title,
                                    supportingText: next,
                                    semanticLabel: S.current
                                        .issuanceStepSemantic(
                                          stepNumber,
                                          3,
                                          title,
                                        ),
                                  ),
                                ),
                                Expanded(
                                  child: IssuanceContent(
                                    scroll: scroll,
                                    onDeleteAddress: (address) =>
                                        _deleteAddress(context, address),
                                  ),
                                ),
                              ],
                            ),
                            if (state.status == RequestStatus.success &&
                                state.submissionStatus !=
                                    RequestStatus.success &&
                                state.catalog?.deposits.isNotEmpty == true &&
                                state.catalog?.types.isNotEmpty == true) ...[
                              Positioned(
                                left: 16,
                                bottom:
                                    (state.step == IssuanceStep.confirmation)
                                    ? 136
                                    : 76,
                                child: AppAssistantButton(
                                  onPressed:
                                      widget.onAssistantPressed ??
                                      () => _back(context),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: IssuanceFooter(onTermsRequested: _terms),
                              ),
                            ],
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
    );
  }
}
