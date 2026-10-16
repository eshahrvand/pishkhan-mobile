import 'virtual_card_icon.dart';

import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_invoice.dart';

import '../cubit/virtual_card_cubit.dart';

import 'virtual_card_styles.dart';
import 'virtual_card_notice.dart';

class VirtualCardContent extends StatelessWidget {
  const VirtualCardContent({super.key, required this.count});
  final TextEditingController count;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VirtualCardCubit, VirtualCardState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.catalog != current.catalog ||
          previous.editable != current.editable ||
          previous.depositId != current.depositId ||
          previous.countText != current.countText ||
          previous.validCount != current.validCount ||
          previous.quote != current.quote ||
          previous.expanded != current.expanded ||
          previous.quoteStatus != current.quoteStatus ||
          previous.failure != current.failure,
      builder: (context, state) {
        if (state.status == RequestStatus.loading ||
            state.status == RequestStatus.initial) {
          return AppButton(
            onPressed: null,
            isLoading: true,
            label: S.current.dashboardLoading,
          );
        }
        if (state.status == RequestStatus.failure ||
            state.catalog?.deposits.isEmpty == true) {
          return Column(
            children: [
              Text(
                state.catalog?.deposits.isEmpty == true
                    ? S.current.virtualRequestEmpty
                    : S.current.dashboardLoadError,
              ),
              const SizedBox(height: 12),
              AppButton(
                onPressed: () {
                  count.clear();
                  context.read<VirtualCardCubit>().load();
                },
                label: S.current.dashboardRetry,
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              S.current.virtualRequestPrompt,
              style: virtualCardBodyStyle(context)
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            VirtualCardNotice(text: S.current.virtualRequestNotice),
            const SizedBox(height: 20),
            IgnorePointer(
              ignoring: !state.editable,
              child: AppSelect<String>(
                label: S.current.virtualRequestDepositLabel,
                hintText: S.current.virtualRequestDepositHint,
                value: state.depositId,
                options: [
                  for (final d in state.catalog!.deposits)
                    AppSelectOption(value: d.id, label: d.number),
                ],
                onChanged: context.read<VirtualCardCubit>().selectDeposit,
                labelSpacing: 8,
                labelStyle: virtualCardLabelStyle(context),
                textStyle: virtualCardBodyStyle(context).copyWith(
                  color: state.depositId == null
                      ? AppPalette.gray400
                      : context.colors.textPrimary,
                ),
                trailing: VirtualCardIcon(
                  path: state.depositId == null
                      ? AppAssets.issuanceSelectEmpty
                      : AppAssets.cardFeaturesChevron,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              S.current.virtualRequestCount,
              style: virtualCardLabelStyle(context),
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: count,
              enabled: state.editable,
              hintText: S.current.virtualRequestCountHint,
              hintColor: AppPalette.gray400,
              textStyle: virtualCardBodyStyle(context),
              textAlign: TextAlign.right,
              textDirection: TextDirection.ltr,
              keyboardType: TextInputType.number,
              normalizeDigits: true,
              focusRing: AppTextFieldFocusRing.none,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              errorText: state.countText.isNotEmpty && !state.validCount
                  ? S.current.virtualRequestCountError(state.catalog!.maxCount)
                  : null,
              onChanged: context.read<VirtualCardCubit>().countChanged,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 0,
              child: OverflowBox(
                minHeight: 1,
                maxHeight: 1,
                child: AvpImage(
                  image: AppAssets.issuanceDivider,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (state.quote != null)
              AppInvoice(
                totalAmount: CurrencyFormatter.format(state.quote!.totalRial),
                walletBalance: CurrencyFormatter.format(
                  state.quote!.walletBalanceRial,
                ),
                lines: [
                  AppInvoiceLine(
                    id: 'virtual-unit-fee',
                    label: S.current.virtualRequestUnitFee,
                    amount: CurrencyFormatter.format(
                      state.quote!.perCardFeeRial,
                    ),
                    icon: SizedBox.square(
                      dimension: 20,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 20 * .0833,
                            top: 20 * .1667,

                            width: 16.2878,
                            height: 12.9544,
                            child: AvpImage(
                              image: AppAssets.virtualRequestCard,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                isExpanded: state.expanded,
                onExpandedChanged: context.read<VirtualCardCubit>().setExpanded,
                isWalletBalanceSufficient: state.quote!.walletSufficient,
                title: S.current.issuancePayable,
                walletLabel: S.current.walletBalanceTitle,
                backgroundColor: context.colors.surface,
                labelColor: context.colors.textTertiary,
                walletSufficientLabel: S.current.issuanceWalletSufficient,
                walletInsufficientLabel: S.current.issuanceWalletInsufficient,
                zeroHeightDividers: true,
              )
            else
              VirtualCardNotice(
                text: S.current.virtualRequestFeeNotice(
                  CurrencyFormatter.format(
                    state.catalog!.indicativePerCardFeeRial,
                  ),
                ),
              ),
            if (state.quoteStatus == RequestStatus.loading) ...[
              const SizedBox(height: 12),
              Text(S.current.virtualRequestQuoting),
            ],
            if (state.failure != null) ...[
              const SizedBox(height: 12),
              Text(
                S.current.dashboardLoadError,
                style: virtualCardBodyStyle(context)
                    .copyWith(color: context.colors.error),
              ),
              AppButton(
                onPressed: state.editable
                    ? (state.quote == null
                          ? context.read<VirtualCardCubit>().refreshQuote
                          : context.read<VirtualCardCubit>().submit)
                    : null,
                label: S.current.dashboardRetry,
                variant: AppButtonVariant.text,
              ),
            ],
          ],
        );
      },
    );
  }
}
