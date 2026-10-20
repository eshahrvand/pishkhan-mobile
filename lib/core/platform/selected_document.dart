import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// Memory-only selection; never persist or log banking document contents.
class SelectedDocument extends Equatable {
  SelectedDocument({required this.name, required Uint8List bytes})
    : bytes = Uint8List.fromList(bytes).asUnmodifiableView();
  final String name;
  final Uint8List bytes;
  @override
  bool get stringify => false;
  @override
  List<Object?> get props => [name, bytes];
}
