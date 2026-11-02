import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class LoginCaptcha extends Equatable {
  LoginCaptcha(List<int> bytes, {required this.sessionId})
    : bytes = Uint8List.fromList(bytes).asUnmodifiableView();

  final Uint8List bytes;
  final String sessionId;

  @override
  bool get stringify => false;

  @override
  List<Object?> get props => [bytes, sessionId];
}
