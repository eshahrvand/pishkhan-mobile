import 'auth_otp_timer.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pishkhan_mobile/features/auth/presentation/login/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/widgets/auth_form_shared.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

class AuthOtpForm extends StatelessWidget {
  const AuthOtpForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (previous, current) =>
              previous.maskedPhone != current.maskedPhone,
          builder: (context, state) => AuthSectionHeading(
            title: S.current.otpSentTitle,
            description: S.current.otpSentMessage(
              '\u2066${state.maskedPhone}\u2069',
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BlocBuilder<AuthCubit, AuthState>(
                buildWhen: (previous, current) => previous.otp != current.otp,
                builder: (context, state) => AppTextField(
                  value: state.otp,
                  hintText: S.current.otpHint,
                  prefixIcon: const AuthFieldIcon(AuthAssets.lock),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.start,
                  textStyle: Theme.of(context).textTheme.bodyMedium!
                      .copyWith(height: 20 / 14, letterSpacing: 0),
                  normalizeDigits: true,
                  focusRing: AppTextFieldFocusRing.subtle,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onChanged: context.read<AuthCubit>().updateOtp,
                  onSubmitted: (_) => context.read<AuthCubit>().submitOtp(),
                ),
              ),
            ),
            const SizedBox(width: 7),
            const SizedBox(width: 148, child: AuthOtpTimer()),
          ],
        ),
        const SizedBox(height: 24),
        BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (previous, current) =>
              previous.otpValid != current.otpValid,
          builder: (context, state) => AppButton(
            onPressed: state.otpValid
                ? context.read<AuthCubit>().submitOtp
                : null,
            label: S.current.enterDashboard,
            size: AppButtonSize.lg,
          ),
        ),
      ],
    );
  }
}
