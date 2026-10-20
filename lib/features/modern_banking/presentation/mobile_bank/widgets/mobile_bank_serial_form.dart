import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../cubit/mobile_bank_cubit.dart';

class MobileBankSerialForm extends StatelessWidget {
  const MobileBankSerialForm({super.key, required this.state});
  final MobileBankState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          S.current.passwordSerialPrompt,
          style: Theme.of(context).textTheme.bodyMedium!
              .copyWith(height: 20 / 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        AppTextField(
          enabled: state.submissionStatus != RequestStatus.loading,
          value: state.nationalCardSerial,
          hintText: S.current.passwordSerialHint,
          errorText: state.isSerialError ? S.current.passwordSerialError : null,
          textStyle: Theme.of(context).textTheme.bodyMedium,
          textDirection: TextDirection.ltr,
          hintTextDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          normalizeDigits: true,
          maxLength: 20,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
          ],
          focusRing: AppTextFieldFocusRing.none,
          autocorrect: false,
          enableSuggestions: false,
          enableIMEPersonalizedLearning: false,
          onChanged: (value) {
            context.read<MobileBankCubit>().updateNationalCardSerial(value);
          },
          onFocusLost: () {
            context.read<MobileBankCubit>().validateSerial();
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox.square(
              dimension: 14,
              child: AvpImage(image: AppAssets.passwordInfo),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                S.current.passwordSerialHelper,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: context.colors.textSecondary,
                  height: 18 / 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
