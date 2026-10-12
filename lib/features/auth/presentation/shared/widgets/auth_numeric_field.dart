import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Controlled auth input; the Cubit owns normalized values and validation.
class AuthNumericField extends StatefulWidget {
  const AuthNumericField({
    required this.value,
    required this.hintText,
    required this.maxLength,
    required this.onChanged,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.number,
    this.textInputAction = TextInputAction.next,
    this.onFocusLost,
    this.onSubmitted,
    super.key,
  });

  final String value;
  final String hintText;
  final String? errorText;
  final int maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFocusLost;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AuthNumericField> createState() => _AuthNumericFieldState();
}

class _AuthNumericFieldState extends State<AuthNumericField> {
  late final _controller = TextEditingController(text: widget.value);
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_focusChanged);
  }

  void _focusChanged() {
    if (!_focusNode.hasFocus) widget.onFocusLost?.call();
  }

  @override
  void didUpdateWidget(covariant AuthNumericField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.value) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_focusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppTextField(
    controller: _controller,
    focusNode: _focusNode,
    hintText: widget.hintText,
    errorText: widget.errorText,
    prefixIcon: widget.prefixIcon,
    suffixIcon: widget.suffixIcon,
    keyboardType: widget.keyboardType,
    textInputAction: widget.textInputAction,
    textDirection: widget.value.isEmpty ? TextDirection.rtl : TextDirection.ltr,
    textAlign: widget.value.isEmpty ? TextAlign.start : TextAlign.end,
    textStyle: AppTypography.bodyMedium.copyWith(
      height: 20 / 14,
      letterSpacing: 0,
    ),
    normalizeDigits: true,
    focusRing: AppTextFieldFocusRing.subtle,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(widget.maxLength),
    ],
    onChanged: widget.onChanged,
    onSubmitted: widget.onSubmitted,
  );
}
