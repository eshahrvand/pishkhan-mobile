import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// One editable code with five visual slots. Paste, deletion, selection and
/// accessibility remain owned by one design-system text input.
class LoanOtpDigits extends StatefulWidget {
  const LoanOtpDigits({
    super.key,
    required this.value,
    required this.length,
    required this.enabled,
    required this.onChanged,
    required this.label,
  });
  final String value;
  final int length;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final String label;
  @override
  State<LoanOtpDigits> createState() {
    return _LoanOtpDigitsState();
  }
}

class _LoanOtpDigitsState extends State<LoanOtpDigits> {
  final _focus = FocusNode();
  @override
  void initState() {
    super.initState();
    // The modal input must be attached before requesting keyboard focus.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      child: SizedBox(
        height: 56,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: 0,
              alwaysIncludeSemantics: true,
              child: AppTextField(
                value: widget.value,
                focusNode: _focus,
                normalizeDigits: true,
                maxLength: widget.length,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textDirection: TextDirection.ltr,
                enabled: widget.enabled,
                autocorrect: false,
                enableSuggestions: false,
                enableIMEPersonalizedLearning: false,
                onChanged: widget.onChanged,
              ),
            ),
            IgnorePointer(
              child: ExcludeSemantics(
                child: Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    for (var index = 0; index < widget.length; index++) ...[
                      if (index > 0) const SizedBox(width: 14),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: context.colors.surface,
                            borderRadius: AppRadius.borderSm,
                            border: Border.all(color: context.colors.border),
                            boxShadow: AppShadows.xs,
                          ),
                          child: Text(
                            widget.value.length > index
                                ? widget.value[index]
                                : '',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w500,
                              color: context.colors.textPrimary,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
