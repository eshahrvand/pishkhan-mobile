import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../../../domain/entities/issuance_data.dart';
import '../cubit/card_issuance_cubit.dart';

import 'issuance_styles.dart';
import 'issuance_divider.dart';
import 'issuance_select.dart';
import 'issuance_toggle_row.dart';
import 'issuance_current_card_row.dart';

class IssuanceSelection extends StatelessWidget {
  const IssuanceSelection({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CardIssuanceCubit, CardIssuanceState>(
      buildWhen: (previous, current) =>
          previous.catalog != current.catalog ||
          previous.draft != current.draft ||
          previous.deposit != current.deposit,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IssuanceSelect<String>(
              options: [
                for (final d in state.catalog!.deposits)
                  AppSelectOption(value: d.id, label: d.number),
              ],
              value: state.draft.depositId,
              label: S.current.issuanceDeposit,
              hint: S.current.issuanceDepositHint,
              onChanged: (v) {
                if (v != null) {
                  context.read<CardIssuanceCubit>().selectDeposit(v);
                }
              },
            ),
            if (state.deposit != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    IssuanceCurrentCardRow(
                      label: S.current.issuanceCurrentCard,
                      value: state.deposit!.cardNumber,
                      asset: AppAssets.issuanceCredit,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 0,
                      width: double.infinity,
                      child: OverflowBox(
                        minHeight: .5,
                        maxHeight: .5,
                        child: AvpImage(
                          image: AppAssets.issuanceCardDivider,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    IssuanceCurrentCardRow(
                      label: S.current.issuanceExpiry,
                      value: state.deposit!.expiry,
                      asset: AppAssets.issuanceCalendar,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            const IssuanceDivider(),
            const SizedBox(height: 20),
            IssuanceSelect<IssuanceType>(
              options: [
                for (final type in state.catalog!.types)
                  AppSelectOption(value: type, label: issuanceTypeLabel(type)),
              ],
              value: state.draft.type,
              label: S.current.issuanceType,
              hint: S.current.issuanceTypeHint,
              onChanged: (v) {
                context.read<CardIssuanceCubit>().selectIssuanceType(v);
              },
            ),
            const SizedBox(height: 20),
            const IssuanceDivider(),
            const SizedBox(height: 20),
            IssuanceToggleRow(
              label: S.current.issuanceNoPhysical,
              value: state.draft.noPhysicalCard,
              onChanged: context
                  .read<CardIssuanceCubit>()
                  .updatePhysicalCardOmission,
            ),
          ],
        );
      },
    );
  }
}
