import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:pishkhan_mobile/features/auth/presentation/password_services/cubit/password_rules.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/cubit/second_password_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/widgets/password_styles.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

class SecondPasswordForm extends StatefulWidget {
  const SecondPasswordForm({super.key});
  @override
  State<SecondPasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<SecondPasswordForm> {
  late final TextEditingController password, confirmation, currentPassword;
  final focus = FocusNode();
  bool showPassword = false,
      showConfirmation = false,
      showCurrent = false,
      mismatch = false;
  @override
  void initState() {
    super.initState();
    final state = context.read<SecondPasswordCubit>().state;
    currentPassword = TextEditingController(text: state.currentPassword);
    password = TextEditingController(text: state.password);
    confirmation = TextEditingController(text: state.confirmation);
    focus.addListener(() {
      if (!focus.hasFocus && mounted) {
        setState(
          () => mismatch =
              confirmation.text.isNotEmpty &&
              password.text != confirmation.text,
        );
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
    final c = context.read<SecondPasswordCubit>(), l = context.l10n;
    final change = passwordIsChange(c.state);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          change ? l.passwordChangePrompt : l.passwordPrompt,
          style: passwordBody(context).copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        if (change) ...[
          PasswordPinField(
            controller: currentPassword,
            hintText: l.passwordCurrentHint,
            visible: showCurrent,

            onVisibilityChanged: () =>
                setState(() => showCurrent = !showCurrent),
            onChanged: (value) {
              setState(() => mismatch = false);
              c.currentPasswordChanged(value);
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
          hintText: change ? l.passwordNewHint : l.passwordValueHint,
          visible: showPassword,

          onVisibilityChanged: () =>
              setState(() => showPassword = !showPassword),
          onChanged: (value) {
            setState(() => mismatch = false);
            c.passwordChanged(value);
          },
        ),
        const SizedBox(height: 20),
        PasswordPinField(
          controller: confirmation,
          hintText: change
              ? l.passwordNewConfirmationHint
              : l.passwordConfirmationHint,
          visible: showConfirmation,
          focusNode: focus,
          errorText: mismatch ? l.passwordMismatch : null,
          onVisibilityChanged: () =>
              setState(() => showConfirmation = !showConfirmation),
          onChanged: (value) {
            setState(() => mismatch = false);
            c.confirmationChanged(value);
          },
        ),
        const SizedBox(height: 20),
        const PasswordRules(),
      ],
    );
  }
}

class PasswordPinField extends StatelessWidget {
  const PasswordPinField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.visible,
    required this.onVisibilityChanged,
    required this.onChanged,
    this.focusNode,
    this.errorText,
  });
  final TextEditingController controller;
  final String hintText;
  final bool visible;
  final VoidCallback onVisibilityChanged;
  final ValueChanged<String> onChanged;
  final FocusNode? focusNode;
  final String? errorText;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppTextField(
      controller: controller,
      focusNode: focusNode,
      hintText: hintText,
      obscureText: !visible,
      obscuringCharacter: '*',
      autocorrect: false,
      enableSuggestions: false,
      enableIMEPersonalizedLearning: false,
      keyboardType: TextInputType.number,
      normalizeDigits: true,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      focusRing: AppTextFieldFocusRing.none,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
      textStyle: passwordBody(context),
      errorText: errorText,
      suffixIcon: AppButton(
        variant: AppButtonVariant.text,
        size: AppButtonSize.lg,
        tooltip: visible ? l.passwordHide : l.passwordShow,
        onPressed: onVisibilityChanged,
        icon: SizedBox.square(
          dimension: 20,
          child: visible
              ? SvgPicture.asset(AppAssets.resalatCardEye)
              : SvgPicture.asset(AppAssets.passwordEyeSlash),
        ),
      ),
      onChanged: onChanged,
    );
  }
}

class PasswordRules extends StatelessWidget {
  const PasswordRules({super.key});
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BlocBuilder<SecondPasswordCubit, SecondPasswordState>(
      buildWhen: (previous, state) =>
          previous.password != state.password ||
          previous.cardId != state.cardId ||
          previous.catalog != state.catalog,
      builder: (context, state) => Column(
        children: [
          for (final rule in [
            (l.passwordLengthRule, passwordLengthValid(state)),
            (l.passwordPatternRule, passwordPatternValid(state)),
            (l.passwordDateRule, passwordDateValid(state)),
          ]) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox.square(
                  dimension: 20,
                  child: SvgPicture.asset(
                    rule.$2
                        ? AppAssets.passwordCheckActive
                        : AppAssets.passwordCheckInactive,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rule.$1,
                    style: passwordBody(context).copyWith(
                      color: rule.$2
                          ? context.colors.textSecondary
                          : AppPasswordServiceColors.hint,
                    ),
                  ),
                ),
              ],
            ),
            if (rule.$1 != l.passwordDateRule) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
