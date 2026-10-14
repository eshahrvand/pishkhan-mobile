import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/certificate_data.dart';
import '../../shared/certificate_fields.dart';
import '../cubit/average_balance_cubit.dart';

class AverageBalanceTurnoverField extends StatelessWidget {
  const AverageBalanceTurnoverField({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AverageBalanceCubit, AverageBalanceState>(
      buildWhen: (previous, current) => previous.turnover != current.turnover,
      builder: (context, state) {
        return CertificateSelect<StatementTurnover>(
          label: S.current.certificateTurnover,
          hint: S.current.certificateTurnoverHint,
          value: state.turnover,
          options: [
            for (final value in StatementTurnover.values)
              AppSelectOption(
                value: value,
                label: switch (value) {
                  StatementTurnover.depositsAndWithdrawals =>
                    S.current.certificateBothTurnovers,
                  StatementTurnover.deposits =>
                    S.current.certificateDepositsOnly,
                  StatementTurnover.withdrawals =>
                    S.current.certificateWithdrawalsOnly,
                  StatementTurnover.averageBalance =>
                    S.current.certificateAverageBalance,
                },
              ),
          ],
          onChanged: context.read<AverageBalanceCubit>().selectTurnover,
        );
      },
    );
  }
}
