import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../../../domain/entities/wallet.dart';
import '../cubit/linked_deposit_cubit.dart';

class WalletLinkedDepositForm extends StatelessWidget {
  const WalletLinkedDepositForm({super.key, required this.state});
  final WalletLinkedDepositState state;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            S.current.walletLinkedDepositIntro,
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 24),
          CertificateInput(
            label: S.current.walletFromDeposit,
            hint: '',
            value: state.catalog?.wallet.linkedDeposit.number ?? '',
            readOnly: true,
            enabled: false,
          ),
          const SizedBox(height: 24),
          CertificateSelect<WalletDeposit>(
            label: S.current.walletToDeposit,
            hint: S.current.walletDepositHint,
            value: state.deposit,
            options: [
              for (final d in state.destinations)
                AppSelectOption(value: d, label: d.number),
            ],
            enabled: state.submissionStatus != RequestStatus.loading,
            onChanged: context.read<WalletLinkedDepositCubit>().selectDeposit,
          ),
        ],
      ),
    );
  }
}
