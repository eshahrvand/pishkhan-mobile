import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pishkhan_mobile/features/auth/presentation/login/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/widgets/auth_form_shared.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

class AuthCaptchaRow extends StatelessWidget {
  const AuthCaptchaRow({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: BlocBuilder<AuthCubit, AuthState>(
            buildWhen: (previous, current) =>
                previous.captcha != current.captcha ||
                previous.isCaptchaError != current.isCaptchaError,
            builder: (context, state) => AppTextField(
              value: state.captcha,
              hintText: S.current.captchaHint,
              errorText: state.isCaptchaError
                  ? S.current.authInvalidCaptcha
                  : null,
              suffixIcon: AuthFieldIcon(
                AuthAssets.refresh,
                semanticLabel: S.current.refreshCaptcha,
                onPressed: cubit.refreshCaptcha,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.start,
              textStyle: Theme.of(context).textTheme.bodyMedium!
                  .copyWith(height: 20 / 14, letterSpacing: 0),
              normalizeDigits: true,
              focusRing: AppTextFieldFocusRing.subtle,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 6,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onChanged: cubit.updateCaptcha,
              onFocusLost: () => cubit.validateCaptcha(),
              onSubmitted: (_) => cubit.requestOtp(),
            ),
          ),
        ),
        const SizedBox(width: 7),
        SizedBox(
          width: 148,
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border.all(color: context.colors.border),
              borderRadius: AppRadius.borderSm,
              boxShadow: AppShadows.xs,
            ),
            child: AvpImage(
              image: AuthAssets.captcha,
              width: 100,
              height: 34,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}
