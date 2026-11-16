import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/shared/widgets/app_decision_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/flow_exit_sheet.dart';

import '../../../domain/entities/card_restriction.dart';
import '../../shared/card_service_widgets.dart';
import '../cubit/card_restriction_cubit.dart';
import '../widgets/card_restriction_form.dart';

import 'package:pishkhan_mobile/shared/widgets/deposit_request_footer.dart';

import '../widgets/card_restriction_labels.dart';

class CardRestrictionScreen extends StatelessWidget {
  const CardRestrictionScreen({
    super.key,
    required this.operation,
    this.initialCardNumber,
  });
  final CardRestrictionOperation operation;
  final String? initialCardNumber;

  void _showFailure(BuildContext context, CardRestrictionState state) {
    avpSnackBar(
      context: context,
      type: AvpSnackBarType.error,
      message: state.message!,
    );
  }

  Future<void> _handleEffect(
    BuildContext context,
    CardRestrictionState state,
  ) async {
    switch (state.effect) {
      case CardRestrictionEffect.confirmBlock:
        context.read<CardRestrictionCubit>().consumeInteraction();
        final confirmed = await showAppServiceSheet<bool>(
          context,
          Theme(
            data: Theme.of(context).copyWith(
              textTheme: Theme.of(context).textTheme.copyWith(
                bodyMedium: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(height: 20 / 14),
              ),
            ),
            child: AppDecisionSheet(
              message: S.current.cardBlockConfirmation,
              confirmLabel: S.current.cardBlockConfirm,
              cancelLabel: S.current.dashboardCancel,
              onConfirm: () =>
                  Navigator.of(context, rootNavigator: true).pop(true),
            ),
          ),
        );
        if (context.mounted) {
          await context.read<CardRestrictionCubit>().applyBlockConfirmation(
            confirmed,
          );
        }
      case CardRestrictionEffect.confirmExit:
        context.read<CardRestrictionCubit>().consumeInteraction();
        final confirmed = await showFlowExitSheet(context);
        if (context.mounted) {
          context.read<CardRestrictionCubit>().applyExitConfirmation(confirmed);
        }
      case CardRestrictionEffect.back:
        // PopScope must rebuild with the authorized exit intent before popping.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) NavigationActions.back(context);
        });
      case CardRestrictionEffect.home:
        NavigationActions.returnHome(context);
      case CardRestrictionEffect.termsUnavailable:
        context.read<CardRestrictionCubit>().consumeInteraction();
        avpSnackBar(
          context: context,
          type: AvpSnackBarType.error,
          message: S.current.issuanceTermsUnavailable,
        );
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CardRestrictionCubit(
        operation: operation,
        initialCardNumber: initialCardNumber,
      )..fetchCatalog(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<CardRestrictionCubit, CardRestrictionState>(
            listenWhen: (previous, current) =>
                previous.catalogStatus != current.catalogStatus &&
                current.catalogStatus == RequestStatus.failure,
            listener: _showFailure,
          ),
          BlocListener<CardRestrictionCubit, CardRestrictionState>(
            listenWhen: (previous, current) =>
                previous.submissionStatus != current.submissionStatus &&
                current.submissionStatus == RequestStatus.failure,
            listener: _showFailure,
          ),
          BlocListener<CardRestrictionCubit, CardRestrictionState>(
            listenWhen: (previous, current) =>
                previous.effect != current.effect && current.effect != null,
            listener: _handleEffect,
          ),
        ],
        child: BlocBuilder<CardRestrictionCubit, CardRestrictionState>(
          builder: (context, state) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: PopScope(
                canPop:
                    state.catalogStatus != RequestStatus.loading &&
                    state.submissionStatus != RequestStatus.loading &&
                    state.effect == CardRestrictionEffect.back,
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop &&
                      state.catalogStatus != RequestStatus.loading &&
                      state.submissionStatus != RequestStatus.loading) {
                    context.read<CardRestrictionCubit>().requestBack();
                  }
                },
                child: Scaffold(
                  backgroundColor: context.colors.surfaceSubtle,
                  body: SafeArea(
                    child: Column(
                      children: [
                        AppTopBar(
                          title: cardRestrictionTitle(operation),
                          showLeadingActions: false,
                          leadingAction: const SizedBox.shrink(),
                          trailingIcon: const Center(
                            child: AvpImage(
                              image:
                                  '${AppConstants.baseImage}card_restriction_back.svg',
                              width: 6,
                              height: 10,
                            ),
                          ),
                          trailingTooltip: S.current.backLabel,
                          onTrailingPressed: context
                              .read<CardRestrictionCubit>()
                              .requestBack,
                          isTrailingActive:
                              state.catalogStatus != RequestStatus.loading &&
                              state.submissionStatus != RequestStatus.loading,
                        ),
                        Expanded(
                          child:
                              state.receipt != null ||
                                  state.catalogStatus !=
                                      RequestStatus.success ||
                                  state.catalog!.cards.isEmpty
                              ? CardServiceStatus(
                                  status: state.catalogStatus,
                                  empty: state.catalog?.cards.isEmpty == true,
                                  receipt: state.receipt,
                                  onRetry: context
                                      .read<CardRestrictionCubit>()
                                      .fetchCatalog,
                                )
                              : CardRestrictionForm(
                                  operation: operation,
                                  state: state,
                                ),
                        ),
                        if (state.receipt == null &&
                            state.catalogStatus == RequestStatus.success &&
                            state.catalog!.cards.isNotEmpty)
                          DepositRequestFooter(
                            termsAccepted: state.termsAccepted,
                            onTermsChanged: state.isEditable
                                ? context
                                      .read<CardRestrictionCubit>()
                                      .updateTermsAcceptance
                                : null,
                            onTermsRequested: context
                                .read<CardRestrictionCubit>()
                                .requestTerms,
                            onSubmit: context
                                .read<CardRestrictionCubit>()
                                .requestSubmission,
                            isLoading:
                                state.submissionStatus == RequestStatus.loading,
                            isActive: state.canSubmit && state.isEditable,
                            bottomPadding: 16,
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
