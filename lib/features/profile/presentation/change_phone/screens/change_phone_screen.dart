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

import '../../shared/profile_submission_dialog.dart';
import '../cubit/change_phone_cubit.dart';
import '../widgets/change_phone_form.dart';
import '../widgets/change_phone_footer.dart';

class ChangePhoneScreen extends StatelessWidget {
  const ChangePhoneScreen({super.key, this.onAssistantPressed});
  final VoidCallback? onAssistantPressed;
  void _showRequestFailure(BuildContext context, ChangePhoneState state) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(state.message!)));
  }

  Future<void> _handleEffect(
    BuildContext context,
    ChangePhoneState state,
  ) async {
    switch (state.effect) {
      case ChangePhoneEffect.confirmExit:
        context.read<ChangePhoneCubit>().consumeChangePhoneInteraction();
        final confirmed = await showFlowExitDialog(context);
        if (context.mounted) {
          context.read<ChangePhoneCubit>().applyExitConfirmation(confirmed);
        }
      case ChangePhoneEffect.back:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) NavigationActions.back(context);
        });
      case ChangePhoneEffect.home:
        NavigationActions.returnHome(context);
      case ChangePhoneEffect.assistant:
        context.read<ChangePhoneCubit>().consumeChangePhoneInteraction();
        NavigationActions.returnHome(context);
        onAssistantPressed?.call();
      case ChangePhoneEffect.terms:
        context.read<ChangePhoneCubit>().consumeChangePhoneInteraction();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.issuanceTermsUnavailable)),
        );
      case ChangePhoneEffect.submitted:
        context.read<ChangePhoneCubit>().consumeChangePhoneInteraction();
        await showDialog<void>(
          context: context,
          builder: (context) =>
              ProfileSubmissionDialog(message: S.current.profilePhoneSubmitted),
        );
        if (context.mounted) {
          context.read<ChangePhoneCubit>().applySubmissionDismissal();
        }
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChangePhoneCubit()..fetchSettings(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<ChangePhoneCubit, ChangePhoneState>(
            listenWhen: (previous, current) =>
                previous.settingsStatus != current.settingsStatus &&
                current.settingsStatus == RequestStatus.failure,
            listener: _showRequestFailure,
          ),
          BlocListener<ChangePhoneCubit, ChangePhoneState>(
            listenWhen: (previous, current) =>
                previous.otpRequestStatus != current.otpRequestStatus &&
                current.otpRequestStatus == RequestStatus.failure,
            listener: _showRequestFailure,
          ),
          BlocListener<ChangePhoneCubit, ChangePhoneState>(
            listenWhen: (previous, current) =>
                previous.submissionStatus != current.submissionStatus &&
                current.submissionStatus == RequestStatus.failure,
            listener: _showRequestFailure,
          ),
          BlocListener<ChangePhoneCubit, ChangePhoneState>(
            listenWhen: (previous, current) =>
                previous.effect != current.effect && current.effect != null,
            listener: _handleEffect,
          ),
        ],
        child: BlocBuilder<ChangePhoneCubit, ChangePhoneState>(
          builder: (context, state) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: PopScope(
                canPop:
                    (state.settingsStatus != RequestStatus.loading &&
                        state.otpRequestStatus != RequestStatus.loading &&
                        state.submissionStatus != RequestStatus.loading) &&
                    (state.effect == ChangePhoneEffect.back),
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop &&
                      state.settingsStatus != RequestStatus.loading &&
                      state.otpRequestStatus != RequestStatus.loading &&
                      state.submissionStatus != RequestStatus.loading) {
                    context.read<ChangePhoneCubit>().requestBack();
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
                              title: S.current.profileChangePhone,
                              showLeadingActions: false,
                              leadingAction: const SizedBox.shrink(),
                              trailingIcon: AvpImage(
                                image:
                                    '${AppConstants.baseImage}deposit_list_back.svg',
                                width: 24,
                                height: 24,
                              ),
                              trailingTooltip: S.current.backLabel,
                              onTrailingPressed: () {
                                context.read<ChangePhoneCubit>().requestBack();
                              },
                              isTrailingActive:
                                  (state.settingsStatus !=
                                      RequestStatus.loading &&
                                  state.otpRequestStatus !=
                                      RequestStatus.loading &&
                                  state.submissionStatus !=
                                      RequestStatus.loading),
                            ),
                            Expanded(child: const ChangePhoneForm()),
                            const ChangePhoneFooter(),
                          ],
                        ),
                        if (MediaQuery.viewInsetsOf(context).bottom == 0)
                          Positioned(
                            left: 16,
                            bottom: 76,
                            child: AppAssistantButton(
                              onPressed: () {
                                context
                                    .read<ChangePhoneCubit>()
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
