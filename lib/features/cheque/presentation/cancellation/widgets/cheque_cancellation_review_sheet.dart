import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../cubit/cheque_cancellation_cubit.dart';
import 'cheque_cancellation_delete_sheet.dart';
import 'cheque_cancellation_details.dart';

Future<bool?> showChequeCancellationReviewSheet(BuildContext context) {
  return showAppServiceSheet<bool>(
    context,
    BlocProvider.value(
      value: context.read<ChequeCancellationCubit>(),
      child: const ChequeCancellationReviewSheet(),
    ),
    scrimColor: context.colors.textSecondary.withValues(alpha: .9),
  );
}

class ChequeCancellationReviewSheet extends StatelessWidget {
  const ChequeCancellationReviewSheet({super.key});
  Future<void> _handleEffect(
    BuildContext context,
    ChequeCancellationState state,
  ) {
    context
        .read<ChequeCancellationCubit>()
        .consumeChequeCancellationInteraction();
    return showChequeCancellationDeleteSheet(context, state.pendingCheque!);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChequeCancellationCubit, ChequeCancellationState>(
      listenWhen: (previous, current) =>
          (previous.effect != current.effect && current.effect != null) &&
          current.effect == ChequeCancellationEffect.deleteReviewCheque,
      listener: _handleEffect,
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBottomSheetHeader(
              title:
                  '${S.current.chequeCancelReview} (${CurrencyFormatter.toPersianDigits('${state.selectedEntries.length}')})',
              showLeftAction: false,
              showRightIcon: false,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.selectedEntries.isEmpty)
                    Text(
                      S.current.chequeCancelEmpty,
                      textAlign: TextAlign.center,
                    ),
                  ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.selectedEntries.length,
                    separatorBuilder: (_, _) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const AvpImage(
                        image:
                            '${AppConstants.baseImage}card_features_divider.svg',
                        height: .5,
                        fit: BoxFit.fill,
                      ),
                    ),
                    itemBuilder: (context, index) => Row(
                      children: [
                        SizedBox.square(
                          dimension: 24,
                          child: Center(
                            child: Text(
                              CurrencyFormatter.toPersianDigits('${index + 1}'),
                              style: certificateLabelStyle(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ChequeCancellationDetails(
                            cheque: state.selectedEntries[index].cheque,
                            reviewLayout: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Semantics(
                          button: true,
                          label: S.current.chequeCancelRemove,
                          child: InkWell(
                            onTap: () => context
                                .read<ChequeCancellationCubit>()
                                .requestReviewChequeRemoval(
                                  state.selectedEntries[index].cheque,
                                ),
                            child: const AvpImage(
                              image:
                                  '${AppConstants.baseImage}issuance_trash.svg',
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  AppButton(
                    label: S.current.backLabel,
                    size: AppButtonSize.lg,
                    onPressed: () => Navigator.of(context).pop(true),
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
