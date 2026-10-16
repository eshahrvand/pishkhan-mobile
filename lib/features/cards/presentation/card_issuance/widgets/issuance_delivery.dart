import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_address_card.dart';

import '../../../domain/entities/issuance_data.dart';
import '../cubit/card_issuance_cubit.dart';

import 'issuance_styles.dart';
import 'issuance_divider.dart';
import 'issuance_select.dart';
import 'issuance_toggle_row.dart';

class IssuanceDelivery extends StatefulWidget {
  const IssuanceDelivery({
    super.key,
    required this.onAddAddress,
    required this.onDeleteAddress,
  });
  final VoidCallback onAddAddress;
  final ValueChanged<IssuanceAddress> onDeleteAddress;
  @override
  State<IssuanceDelivery> createState() => _IssuanceDeliveryState();
}

class _IssuanceDeliveryState extends State<IssuanceDelivery> {
  late final TextEditingController name;
  late final TextEditingController national;
  late final TextEditingController mobile;
  late final TextEditingController agentName;
  late final TextEditingController agentCode;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(
      text: context.read<CardIssuanceCubit>().state.draft.recipient.name,
    );
    national = TextEditingController(
      text: context.read<CardIssuanceCubit>().state.draft.recipient.nationalId,
    );
    mobile = TextEditingController(
      text: context.read<CardIssuanceCubit>().state.draft.recipient.mobile,
    );
    agentName = TextEditingController(
      text: context.read<CardIssuanceCubit>().state.draft.agent.name,
    );
    agentCode = TextEditingController(
      text: context.read<CardIssuanceCubit>().state.draft.agent.code,
    );
  }

  @override
  void dispose() {
    name.dispose();
    national.dispose();
    mobile.dispose();
    agentName.dispose();
    agentCode.dispose();
    super.dispose();
  }

  void _recipient(String _) => context.read<CardIssuanceCubit>().setRecipient(
    DeliveryPerson(
      name: name.text,
      nationalId: national.text,
      mobile: mobile.text,
    ),
  );
  void _agent(String _) => context.read<CardIssuanceCubit>().setAgent(
    BankAgent(name: agentName.text, code: agentCode.text),
  );
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CardIssuanceCubit, CardIssuanceState>(
      buildWhen: (previous, current) =>
          previous.catalog != current.catalog ||
          previous.draft != current.draft ||
          previous.address != current.address,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IssuanceSelect<String>(
              hintColor: context.colors.textDisabled,
              options: [
                for (final a in state.catalog!.addresses)
                  AppSelectOption(value: a.id, label: a.title),
              ],
              value: state.draft.addressId,
              label: state.address == null
                  ? S.current.issuanceAddress
                  : S.current.issuanceSelectAddress,
              hint: S.current.issuanceAddressHint,
              onChanged: (v) {
                if (v != null) {
                  context.read<CardIssuanceCubit>().selectAddress(v);
                }
              },
            ),
            const SizedBox(height: 12),
            if (state.address != null)
              AppAddressCard(
                variant: AppAddressCardVariant.delivery,
                deleteLabel: S.current.issuanceDeleteAddress,
                address: state.address!.detail,
                onDeleteTap: () => widget.onDeleteAddress(state.address!),
              )
            else
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: SizedBox(
                  width: 139,
                  height: 20,
                  child: AppButton(
                    size: AppButtonSize.sm,
                    variant: AppButtonVariant.text,
                    horizontalPadding: 0,
                    foregroundColor: context.colors.primary,
                    label: S.current.issuanceAddAddress,
                    labelStyle: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 18 / 12,
                      letterSpacing: 0,
                    ),
                    contentGap: 8,
                    constrainLabel: true,
                    leadingIcon: issuanceIcon(AppAssets.issuancePlus),
                    onPressed: widget.onAddAddress,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const IssuanceDivider(),
            const SizedBox(height: 20),
            IssuanceToggleRow(
              label: S.current.issuanceOtherRecipient,
              value: state.draft.otherRecipient,
              onChanged: context.read<CardIssuanceCubit>().setOtherRecipient,
            ),
            if (state.draft.otherRecipient) ...[
              const SizedBox(height: 16),
              AppTextField(
                controller: name,
                label: S.current.issuanceRecipientName,
                onChanged: _recipient,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: national,
                label: S.current.issuanceNationalId,
                keyboardType: TextInputType.number,
                normalizeDigits: true,
                onChanged: _recipient,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: mobile,
                label: S.current.issuanceRecipientMobile,
                keyboardType: TextInputType.phone,
                normalizeDigits: true,
                onChanged: _recipient,
              ),
            ],
            const SizedBox(height: 20),
            const IssuanceDivider(),
            const SizedBox(height: 20),
            IssuanceToggleRow(
              label: S.current.issuanceIncludeAgent,
              value: state.draft.includeAgent,
              onChanged: context.read<CardIssuanceCubit>().setIncludeAgent,
            ),
            if (state.draft.includeAgent) ...[
              const SizedBox(height: 16),
              AppTextField(
                controller: agentName,
                label: S.current.issuanceAgentName,
                onChanged: _agent,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: agentCode,
                label: S.current.issuanceAgentCode,
                normalizeDigits: true,
                onChanged: _agent,
              ),
            ],
          ],
        );
      },
    );
  }
}
