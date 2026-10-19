import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../../../domain/entities/cheque_cancellation.dart';
import '../cubit/cheque_cancellation_cubit.dart';
import 'cheque_cancellation_details.dart';
import 'cheque_cancellation_labels.dart';

class ChequeCancellationReasons extends StatelessWidget {
  const ChequeCancellationReasons({super.key, required this.state});
  final ChequeCancellationState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          S.current.chequeCancelReasonsPrompt,
          style: certificateValueStyle(context)
              .copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            SizedBox(
              height: 20,
              child: AppButton(
                label: S.current.chequeCancelAllReasons,
                variant: AppButtonVariant.text,
                size: AppButtonSize.sm,
                horizontalPadding: 0,
                contentGap: 8,
                labelStyle: certificateLabelStyle(context)
                    .copyWith(color: context.colors.primary),
                trailingIcon: const AvpImage(
                  image: AppAssets.chequeCancelAngleDown,
                  width: 20,
                  height: 20,
                ),
                onPressed: state.isEditable
                    ? context
                          .read<ChequeCancellationCubit>()
                          .requestReasonForAll
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.selectedEntries.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: context.colors.border),
                borderRadius: AppRadius.borderSm,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ChequeCancellationDetails(
                          cheque: state.selectedEntries[index].cheque,
                          reasonLayout: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Semantics(
                        label: S.current.chequeCancelRemove,
                        button: true,
                        child: InkWell(
                          onTap: state.isEditable
                              ? () => context
                                    .read<ChequeCancellationCubit>()
                                    .requestChequeRemoval(
                                      state.selectedEntries[index].cheque,
                                    )
                              : null,
                          child: const AvpImage(
                            image: AppAssets.issuanceTrash,
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const AvpImage(
                    image: AppAssets.chequeCancelReasonDivider,
                    height: 1,
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(height: 16),
                  // The existing select supplies field visuals; the flow opens the
                  // Figma reason sheet through its Cubit effect instead of a menu.
                  InkWell(
                    onTap: state.isEditable
                        ? () => context
                              .read<ChequeCancellationCubit>()
                              .requestReason(state.selectedEntries[index])
                        : null,
                    child: IgnorePointer(
                      child: AppSelect<ChequeCancellationReason>(
                        value: state.selectedEntries[index].reason,
                        hintText: S.current.chequeCancelReasonHint,
                        options: [
                          for (final reason in state.catalog!.reasons)
                            AppSelectOption(
                              value: reason,
                              label: cancellationReasonLabel(reason),
                            ),
                        ],
                        onChanged: context
                            .read<ChequeCancellationCubit>()
                            .selectReasonDraft,
                        textStyle: certificateValueStyle(context).copyWith(
                          color: state.selectedEntries[index].reason == null
                              ? context.colors.textDisabled
                              : context.colors.textPrimary,
                        ),
                        trailing: SizedBox.square(
                          dimension: 20,
                          child: Center(
                            child: AvpImage(
                              image: state.selectedEntries[index].reason == null
                                  ? AppAssets.issuanceSelectEmpty
                                  : AppAssets.cardFeaturesChevron,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
