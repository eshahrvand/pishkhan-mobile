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
import '../../shared/profile_submission_dialog.dart';
import '../cubit/job_information_cubit.dart';
import '../widgets/job_information_form.dart';
import '../widgets/job_information_footer.dart';
import '../widgets/job_information_list.dart';

class JobInformationScreen extends StatelessWidget {
  const JobInformationScreen({super.key, this.onAssistantPressed});
  final VoidCallback? onAssistantPressed;
  void _showRequestFailure(BuildContext context, JobInformationState state) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(state.message!)));
  }

  Future<void> _handleEffect(
    BuildContext context,
    JobInformationState state,
  ) async {
    switch (state.effect) {
      case JobInformationEffect.actions:
        context.read<JobInformationCubit>().consumeJobInformationInteraction();
        final action = await showProfileActionsSheet<JobInformationAction>(
          context,
          editLabel: S.current.profileEditJobInformation,
          deleteLabel: S.current.profileDeleteJobInformation,
          editAction: JobInformationAction.edit,
          deleteAction: JobInformationAction.delete,
        );
        if (context.mounted) {
          context.read<JobInformationCubit>().applyJobInformationAction(action);
        }
      case JobInformationEffect.confirmDeletion:
        context.read<JobInformationCubit>().consumeJobInformationInteraction();
        await showAppDecisionSheet(
          context,
          title: S.current.profileDeleteJobInformation,
          message: S.current.profileDeleteJobInformationPrompt(
            jobInformationLabel(state.selectedJobInformation!.kind),
          ),
          confirmLabel: S.current.chequeCancelRemove,
          cancelLabel: S.current.dashboardCancel,
          onConfirm: () {
            context.read<JobInformationCubit>().submitDeletion(
              state.selectedJobInformation!,
            );
            Navigator.of(context).pop();
          },
        );
      case JobInformationEffect.minimumJobInformation:
        context.read<JobInformationCubit>().consumeJobInformationInteraction();
        await showAppDecisionSheet(
          context,
          title: S.current.profileDeleteJobInformation,
          message: S.current.profileMinimumJobInformation,
          confirmLabel: S.current.passwordUnderstood,
          onConfirm: () {
            Navigator.of(context).pop();
          },
        );
      case JobInformationEffect.confirmExit:
        context.read<JobInformationCubit>().consumeJobInformationInteraction();
        final confirmed = await showFlowExitDialog(context);
        if (context.mounted) {
          context.read<JobInformationCubit>().applyExitConfirmation(confirmed);
        }
      case JobInformationEffect.submitted:
        context.read<JobInformationCubit>().consumeJobInformationInteraction();
        await showDialog<void>(
          context: context,
          builder: (context) => ProfileSubmissionDialog(
            message: S.current.profileJobInformationQueued,
          ),
        );
        if (context.mounted) {
          context.read<JobInformationCubit>().applySubmissionDismissal();
        }
      case JobInformationEffect.back:
        NavigationActions.back(context);
      case JobInformationEffect.assistant:
        context.read<JobInformationCubit>().consumeJobInformationInteraction();
        NavigationActions.returnHome(context);
        onAssistantPressed?.call();
      case JobInformationEffect.terms:
        context.read<JobInformationCubit>().consumeJobInformationInteraction();
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
      create: (_) => JobInformationCubit()..fetchJobInformation(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<JobInformationCubit, JobInformationState>(
            listenWhen: (previous, current) =>
                previous.jobInformationStatus != current.jobInformationStatus &&
                current.jobInformationStatus == RequestStatus.failure,
            listener: _showRequestFailure,
          ),
          BlocListener<JobInformationCubit, JobInformationState>(
            listenWhen: (previous, current) =>
                previous.submissionStatus != current.submissionStatus &&
                current.submissionStatus == RequestStatus.failure,
            listener: _showRequestFailure,
          ),
          BlocListener<JobInformationCubit, JobInformationState>(
            listenWhen: (previous, current) =>
                previous.deletionStatus != current.deletionStatus &&
                current.deletionStatus == RequestStatus.failure,
            listener: _showRequestFailure,
          ),
          BlocListener<JobInformationCubit, JobInformationState>(
            listenWhen: (previous, current) =>
                previous.effect != current.effect && current.effect != null,
            listener: _handleEffect,
          ),
        ],
        child: BlocBuilder<JobInformationCubit, JobInformationState>(
          builder: (context, state) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: PopScope(
                canPop:
                    (state.jobInformationStatus != RequestStatus.loading &&
                        state.submissionStatus != RequestStatus.loading &&
                        state.deletionStatus != RequestStatus.loading) &&
                    (state.step == JobInformationStep.list),
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop &&
                      state.jobInformationStatus != RequestStatus.loading &&
                      state.submissionStatus != RequestStatus.loading &&
                      state.deletionStatus != RequestStatus.loading) {
                    context.read<JobInformationCubit>().requestBack();
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
                                  state.step == JobInformationStep.form &&
                                      state.selectedJobInformation != null
                                  ? S.current.profileEditJobInformation
                                  : S.current.dashboardJobInformation,
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
                                  (state.jobInformationStatus !=
                                          RequestStatus.loading &&
                                      state.submissionStatus !=
                                          RequestStatus.loading &&
                                      state.deletionStatus !=
                                          RequestStatus.loading)
                                  ? () {
                                      context
                                          .read<JobInformationCubit>()
                                          .requestBack();
                                    }
                                  : null,
                            ),
                            Expanded(
                              child: state.step == JobInformationStep.list
                                  ? const JobInformationList()
                                  : const JobInformationForm(),
                            ),
                            const JobInformationFooter(),
                          ],
                        ),
                        if (MediaQuery.viewInsetsOf(context).bottom == 0)
                          Positioned(
                            left: 16,
                            bottom: 76,
                            child: AppAssistantButton(
                              onPressed: () {
                                context
                                    .read<JobInformationCubit>()
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
