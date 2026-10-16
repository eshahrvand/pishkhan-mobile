import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/virtual_card_cubit.dart';

import 'virtual_card_styles.dart';

class VirtualCardFooter extends StatelessWidget {
  const VirtualCardFooter({super.key, this.onTermsRequested});
  final VoidCallback? onTermsRequested;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VirtualCardCubit, VirtualCardState>(
      buildWhen: (previous, current) =>
          previous.terms != current.terms ||
          previous.editable != current.editable ||
          previous.quoteStatus != current.quoteStatus ||
          previous.canSubmit != current.canSubmit ||
          previous.submissionStatus != current.submissionStatus,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
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
                      value: state.terms,
                      size: AppCheckboxSize.md,
                      onChanged:
                          (state.editable &&
                              state.quoteStatus != RequestStatus.loading)
                          ? context.read<VirtualCardCubit>().acceptTerms
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
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
                              S.current.issuanceTerms,
                              style: virtualCardLabelStyle(context).copyWith(
                                color: context.colors.primary,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            ' ${S.current.issuanceTermsPrompt}',
                            style: virtualCardLabelStyle(context).copyWith(
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                onPressed: state.canSubmit
                    ? () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        context.read<VirtualCardCubit>().submit();
                      }
                    : null,
                label: S.current.virtualRequestSubmit,
                size: AppButtonSize.lg,
                constrainLabel: true,
                isLoading: state.submissionStatus == RequestStatus.loading,
                disabledAppearance: AppButtonDisabledAppearance.service,
              ),
            ],
          ),
        );
      },
    );
  }
}
