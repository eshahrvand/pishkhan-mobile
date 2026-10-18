import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/cubit/second_password_cubit.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

class PasswordFlowFooter extends StatelessWidget {
  const PasswordFlowFooter({
    super.key,
    this.onTermsRequested,
    required this.onBack,
  });
  final VoidCallback onBack;
  final VoidCallback? onTermsRequested;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SecondPasswordCubit, SecondPasswordState>(
      builder: (context, state) {
        if (state.isFullStatusVisible) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: AppButton(
              onPressed: onBack,
              label: S.current.passwordUnderstood,
              size: AppButtonSize.lg,
              constrainLabel: true,
            ),
          );
        }
        if (state.record != null ||
            state.catalogStatus == RequestStatus.failure ||
            state.catalog?.cards.isNotEmpty != true ||
            state.catalogStatus == RequestStatus.loading) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            16,
            state.step == SecondPasswordStep.password ? 0 : 16,
            16,
            16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.step == SecondPasswordStep.password) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  constraints: const BoxConstraints(minHeight: 44),
                  decoration: BoxDecoration(
                    color: state.isChange
                        ? context.colors.surfaceSubtle
                        : context.colors.surface,
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Row(
                    children: [
                      AppCheckbox(
                        value: state.termsAccepted,
                        size: AppCheckboxSize.md,
                        onChanged: state.isEditable
                            ? context
                                  .read<SecondPasswordCubit>()
                                  .updateTermsAcceptance
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            InkWell(
                              onTap:
                                  onTermsRequested ??
                                  () => ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            S.current.issuanceTermsUnavailable,
                                          ),
                                        ),
                                      ),
                              child: Text(
                                '${S.current.issuanceTerms} ',
                                style: Theme.of(context).textTheme.bodySmall!
                                    .copyWith(
                                      color: context.colors.primary,
                                      decoration: TextDecoration.underline,
                                      height: 18 / 12,
                                    ),
                              ),
                            ),
                            Text(
                              S.current.issuanceTermsPrompt,
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(height: 18 / 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              AppButton(
                onPressed: state.canContinue
                    ? () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        context.read<SecondPasswordCubit>().submitCurrentStep();
                      }
                    : null,
                label: getPasswordContinueTitle(state),
                isLoading:
                    state.existingRequestStatus == RequestStatus.loading ||
                    state.submissionStatus == RequestStatus.loading,
                size: AppButtonSize.lg,
                constrainLabel: true,
                disabledAppearance: AppButtonDisabledAppearance.service,
              ),
            ],
          ),
        );
      },
    );
  }
}

String getPasswordContinueTitle(SecondPasswordState state) {
  return switch (state.primaryAction) {
    PasswordPrimaryAction.changePassword => S.current.passwordChangeSubmit,
    PasswordPrimaryAction.startKyc => S.current.passwordStartKyc,
    PasswordPrimaryAction.submit => S.current.passwordSubmit,
    PasswordPrimaryAction.continueFlow => S.current.issuanceNext,
  };
}
