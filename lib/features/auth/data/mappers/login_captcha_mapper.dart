import 'dart:convert';

import '../../domain/entities/login_captcha.dart';

LoginCaptcha mapLoginCaptcha(String response, String? sessionId) {
  if (sessionId == null || sessionId.trim().isEmpty) {
    throw const FormatException('Missing CAPTCHA SessionId header');
  }
  // The bank wraps its MIME Base64 with CRLF every 76 characters.
  final bytes = base64Decode(response.replaceAll(RegExp(r'\s+'), ''));
  // Reject a gateway page or malformed payload instead of displaying it as CAPTCHA.
  final jpeg =
      bytes.length >= 3 &&
      bytes[0] == 0xff &&
      bytes[1] == 0xd8 &&
      bytes[2] == 0xff;
  final png =
      bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4e &&
      bytes[3] == 0x47 &&
      bytes[4] == 0x0d &&
      bytes[5] == 0x0a &&
      bytes[6] == 0x1a &&
      bytes[7] == 0x0a;
  if (!jpeg && !png) throw const FormatException('Invalid CAPTCHA image');
  return LoginCaptcha(bytes, sessionId: sessionId);
}
