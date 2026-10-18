import 'package:avp_ui/avp_ui.dart';

import 'password_pin_field.dart';
import 'password_rules.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pishkhan_mobile/features/cards/presentation/password_services/cubit/second_password_cubit.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/widgets/password_styles.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

class SecondPasswordForm extends StatefulWidget {
  const SecondPasswordForm({super.key, required this.state});
  final SecondPasswordState state;
  @override
  State<SecondPasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<SecondPasswordForm> {
  late final TextEditingController password, confirmation, currentPassword;
  final focus = FocusNode();
  @override
  void initState() {
    super.initState();
    final state = widget.state;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.state.isChange
              ? S.current.passwordChangePrompt
              : S.current.passwordPrompt,
          style: passwordBody(context).copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        if (widget.state.isChange) ...[
          PasswordPinField(
            controller: currentPassword,
            hintText: S.current.passwordCurrentHint,
            visible: widget.state.isCurrentPasswordVisible,

            onVisibilityChanged: () => context
                .read<SecondPasswordCubit>()
                .toggleCurrentPasswordVisibility(),
            onChanged: (value) {
              context.read<SecondPasswordCubit>().updateCurrentPassword(value);
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 0,
            child: OverflowBox(
              minHeight: 1,
              maxHeight: 1,
              child: AvpImage(
                image: AppAssets.issuanceDivider,
                fit: BoxFit.fill,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        PasswordPinField(
          controller: password,
          hintText: widget.state.isChange
              ? S.current.passwordNewHint
              : S.current.passwordValueHint,
          visible: widget.state.isPasswordVisible,

          onVisibilityChanged: () =>
              context.read<SecondPasswordCubit>().togglePasswordVisibility(),
          onChanged: (value) {
            context.read<SecondPasswordCubit>().updatePassword(value);
          },
        ),
        const SizedBox(height: 20),
        PasswordPinField(
          controller: confirmation,
          hintText: widget.state.isChange
              ? S.current.passwordNewConfirmationHint
              : S.current.passwordConfirmationHint,
          visible: widget.state.isConfirmationVisible,
          focusNode: focus,
          errorText: widget.state.isConfirmationError
              ? S.current.passwordMismatch
              : null,
          onVisibilityChanged: () => context
              .read<SecondPasswordCubit>()
              .toggleConfirmationVisibility(),
          onChanged: (value) {
            context.read<SecondPasswordCubit>().updateConfirmation(value);
          },
        ),
        const SizedBox(height: 20),
        PasswordRules(state: widget.state),
      ],
    );
  }
}
