import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_deposit_list.dart';

import '../../deposit_list/widgets/deposit_ui.dart';
import '../../shared/certificate_fields.dart';
import '../cubit/close_surplus_deposits_cubit.dart';

class SurplusDepositsResult extends StatelessWidget {
  const SurplusDepositsResult({super.key, required this.state});
  final CloseSurplusDepositsState state;

  @override
  Widget build(BuildContext context) {
    if (state.review!.deposits.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppPalette.brand100,
                  border: Border.all(color: AppPalette.brand50, width: 8),
                ),
                child: const Center(
                  child: AvpImage(image: AppAssets.surplusDepositsEmpty),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                S.current.surplusDepositsEmptyTitle,
                textAlign: TextAlign.center,
                style: certificateValueStyle(context)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                S.current.surplusDepositsEmptyBody,
                textAlign: TextAlign.center,
                style: certificateValueStyle(context),
              ),
            ],
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 76),
      children: [
        Text(
          S.current.surplusDepositsReviewTitle,
          style: certificateValueStyle(context)
              .copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(
          '${S.current.surplusPrimaryDeposit}: ${state.deposit!.number}',
          style: certificateLabelStyle(context),
        ),
        const SizedBox(height: 20),
        for (final deposit in state.review!.deposits) ...[
          AppDepositList(
            alignContentToEdges: true,
            title: depositKindLabel(deposit.kind),
            accountNumber: deposit.number,
            accountNumberLabel: S.current.depositListNumber,
            statusFieldLabel: S.current.depositListStatus,
            statusLabel: depositStatusLabel(deposit.status),
            moreIcon: const SizedBox.shrink(),
            depositIcon: depositIcon(AppAssets.depositFeatureDeposit, size: 20),
            divider: const DepositDivider(
              asset: AppAssets.depositFeatureDivider,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
