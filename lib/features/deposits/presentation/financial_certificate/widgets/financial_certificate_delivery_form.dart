import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../deposit_list/widgets/deposit_ui.dart';
import '../../shared/certificate_delivery_address.dart';
import '../../shared/certificate_delivery_recipient.dart';
import '../../shared/certificate_delivery_agent.dart';
import '../cubit/financial_certificate_cubit.dart';

class FinancialCertificateDeliveryForm extends StatelessWidget {
  const FinancialCertificateDeliveryForm({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocBuilder<FinancialCertificateCubit, FinancialCertificateState>(
          buildWhen: (previous, current) =>
              previous.addresses != current.addresses ||
              previous.address != current.address,
          builder: (context, state) {
            return CertificateDeliveryAddress(
              addresses: state.addresses,
              address: state.address,
              onAddress: context
                  .read<FinancialCertificateCubit>()
                  .selectAddress,
              onAddAddress: context
                  .read<FinancialCertificateCubit>()
                  .requestAddAddress,
              onDeleteAddress: context
                  .read<FinancialCertificateCubit>()
                  .requestDeleteAddress,
            );
          },
        ),
        const SizedBox(height: 20),
        const DepositDivider(
          asset: '${AppConstants.baseImage}certificate_certDivider.svg',
        ),
        const SizedBox(height: 20),
        BlocBuilder<FinancialCertificateCubit, FinancialCertificateState>(
          buildWhen: (previous, current) =>
              previous.isOtherRecipient != current.isOtherRecipient ||
              previous.deliveryRecipientName != current.deliveryRecipientName ||
              previous.deliveryRecipientNationalId !=
                  current.deliveryRecipientNationalId,
          builder: (context, state) {
            return CertificateDeliveryRecipient(
              otherRecipient: state.isOtherRecipient,
              recipientName: state.deliveryRecipientName,
              recipientNationalId: state.deliveryRecipientNationalId,
              onOtherRecipient: context
                  .read<FinancialCertificateCubit>()
                  .updateOtherRecipient,
              onRecipientName: context
                  .read<FinancialCertificateCubit>()
                  .updateRecipientName,
              onRecipientNationalId: context
                  .read<FinancialCertificateCubit>()
                  .updateRecipientNationalId,
            );
          },
        ),
        const SizedBox(height: 20),
        const DepositDivider(
          asset: '${AppConstants.baseImage}certificate_certDivider.svg',
        ),
        const SizedBox(height: 20),
        BlocBuilder<FinancialCertificateCubit, FinancialCertificateState>(
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
                  .read<FinancialCertificateCubit>()
                  .updateIncludeAgent,
              onAgent: context
                  .read<FinancialCertificateCubit>()
                  .updateAgentIdentifier,
              onAgentLookup: context
                  .read<FinancialCertificateCubit>()
                  .requestAgentLookup,
            );
          },
        ),
      ],
    );
  }
}
