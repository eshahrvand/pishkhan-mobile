import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../cubit/transfer_limits_cubit.dart';
import 'mobile_bank_limit_field.dart';

class MobileBankLimitsForm extends StatelessWidget {
  const MobileBankLimitsForm({super.key, required this.state});
  final TransferLimitsState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          state.isEditing
              ? S.current.modernLimitsEditIntro
              : S.current.modernLimitsIntro,
          style: Theme.of(context).textTheme.bodyMedium!
              .copyWith(height: 20 / 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 24),
        MobileBankLimitField(
          label: S.current.modernInternal,
          value: state.internalAmount,
          currentAmount: state.catalog!.limits.internalRial,
          toman: state.internalToman,
          maximum: state.catalog!.maximumLimits.internalRial,
          isEditing: state.isEditing,
          isError: state.isInternalError,
          enabled: state.submissionStatus != RequestStatus.loading,
          onChanged: (value) {
            context.read<TransferLimitsCubit>().updateInternalAmount(value);
          },
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 1,
          child: AvpImage(image: AppAssets.modernDivider, fit: BoxFit.fill),
        ),
        const SizedBox(height: 20),
        MobileBankLimitField(
          label: S.current.modernPaya,
          value: state.payaAmount,
          currentAmount: state.catalog!.limits.payaRial,
          toman: state.payaToman,
          maximum: state.catalog!.maximumLimits.payaRial,
          isEditing: state.isEditing,
          isError: state.isPayaError,
          enabled: state.submissionStatus != RequestStatus.loading,
          onChanged: (value) {
            context.read<TransferLimitsCubit>().updatePayaAmount(value);
          },
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 1,
          child: AvpImage(image: AppAssets.modernDivider, fit: BoxFit.fill),
        ),
        const SizedBox(height: 20),
        MobileBankLimitField(
          label: S.current.modernSatna,
          value: state.satnaAmount,
          currentAmount: state.catalog!.limits.satnaRial,
          toman: state.satnaToman,
          maximum: state.catalog!.maximumLimits.satnaRial,
          isEditing: state.isEditing,
          isError: state.isSatnaError,
          enabled: state.submissionStatus != RequestStatus.loading,
          onChanged: (value) {
            context.read<TransferLimitsCubit>().updateSatnaAmount(value);
          },
        ),
      ],
    );
  }
}
