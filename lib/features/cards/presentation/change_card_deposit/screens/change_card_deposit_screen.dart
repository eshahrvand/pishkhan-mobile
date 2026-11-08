import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/shared/widgets/flow_exit_dialog.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../../../domain/entities/card_service_data.dart';
import '../cubit/change_card_deposit_cubit.dart';
import '../widgets/change_card_deposit_form.dart';
import '../../shared/card_service_widgets.dart';

class ChangeCardDepositScreen extends StatefulWidget {
  const ChangeCardDepositScreen({
    super.key,
    this.initialCardNumber,
    this.onTermsRequested,
    this.onCompleted,
  });

  final String? initialCardNumber;
  final VoidCallback? onTermsRequested;
  final ValueChanged<CardServiceReceipt>? onCompleted;

  @override
  State<ChangeCardDepositScreen> createState() =>
      _ChangeCardDepositScreenState();
}

class _ChangeCardDepositScreenState extends State<ChangeCardDepositScreen> {
  void _showRequestFailure(BuildContext context, ChangeCardDepositState state) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(state.message!)));
  }

  Future<void> _handleNavigation(
    BuildContext context,
    ChangeCardDepositState state,
  ) async {
    switch (state.navigation) {
      case FlowNavigation.confirmExit:
        context
            .read<ChangeCardDepositCubit>()
            .consumeChangeCardDepositInteraction();
        final confirmed = await showFlowExitDialog(context);
        if (context.mounted) {
          context.read<ChangeCardDepositCubit>().applyExitConfirmation(
            confirmed,
          );
        }
      case FlowNavigation.back:
        // Wait for PopScope to rebuild with the authorized exit intent.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) NavigationActions.back(context);
        });
      case FlowNavigation.home:
        NavigationActions.returnHome(context);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChangeCardDepositCubit>(
      create: (_) =>
          ChangeCardDepositCubit(initialCardNumber: widget.initialCardNumber)
            ..fetchCatalog(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<ChangeCardDepositCubit, ChangeCardDepositState>(
            listenWhen: (previous, current) =>
                previous.catalogStatus != current.catalogStatus &&
                current.catalogStatus == RequestStatus.failure,
            listener: _showRequestFailure,
          ),
          BlocListener<ChangeCardDepositCubit, ChangeCardDepositState>(
            listenWhen: (previous, current) =>
                previous.submissionStatus != current.submissionStatus &&
                current.submissionStatus == RequestStatus.failure,
            listener: _showRequestFailure,
          ),
          BlocListener<ChangeCardDepositCubit, ChangeCardDepositState>(
            listenWhen: (previous, current) =>
                previous.navigation != current.navigation &&
                current.navigation != null,
            listener: _handleNavigation,
          ),
          BlocListener<ChangeCardDepositCubit, ChangeCardDepositState>(
            listenWhen: (previous, current) =>
                previous.submissionStatus != current.submissionStatus &&
                current.submissionStatus == RequestStatus.success,
            listener: (context, state) {
              widget.onCompleted?.call(state.receipt!);
            },
          ),
        ],
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocBuilder<ChangeCardDepositCubit, ChangeCardDepositState>(
            builder: (context, state) {
              return PopScope(
                canPop:
                    (state.catalogStatus != RequestStatus.loading &&
                        state.submissionStatus != RequestStatus.loading) &&
                    (state.navigation == FlowNavigation.back),
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop &&
                      state.catalogStatus != RequestStatus.loading &&
                      state.submissionStatus != RequestStatus.loading) {
                    context.read<ChangeCardDepositCubit>().requestBack();
                  }
                },
                child: Scaffold(
                  backgroundColor: context.colors.surfaceSubtle,
                  body: SafeArea(
                    child: Column(
                      children: [
                        AppTopBar(
                          title: S.current.changeCardDepositTitle,
                          showLeadingActions: false,
                          trailingIcon: cardServiceIcon(
                            '${AppConstants.baseImage}card_features_back.svg',
                            size: 24,
                          ),
                          trailingTooltip: S.current.backLabel,
                          onTrailingPressed: context
                              .read<ChangeCardDepositCubit>()
                              .requestBack,
                          isTrailingActive:
                              (state.catalogStatus != RequestStatus.loading &&
                              state.submissionStatus != RequestStatus.loading),
                        ),
                        Expanded(
                          child:
                              (state.catalogStatus == RequestStatus.success &&
                                  !state.isCatalogEmpty &&
                                  state.receipt == null)
                              ? ChangeCardDepositForm(state: state)
                              : CardServiceStatus(
                                  status: state.catalogStatus,
                                  empty: state.isCatalogEmpty,
                                  receipt: state.receipt,
                                  onRetry: context
                                      .read<ChangeCardDepositCubit>()
                                      .fetchCatalog,
                                ),
                        ),
                        if ((state.catalogStatus == RequestStatus.success &&
                            !state.isCatalogEmpty &&
                            state.receipt == null))
                          CardServiceFooter(
                            label: S.current.cardServiceSubmit,
                            loading:
                                state.submissionStatus == RequestStatus.loading,
                            onSubmit: context
                                .read<ChangeCardDepositCubit>()
                                .submitDepositChange,
                            isActive: state.canSubmit,
                            termsAccepted: state.termsAccepted,
                            onTermsChanged: state.isEditable
                                ? context
                                      .read<ChangeCardDepositCubit>()
                                      .updateTermsAcceptance
                                : null,
                            onTermsRequested: widget.onTermsRequested,
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
