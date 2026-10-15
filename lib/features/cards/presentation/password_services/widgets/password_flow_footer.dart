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
      buildWhen: (a, b) =>
          a.canContinue != b.canContinue ||
          a.status != b.status ||
          a.checkStatus != b.checkStatus ||
          a.submissionStatus != b.submissionStatus ||
          a.step != b.step ||
          a.terms != b.terms ||
          a.record != b.record ||
          a.catalog != b.catalog,
      builder: (context, state) {
        if (state.isChange &&
            state.record != null &&
            state.submissionStatus != RequestStatus.success) {
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
            state.status == RequestStatus.failure ||
            state.catalog?.cards.isNotEmpty != true ||
            state.status == RequestStatus.loading) {
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
                        value: state.terms,
                        size: AppCheckboxSize.md,
                        onChanged: context
                            .read<SecondPasswordCubit>()
                            .acceptTerms,
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
                        context.read<SecondPasswordCubit>().next();
                      }
                    : null,
                label:
                    state.isChange &&
                        state.step == SecondPasswordStep.password &&
                        state.formComplete
                    ? S.current.passwordChangeSubmit
                    : state.step == SecondPasswordStep.instruction
                    ? S.current.passwordStartKyc
                    : state.step == SecondPasswordStep.recording
                    ? S.current.passwordSubmit
                    : S.current.issuanceNext,
                isLoading:
                    state.checkStatus == RequestStatus.loading ||
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
