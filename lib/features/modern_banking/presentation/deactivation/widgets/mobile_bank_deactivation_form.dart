import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../../../domain/entities/mobile_bank.dart';
import '../cubit/mobile_bank_deactivation_cubit.dart';

class MobileBankDeactivationForm extends StatelessWidget {
  const MobileBankDeactivationForm({super.key, required this.state});
  final MobileBankDeactivationState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          S.current.modernDeactivationIntro,
          style: Theme.of(context).textTheme.bodyMedium!
              .copyWith(fontWeight: FontWeight.w500, height: 20 / 14),
        ),
        const SizedBox(height: 30),
        AppTextField(
          label: S.current.modernUsername,
          value: state.catalog!.username,
          readOnly: true,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right,
          backgroundColor: context.colors.surfaceSubtle,
          textStyle: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 30),
        CertificateSelect<DeactivationReason>(
          label: S.current.modernReason,
          hint: S.current.modernReasonHint,
          value: state.reason,
          enabled: state.submissionStatus != RequestStatus.loading,
          options: state.catalog!.reasons
              .map(
                (reason) => AppSelectOption(
                  value: reason,
                  label: getDeactivationReasonTitle(reason.code),
                ),
              )
              .toList(),
          onChanged: (value) {
            context.read<MobileBankDeactivationCubit>().selectReason(value);
          },
        ),
      ],
    );
  }
}

String getDeactivationReasonTitle(String code) => switch (code) {
  'suspectedCompromise' => S.current.modernCompromised,
  _ => S.current.modernOtherReason,
};
