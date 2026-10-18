import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_representative_card.dart';

import '../../deposit_list/widgets/deposit_ui.dart';
import '../cubit/representative_cubit.dart';

class RepresentativeList extends StatelessWidget {
  const RepresentativeList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RepresentativeCubit, RepresentativeState>(
      buildWhen: (previous, current) =>
          previous.representatives != current.representatives ||
          previous.isEditable != current.isEditable,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final representative in state.representatives) ...[
              AppRepresentativeCard(
                title: S.current.representativeNewPerson,
                secondary: CurrencyFormatter.toPersianDigits(
                  representative.nationalId,
                ),
                actionIcon: depositIcon(AppAssets.fileUploadTrash, size: 20),
                actionLabel: S.current.representativeRemove,
                actionAlignment: Alignment.centerLeft,
                bodyColor: AppPalette.gray100,
                detailLabelColor: context.colors.textTertiary,
                onMorePressed: state.isEditable
                    ? () => context
                          .read<RepresentativeCubit>()
                          .removeRepresentative(representative)
                    : null,
                rows: [
                  (
                    label: S.current.representativeKind,
                    value: S.current.representativeChequeBook,
                  ),
                  (
                    label: S.current.representativeDepositShort,
                    value: CurrencyFormatter.toPersianDigits(
                      representative.deposit.number,
                    ),
                  ),
                  (
                    label: S.current.representativeValidity,
                    value: JalaliDateFormatter.format(
                      representative.validUntil,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: IntrinsicWidth(
                child: SizedBox(
                  height: 20,
                  child: AppButton(
                    label: S.current.representativeAddNext,
                    leadingIcon: depositIcon(
                      AppAssets.issuancePlus,
                      size: 20,
                    ),
                    variant: AppButtonVariant.text,
                    size: AppButtonSize.sm,
                    horizontalPadding: 0,
                    contentGap: 8,
                    labelStyle: Theme.of(context).textTheme.bodySmall!
                        .copyWith(fontWeight: FontWeight.w500, height: 18 / 12),
                    constrainLabel: true,
                    onPressed: state.isEditable
                        ? context
                              .read<RepresentativeCubit>()
                              .requestNextRepresentative
                        : null,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
