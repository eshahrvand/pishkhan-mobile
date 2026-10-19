import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../cubit/cheque_cancellation_cubit.dart';
import 'cheque_cancellation_labels.dart';

Future<void> showChequeCancellationReasonSheet(BuildContext context) {
  return showAppServiceSheet<void>(
    context,
    BlocProvider.value(
      value: context.read<ChequeCancellationCubit>(),
      child: const ChequeCancellationReasonSheet(),
    ),
    scrimColor: context.colors.textSecondary.withValues(alpha: .9),
  );
}

class ChequeCancellationReasonSheet extends StatelessWidget {
  const ChequeCancellationReasonSheet({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChequeCancellationCubit, ChequeCancellationState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBottomSheetHeader(
              title: state.isReasonForAll
                  ? S.current.chequeCancelAllReasonsTitle
                  : S.current.chequeCancelReason,
              showLeftAction: false,
              showRightIcon: false,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                children: [
                  for (final reason in state.catalog!.reasons)
                    SizedBox(
                      height: 56,
                      child: Semantics(
                        checked: state.reasonDraft == reason,
                        inMutuallyExclusiveGroup: true,
                        child: InkWell(
                          onTap: () => context
                              .read<ChequeCancellationCubit>()
                              .selectReasonDraft(reason),
                          child: Row(
                            children: [
                              // avp_ui has no circular radio primitive; this authored
                              // choice uses the exact Figma check asset and theme tokens.
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: state.reasonDraft == reason
                                      ? context.colors.primary
                                      : context.colors.surface,
                                  border: Border.all(
                                    color: state.reasonDraft == reason
                                        ? context.colors.primary
                                        : context.colors.border,
                                  ),
                                ),
                                child: state.reasonDraft == reason
                                    ? const Center(
                                        child: AvpImage(
                                          image: AppAssets.chequeCancelCheck,
                                          width: 16,
                                          height: 16,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  cancellationReasonLabel(reason),
                                  style: certificateValueStyle(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: S.current.dashboardCancel,
                          variant: AppButtonVariant.secondaryGray,
                          size: AppButtonSize.lg,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: S.current.chequeCancelChoose,
                          size: AppButtonSize.lg,
                          disabledAppearance:
                              AppButtonDisabledAppearance.service,
                          onPressed: state.reasonDraft != null
                              ? () {
                                  context
                                      .read<ChequeCancellationCubit>()
                                      .applyReason();
                                  Navigator.of(context).pop();
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
