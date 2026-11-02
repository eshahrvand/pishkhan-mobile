import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Android persists only the final login token. Other platforms use memory.
/// Restoring a token does not verify its validity with the bank.
class AccessTokenStore {
  AccessTokenStore({this.storage});

  static const _tokenKey = 'auth.access_token.v1';
  final FlutterSecureStorage? storage;
  String? _accessToken;

  String? get accessToken => _accessToken;

  Future<void> restore() async {
    _accessToken = null;
    try {
      final token = await storage?.read(key: _tokenKey);
      if (token != null && token.trim().isNotEmpty) {
        _accessToken = token;
      }
    } on PlatformException {
      // Unreadable device storage requires login, never a fabricated session.
    }
  }

  Future<void> replace(String token) async {
    await storage?.write(key: _tokenKey, value: token);
    _accessToken = token;
  }

  Future<void> clear() async {
    await storage?.delete(key: _tokenKey);
    _accessToken = null;
  }
}

AccessTokenStore createAccessTokenStore() {
  return AccessTokenStore(
    storage: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? const FlutterSecureStorage()
        : null,
  );
}
