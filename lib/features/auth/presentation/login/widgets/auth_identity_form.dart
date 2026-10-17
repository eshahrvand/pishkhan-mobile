import 'auth_identity_fields.dart';
import 'auth_captcha_row.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/widgets/auth_form_shared.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

class AuthIdentityForm extends StatelessWidget {
  const AuthIdentityForm({required this.changePhone, super.key});
  final bool changePhone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthSectionHeading(
          title: changePhone
              ? S.current.changeMobileTitle
              : S.current.loginTitle,
          description: changePhone
              ? S.current.changeMobileDescription
              : S.current.loginDescription,
        ),
        const SizedBox(height: 32),
        AuthIdentityFields(changePhone: changePhone),
        const SizedBox(height: 24),
        const AuthCaptchaRow(),
        const SizedBox(height: 24),
        BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (previous, current) {
            return previous.formValid != current.formValid ||
                previous.status != current.status;
          },
          builder: (context, state) {
            return AppButton(
              label: S.current.requestOtp,
              size: AppButtonSize.md,
              isActive: state.formValid,
              isLoading: state.status == RequestStatus.loading,
              onPressed: context.read<AuthCubit>().requestOtp,
            );
          },
        ),
      ],
    );
  }
}
