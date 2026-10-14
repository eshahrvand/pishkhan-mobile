import 'password_pin_field.dart';
import 'password_rules.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:pishkhan_mobile/features/auth/presentation/password_services/cubit/second_password_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/widgets/password_styles.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

class SecondPasswordForm extends StatefulWidget {
  const SecondPasswordForm({super.key});
  @override
  State<SecondPasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<SecondPasswordForm> {
  late final TextEditingController password, confirmation, currentPassword;
  final focus = FocusNode();
  @override
  void initState() {
    super.initState();
    context.read<SecondPasswordCubit>().resetPasswordFormPresentation();
    final state = context.read<SecondPasswordCubit>().state;
    currentPassword = TextEditingController(text: state.currentPassword);
    password = TextEditingController(text: state.password);
    confirmation = TextEditingController(text: state.confirmation);
    focus.addListener(() {
      if (!focus.hasFocus && mounted) {
        context.read<SecondPasswordCubit>().validateConfirmation();
      }
    });
  }

  @override
  void dispose() {
    currentPassword.dispose();
    password.dispose();
    confirmation.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SecondPasswordCubit, SecondPasswordState>(
      buildWhen: (previous, current) =>
          previous.isChange != current.isChange ||
          previous.showPassword != current.showPassword ||
          previous.showConfirmation != current.showConfirmation ||
          previous.showCurrentPassword != current.showCurrentPassword ||
          previous.isConfirmationError != current.isConfirmationError,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              state.isChange
                  ? S.current.passwordChangePrompt
                  : S.current.passwordPrompt,
              style: passwordBody(context)
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            if (state.isChange) ...[
              PasswordPinField(
                controller: currentPassword,
                hintText: S.current.passwordCurrentHint,
                visible: state.showCurrentPassword,

                onVisibilityChanged: () => context
                    .read<SecondPasswordCubit>()
                    .toggleCurrentPasswordVisibility(),
                onChanged: (value) {
                  context.read<SecondPasswordCubit>().currentPasswordChanged(
                    value,
                  );
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 0,
                child: OverflowBox(
                  minHeight: 1,
                  maxHeight: 1,
                  child: SvgPicture.asset(
                    AppAssets.issuanceDivider,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            PasswordPinField(
              controller: password,
              hintText: state.isChange
                  ? S.current.passwordNewHint
                  : S.current.passwordValueHint,
              visible: state.showPassword,

              onVisibilityChanged: () => context
                  .read<SecondPasswordCubit>()
                  .togglePasswordVisibility(),
              onChanged: (value) {
                context.read<SecondPasswordCubit>().passwordChanged(value);
              },
            ),
            const SizedBox(height: 20),
            PasswordPinField(
              controller: confirmation,
              hintText: state.isChange
                  ? S.current.passwordNewConfirmationHint
                  : S.current.passwordConfirmationHint,
              visible: state.showConfirmation,
              focusNode: focus,
              errorText: state.isConfirmationError
                  ? S.current.passwordMismatch
                  : null,
              onVisibilityChanged: () => context
                  .read<SecondPasswordCubit>()
                  .toggleConfirmationVisibility(),
              onChanged: (value) {
                context.read<SecondPasswordCubit>().confirmationChanged(value);
              },
            ),
            const SizedBox(height: 20),
            const PasswordRules(),
          ],
        );
      },
    );
  }
}
