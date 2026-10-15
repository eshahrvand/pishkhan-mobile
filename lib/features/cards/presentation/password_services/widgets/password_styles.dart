import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

TextStyle passwordBody(BuildContext context) => Theme.of(context)
    .textTheme
    .bodyMedium!
    .copyWith(
      height: 20 / 14,
      letterSpacing: 0,
      color: AppPasswordServiceColors.title,
    );
