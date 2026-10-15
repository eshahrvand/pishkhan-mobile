import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/issuance_data.dart';

Widget issuanceIcon(String path, {double size = 20}) => SizedBox(
  width: size,
  height: size,
  child: AvpImage(image: path, width: size, height: size),
);
TextStyle issuanceBody(BuildContext context, {bool medium = false}) =>
    AppTypography.bodyMedium.copyWith(
      color: context.colors.textPrimary,
      fontWeight: medium ? FontWeight.w500 : FontWeight.w400,
      height: 20 / 14,
      letterSpacing: 0,
    );
String issuanceTypeLabel(BuildContext context, IssuanceType value) =>
    switch (value) {
      IssuanceType.newNumber => S.current.issuanceNewNumber,
      IssuanceType.existingNumber => S.current.issuanceExistingNumber,
    };
