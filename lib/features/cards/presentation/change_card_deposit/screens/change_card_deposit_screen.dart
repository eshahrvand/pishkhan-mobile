import 'package:pishkhan_mobile/shared/widgets/flow_exit_dialog.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
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
  Future<void> _handleNavigation(
    BuildContext context,
    ChangeCardDepositState state,
  ) async {
    switch (state.navigation) {
      case FlowNavigation.confirmExit:
        final confirmed = await showFlowExitDialog(context);
        if (context.mounted) {
          context.read<ChangeCardDepositCubit>().exitConfirmationResult(
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
            ..load(),
      child: BlocListener<ChangeCardDepositCubit, ChangeCardDepositState>(
        listenWhen: (previous, current) =>
            previous.navigationId != current.navigationId,
        listener: _handleNavigation,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocConsumer<ChangeCardDepositCubit, ChangeCardDepositState>(
            listenWhen: (previous, current) =>
                previous.submissionStatus != current.submissionStatus,
            listener: (context, state) {
              if (state.receipt != null) {
                widget.onCompleted?.call(state.receipt!);
              }
            },
            builder: (context, state) {
              return PopScope(
                canPop: state.navigation == FlowNavigation.back,
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop) {
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
                            AppAssets.cardFeaturesBack,
                            size: 24,
                          ),
                          trailingTooltip: S.current.backLabel,
                          onTrailingPressed: context
                              .read<ChangeCardDepositCubit>()
                              .requestBack,
                        ),
                        Expanded(
                          child:
                              (state.status == RequestStatus.success &&
                                  !state.isEmpty &&
                                  state.receipt == null)
                              ? ChangeCardDepositForm(
                                  cubit: context.read<ChangeCardDepositCubit>(),
                                  state: state,
                                )
                              : CardServiceStatus(
                                  status: state.status,
                                  empty: state.isEmpty,
                                  receipt: state.receipt,
                                  onRetry: context
                                      .read<ChangeCardDepositCubit>()
                                      .load,
                                ),
                        ),
                        if ((state.status == RequestStatus.success &&
                            !state.isEmpty &&
                            state.receipt == null))
                          CardServiceFooter(
                            label: S.current.cardServiceSubmit,
                            loading:
                                state.submissionStatus == RequestStatus.loading,
                            onSubmit: state.canSubmit
                                ? context.read<ChangeCardDepositCubit>().submit
                                : null,
                            termsAccepted: state.termsAccepted,
                            onTermsChanged: state.editable
                                ? context
                                      .read<ChangeCardDepositCubit>()
                                      .acceptTerms
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
