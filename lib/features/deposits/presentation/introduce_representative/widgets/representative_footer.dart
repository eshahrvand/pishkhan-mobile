import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../shared/certificate_fields.dart';
import '../cubit/representative_cubit.dart';

class RepresentativeFooter extends StatelessWidget {
  const RepresentativeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<RepresentativeCubit, RepresentativeState>(
            buildWhen: (previous, current) =>
                previous.termsAccepted != current.termsAccepted ||
                previous.isEditable != current.isEditable,
            builder: (context, state) {
              return Container(
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: AppRadius.borderSm,
                ),
                child: Row(
                  children: [
                    AppCheckbox(
                      value: state.termsAccepted,
                      size: AppCheckboxSize.md,
                      onChanged: state.isEditable
                          ? context
                                .read<RepresentativeCubit>()
                                .updateTermsAcceptance
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        children: [
                          InkWell(
                            onTap: () => ScaffoldMessenger.of(context)
                                .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      S.current.issuanceTermsUnavailable,
                                    ),
                                  ),
                                ),
                            child: Text(
                              S.current.issuanceTerms,
                              style: certificateLabelStyle(context).copyWith(
                                color: context.colors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          Text(
                            ' ${S.current.issuanceTermsPrompt}',
                            style: certificateLabelStyle(context).copyWith(
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          BlocBuilder<RepresentativeCubit, RepresentativeState>(
            buildWhen: (previous, current) =>
                previous.canSubmit != current.canSubmit ||
                previous.submissionStatus != current.submissionStatus ||
                previous.submissionFailure != current.submissionFailure,
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.submissionFailure != null) ...[
                    Text(
                      S.current.issuanceSubmitError,
                      style: certificateLabelStyle(context)
                          .copyWith(color: context.colors.error),
                    ),
                    const SizedBox(height: 8),
                  ],
                  AppButton(
                    label: S.current.issuanceSubmit,
                    size: AppButtonSize.lg,
                    disabledAppearance: AppButtonDisabledAppearance.service,
                    isLoading: state.submissionStatus == RequestStatus.loading,
                    onPressed: state.canSubmit
                        ? context
                              .read<RepresentativeCubit>()
                              .submitRepresentatives
                        : null,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
