import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/listed_deposit.dart';
import '../../shared/certificate_fields.dart';
import '../cubit/close_surplus_deposits_cubit.dart';

class CloseSurplusDepositsForm extends StatelessWidget {
  const CloseSurplusDepositsForm({super.key, required this.state});
  final CloseSurplusDepositsState state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 76),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            S.current.surplusDepositsDescription,
            style: certificateValueStyle(context)
                .copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          CertificateSelect<ListedDeposit>(
            label: S.current.surplusPrimaryDeposit,
            hint: S.current.surplusPrimaryDepositHint,
            value: state.deposit,
            enabled: state.isEditable,
            options: [
              for (final deposit in state.deposits)
                AppSelectOption(value: deposit, label: deposit.number),
            ],
            onChanged: context
                .read<CloseSurplusDepositsCubit>()
                .selectPrimaryDeposit,
          ),
          if (state.depositsStatus == RequestStatus.loading) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
          ],
          if (state.depositsStatus == RequestStatus.failure) ...[
            const SizedBox(height: 16),
            Text(
              S.current.dashboardLoadError,
              style: certificateLabelStyle(context)
                  .copyWith(color: context.colors.error),
            ),
            AppButton(
              label: S.current.dashboardRetry,
              onPressed: context
                  .read<CloseSurplusDepositsCubit>()
                  .fetchPrimaryDeposits,
            ),
          ],
          if (state.depositsStatus == RequestStatus.success &&
              state.deposits.isEmpty) ...[
            const SizedBox(height: 16),
            Text(S.current.depositsEmpty),
          ],
        ],
      ),
    );
  }
}
