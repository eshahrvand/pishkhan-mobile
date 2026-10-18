import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pishkhan_mobile/features/cards/presentation/password_services/cubit/second_password_cubit.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/widgets/password_styles.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

class PasswordSerialForm extends StatefulWidget {
  const PasswordSerialForm({super.key, required this.state});
  final SecondPasswordState state;
  @override
  State<PasswordSerialForm> createState() => _SerialFormState();
}

class _SerialFormState extends State<PasswordSerialForm> {
  late final TextEditingController controller;
  final focus = FocusNode();
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.state.nationalCardSerial);
    focus.addListener(() {
      if (!focus.hasFocus && mounted) {
        context.read<SecondPasswordCubit>().validateSerial();
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          S.current.passwordSerialPrompt,
          style: passwordBody(context).copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        AppTextField(
          controller: controller,
          focusNode: focus,
          hintText: S.current.passwordSerialHint,
          errorText: widget.state.isSerialError
              ? S.current.passwordSerialError
              : null,
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
            context.read<SecondPasswordCubit>().updateNationalCardSerial(v);
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
