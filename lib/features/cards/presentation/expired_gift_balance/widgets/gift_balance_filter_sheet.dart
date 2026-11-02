import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../../shared/card_service_sheet.dart';
import '../../shared/card_service_widgets.dart';
import '../cubit/expired_gift_balance_cubit.dart';
import '../models/gift_balance_deposit_filter.dart';

Future<bool?> showGiftBalanceFilter(
  BuildContext context,
  ExpiredGiftBalanceCubit cubit,
) => showCardServiceSheet<bool>(
  context,
  (_) =>
      BlocProvider.value(value: cubit, child: const GiftBalanceFilterSheet()),
);

class GiftBalanceFilterSheet extends StatelessWidget {
  const GiftBalanceFilterSheet({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpiredGiftBalanceCubit, ExpiredGiftBalanceState>(
      buildWhen: (previous, current) =>
          previous.draftFilter != current.draftFilter,
      builder: (context, state) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBottomSheetHeader(
                title: S.current.cardFeatureFilter,
                rightIcon: cardServiceIcon(
                  '${AppConstants.baseImage}card_features_filter_header.svg',
                ),
                showLeftAction: false,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: AppSelect<GiftBalanceDepositFilter>(
                  label: S.current.cardFeatureDeposit,
                  value: state.draftFilter,
                  labelSpacing: 8,
                  labelStyle: cardServiceSmall(context, medium: true),
                  textStyle: AppTypography.bodyMedium.copyWith(
                    height: 20 / 14,
                    letterSpacing: 0,
                    color: context.colors.textPrimary,
                  ),
                  trailing: cardServiceIcon(
                    '${AppConstants.baseImage}card_features_chevron.svg',
                  ),
                  options: [
                    for (final filter in state.filterOptions)
                      AppSelectOption(
                        value: filter,
                        label:
                            filter.deposit?.number ?? S.current.cardFeatureAll,
                      ),
                  ],
                  onChanged: context
                      .read<ExpiredGiftBalanceCubit>()
                      .selectDraftFilter,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: AppButton(
                  size: AppButtonSize.lg,
                  label: S.current.cardFeatureApplyFilter,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
