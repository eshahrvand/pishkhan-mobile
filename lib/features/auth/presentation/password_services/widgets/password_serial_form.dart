import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:pishkhan_mobile/features/auth/presentation/password_services/cubit/second_password_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/widgets/password_styles.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

class PasswordSerialForm extends StatefulWidget {
  const PasswordSerialForm({super.key});
  @override
  State<PasswordSerialForm> createState() => _SerialFormState();
}

class _SerialFormState extends State<PasswordSerialForm> {
  late final TextEditingController controller;
  final focus = FocusNode();
  bool error = false;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
      text: context.read<SecondPasswordCubit>().state.serial,
    );
    focus.addListener(() {
      if (!focus.hasFocus && mounted) {
        setState(
          () => error =
              controller.text.isNotEmpty &&
              !context.read<SecondPasswordCubit>().state.serialComplete,
        );
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        context.l10n.passwordSerialPrompt,
        style: passwordBody(context).copyWith(fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 20),
      AppTextField(
        controller: controller,
        focusNode: focus,
        hintText: context.l10n.passwordSerialHint,
        errorText: error ? context.l10n.passwordSerialError : null,
        textStyle: passwordBody(context),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
        normalizeDigits: true,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
          LengthLimitingTextInputFormatter(20),
        ],
        focusRing: AppTextFieldFocusRing.none,
        autocorrect: false,
        enableSuggestions: false,
        enableIMEPersonalizedLearning: false,
        onChanged: (v) {
          setState(() => error = false);
          context.read<SecondPasswordCubit>().serialChanged(v);
        },
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          SizedBox.square(
            dimension: 14,
            child: SvgPicture.asset(AppAssets.passwordInfo),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.passwordSerialHelper,
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
