import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../deposit_list/widgets/deposit_ui.dart';
import '../../shared/certificate_delivery_address.dart';
import '../../shared/certificate_delivery_recipient.dart';
import '../../shared/certificate_delivery_agent.dart';
import '../cubit/average_balance_cubit.dart';

class AverageBalanceDeliveryForm extends StatelessWidget {
  const AverageBalanceDeliveryForm({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocBuilder<AverageBalanceCubit, AverageBalanceState>(
          buildWhen: (previous, current) =>
              previous.addresses != current.addresses ||
              previous.address != current.address,
          builder: (context, state) {
            return CertificateDeliveryAddress(
              addresses: state.addresses,
              address: state.address,
              onAddress: context.read<AverageBalanceCubit>().selectAddress,
              onAddAddress: context
                  .read<AverageBalanceCubit>()
                  .requestAddAddress,
              onDeleteAddress: context
                  .read<AverageBalanceCubit>()
                  .requestDeleteAddress,
            );
          },
        ),
        const SizedBox(height: 20),
        const DepositDivider(
          asset: '${AppConstants.baseImage}certificate_certDivider.svg',
        ),
        const SizedBox(height: 20),
        BlocBuilder<AverageBalanceCubit, AverageBalanceState>(
          buildWhen: (previous, current) =>
              previous.isOtherRecipient != current.isOtherRecipient ||
              previous.recipientName != current.recipientName ||
              previous.recipientNationalId != current.recipientNationalId,
          builder: (context, state) {
            return CertificateDeliveryRecipient(
              otherRecipient: state.isOtherRecipient,
              recipientName: state.recipientName,
              recipientNationalId: state.recipientNationalId,
              onOtherRecipient: context
                  .read<AverageBalanceCubit>()
                  .updateOtherRecipient,
              onRecipientName: context
                  .read<AverageBalanceCubit>()
                  .updateRecipientName,
              onRecipientNationalId: context
                  .read<AverageBalanceCubit>()
                  .updateRecipientNationalId,
            );
          },
        ),
        const SizedBox(height: 20),
        const DepositDivider(
          asset: '${AppConstants.baseImage}certificate_certDivider.svg',
        ),
        const SizedBox(height: 20),
        BlocBuilder<AverageBalanceCubit, AverageBalanceState>(
          buildWhen: (previous, current) =>
              previous.isIncludeAgent != current.isIncludeAgent ||
              previous.agentIdentifier != current.agentIdentifier ||
              previous.canCheckAgent != current.canCheckAgent,
          builder: (context, state) {
            return CertificateDeliveryAgent(
              includeAgent: state.isIncludeAgent,
              agentIdentifier: state.agentIdentifier,
              canCheckAgent: state.canCheckAgent,
              onIncludeAgent: context
                  .read<AverageBalanceCubit>()
                  .updateIncludeAgent,
              onAgent: context
                  .read<AverageBalanceCubit>()
                  .updateAgentIdentifier,
              onAgentLookup: context
                  .read<AverageBalanceCubit>()
                  .requestAgentLookup,
            );
          },
        ),
      ],
    );
  }
}
