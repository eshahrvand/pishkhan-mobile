import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/flow_exit_dialog.dart';

import '../../shared/profile_actions_sheet.dart';

import 'package:pishkhan_mobile/shared/widgets/app_decision_sheet.dart';

import '../../shared/profile_labels.dart';
import '../cubit/occupations_cubit.dart';
import '../widgets/occupation_form.dart';
import '../widgets/occupation_footer.dart';
import '../widgets/occupations_list.dart';

class OccupationsScreen extends StatelessWidget {
  const OccupationsScreen({super.key, this.onAssistantPressed});
  final VoidCallback? onAssistantPressed;
  Future<void> _handleEffect(
    BuildContext context,
    OccupationsState state,
  ) async {
    if (state.message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.message!)));
      return;
    }

    switch (state.effect) {
      case OccupationEffect.actions:
        context.read<OccupationsCubit>().consumeOccupationsInteraction();
        final action = await showProfileActionsSheet<OccupationAction>(
          context,
          editLabel: S.current.profileEditOccupation,
          deleteLabel: S.current.profileDeleteOccupation,
          editAction: OccupationAction.edit,
          deleteAction: OccupationAction.delete,
        );
        if (context.mounted) {
          context.read<OccupationsCubit>().applyOccupationAction(action);
        }
      case OccupationEffect.confirmDeletion:
        context.read<OccupationsCubit>().consumeOccupationsInteraction();
        await showAppDecisionSheet(
          context,
          title: S.current.profileDeleteOccupation,
          message: S.current.profileDeleteOccupationPrompt(
            occupationLabel(state.selectedOccupation!.kind),
          ),
          confirmLabel: S.current.chequeCancelRemove,
          cancelLabel: S.current.dashboardCancel,
          onConfirm: () {
            context.read<OccupationsCubit>().submitDeletion(
              state.selectedOccupation!,
            );
            Navigator.of(context).pop();
          },
        );
      case OccupationEffect.minimumOccupation:
        context.read<OccupationsCubit>().consumeOccupationsInteraction();
        await showAppDecisionSheet(
          context,
          title: S.current.profileDeleteOccupation,
          message: S.current.profileMinimumOccupation,
          confirmLabel: S.current.passwordUnderstood,
          onConfirm: () {
            Navigator.of(context).pop();
          },
        );
      case OccupationEffect.confirmExit:
        context.read<OccupationsCubit>().consumeOccupationsInteraction();
        final confirmed = await showFlowExitDialog(context);
        if (context.mounted) {
          context.read<OccupationsCubit>().applyExitConfirmation(confirmed);
        }
      case OccupationEffect.submitted:
        context.read<OccupationsCubit>().consumeOccupationsInteraction();
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(S.current.profileOccupationQueued),
            actions: [
              AppButton(
                label: S.current.backLabel,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
        if (context.mounted) {
          context.read<OccupationsCubit>().applySubmissionDismissal();
        }
      case OccupationEffect.back:
        NavigationActions.back(context);
      case OccupationEffect.assistant:
        context.read<OccupationsCubit>().consumeOccupationsInteraction();
        NavigationActions.returnHome(context);
        onAssistantPressed?.call();
      case OccupationEffect.terms:
        context.read<OccupationsCubit>().consumeOccupationsInteraction();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.issuanceTermsUnavailable)),
        );
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OccupationsCubit()..fetchOccupations(),
      child: BlocListener<OccupationsCubit, OccupationsState>(
        listenWhen: (previous, current) =>
            (previous.effect != current.effect && current.effect != null) ||
            ((previous.occupationsStatus != current.occupationsStatus &&
                    current.occupationsStatus == RequestStatus.failure) ||
                (previous.submissionStatus != current.submissionStatus &&
                    current.submissionStatus == RequestStatus.failure) ||
                (previous.deletionStatus != current.deletionStatus &&
                    current.deletionStatus == RequestStatus.failure)),
        listener: _handleEffect,
        child: BlocBuilder<OccupationsCubit, OccupationsState>(
          builder: (context, state) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: PopScope(
                canPop:
                    (state.occupationsStatus != RequestStatus.loading &&
                        state.submissionStatus != RequestStatus.loading &&
                        state.deletionStatus != RequestStatus.loading) &&
                    (state.step == OccupationStep.list),
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop &&
                      state.occupationsStatus != RequestStatus.loading &&
                      state.submissionStatus != RequestStatus.loading &&
                      state.deletionStatus != RequestStatus.loading) {
                    context.read<OccupationsCubit>().requestBack();
                  }
                },
                child: Scaffold(
                  backgroundColor: context.colors.surfaceSubtle,
                  body: SafeArea(
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            AppTopBar(
                              title:
                                  state.step == OccupationStep.form &&
                                      state.selectedOccupation != null
                                  ? S.current.profileEditOccupation
                                  : S.current.dashboardOccupation,
                              showLeadingActions: false,
                              leadingAction: const SizedBox.shrink(),
                              trailingIcon: AvpImage(
                                image:
                                    '${AppConstants.baseImage}deposit_list_back.svg',
                                width: 24,
                                height: 24,
                              ),
                              trailingTooltip: S.current.backLabel,
                              onTrailingPressed:
                                  (state.occupationsStatus !=
                                          RequestStatus.loading &&
                                      state.submissionStatus !=
                                          RequestStatus.loading &&
                                      state.deletionStatus !=
                                          RequestStatus.loading)
                                  ? () {
                                      context
                                          .read<OccupationsCubit>()
                                          .requestBack();
                                    }
                                  : null,
                            ),
                            Expanded(
                              child: state.step == OccupationStep.list
                                  ? const OccupationsList()
                                  : const OccupationForm(),
                            ),
                            const OccupationFooter(),
                          ],
                        ),
                        if (MediaQuery.viewInsetsOf(context).bottom == 0)
                          Positioned(
                            left: 16,
                            bottom: 76,
                            child: AppAssistantButton(
                              onPressed: () {
                                context
                                    .read<OccupationsCubit>()
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
