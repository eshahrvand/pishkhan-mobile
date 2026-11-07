import 'package:flutter/material.dart';

/// Keeps the fading backdrop stationary while the bottom-sheet panel slides.
class AppServiceSheetRoute<T> extends ModalBottomSheetRoute<T> {
  AppServiceSheetRoute({
    required super.builder,
    required super.modalBarrierColor,
    required super.barrierLabel,
    required super.capturedThemes,
    super.enableDrag = false,
  }) : super(isScrollControlled: true, backgroundColor: Colors.transparent);
}
