import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/certificate_data.dart';
import '../../shared/certificate_fields.dart';

class AverageBalanceTurnoverField extends StatelessWidget {
  const AverageBalanceTurnoverField({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final StatementTurnover? value;
  final ValueChanged<StatementTurnover> onChanged;
  @override
  Widget build(BuildContext context) {
    return CertificateSelect<StatementTurnover>(
      label: S.current.certificateTurnover,
      hint: S.current.certificateTurnoverHint,
      value: value,
      options: [
        for (final value in StatementTurnover.values)
          AppSelectOption(
            value: value,
            label: switch (value) {
              StatementTurnover.depositsAndWithdrawals =>
                S.current.certificateBothTurnovers,
              StatementTurnover.deposits => S.current.certificateDepositsOnly,
              StatementTurnover.withdrawals =>
                S.current.certificateWithdrawalsOnly,
              StatementTurnover.averageBalance =>
                S.current.certificateAverageBalance,
            },
          ),
      ],
      onChanged: onChanged,
    );
  }
}
