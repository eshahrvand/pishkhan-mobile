import 'package:flutter/material.dart';

TextStyle getInvoiceTextStyle(
  TextStyle base, {
  required Color color,
  FontWeight fontWeight = FontWeight.w400,
  double height = 18 / 12,
}) => base.copyWith(
  color: color,
  fontWeight: fontWeight,
  height: height,
  letterSpacing: 0,
);
