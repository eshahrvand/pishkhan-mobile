import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import '../../domain/entities/login_captcha.dart';

Future<LoginCaptcha> mapLoginCaptcha(String response, String? sessionId) async {
  if (sessionId == null || sessionId.trim().isEmpty) {
    throw const FormatException('Missing CAPTCHA SessionId header');
  }
  // The bank wraps its MIME Base64 with CRLF every 76 characters.
  var bytes = base64Decode(response.replaceAll(RegExp(r'\s+'), ''));
  // Accept one additional Base64 text layer, never decode image bytes again.
  if (!_isJpeg(bytes) && !_isPng(bytes)) {
    bytes = base64Decode(utf8.decode(bytes).replaceAll(RegExp(r'\s+'), ''));
  }
  if (!_isJpeg(bytes) && !_isPng(bytes)) {
    throw const FormatException('Invalid CAPTCHA image');
  }
  // Observed bank responses sometimes omit the final JPEG marker byte(s).
  // Restore only EOI; the image must still pass the real codec below.
  if (_isJpeg(bytes) &&
      !(bytes[bytes.length - 2] == 0xff && bytes.last == 0xd9)) {
    bytes = Uint8List.fromList([...bytes, if (bytes.last != 0xff) 0xff, 0xd9]);
  }
  try {
    final codec = await ui.instantiateImageCodec(bytes);
    try {
      final frame = await codec.getNextFrame();
      frame.image.dispose();
    } finally {
      codec.dispose();
    }
  } catch (_) {
    throw const FormatException('Invalid CAPTCHA image');
  }
  return LoginCaptcha(bytes, sessionId: sessionId);
}

bool _isJpeg(List<int> bytes) {
  return bytes.length >= 3 &&
      bytes[0] == 0xff &&
      bytes[1] == 0xd8 &&
      bytes[2] == 0xff;
}

bool _isPng(List<int> bytes) {
  return bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4e &&
      bytes[3] == 0x47 &&
      bytes[4] == 0x0d &&
      bytes[5] == 0x0a &&
      bytes[6] == 0x1a &&
      bytes[7] == 0x0a;
}
