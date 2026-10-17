import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pishkhan_mobile/features/auth/presentation/login/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

class AuthOtpTimer extends StatelessWidget {
  const AuthOtpTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) =>
          previous.secondsRemaining != current.secondsRemaining,
      builder: (context, state) => SizedBox(
        height: 44,
        child: AppButton(
          onPressed: state.secondsRemaining == 0
              ? context.read<AuthCubit>().resendOtp
              : () {},
          label: state.secondsRemaining == 0
              ? S.current.resendOtp
              : getOtpRemainingTime(state.secondsRemaining),
          trailingIcon: AvpImage(
            image: AuthAssets.clock,
            width: 20,
            height: 20,
          ),
          variant: AppButtonVariant.text,
          size: AppButtonSize.lg,
          horizontalPadding: 4,
        ),
      ),
    );
  }
}

String getOtpRemainingTime(int secondsRemaining) {
  return '${(secondsRemaining ~/ 60).toString().padLeft(2, '0')}:'
      '${(secondsRemaining % 60).toString().padLeft(2, '0')}';
}
