import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/network/access_token_store.dart';

/// Router state is memory-only. A saved prototype marker never authenticates a user.
class RouterSession extends ChangeNotifier {
  /// Isolated router scope; also used by navigation tests.
  RouterSession([this._authenticated = false]) : _tokens = null;

  RouterSession.managed()
    : _authenticated = false,
      _tokens = getIt<AccessTokenStore>();

  final AccessTokenStore? _tokens;

  /// Remove the obsolete prototype marker; no bank token is restored from disk.
  static Future<RouterSession> restore() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('prototype.authenticated.v1');
    return RouterSession.managed();
  }

  bool _authenticated;
  Object? pendingExtra;
  bool get isAuthenticated => _authenticated;

  Future<void> signIn() async {
    if (_tokens != null && _tokens.accessToken == null) {
      throw StateError('Bank authentication has not completed');
    }
    _authenticated = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    _tokens?.clear();
    _authenticated = false;
    pendingExtra = null;
    notifyListeners();
  }

  Object? takePendingExtra() {
    final extra = pendingExtra;
    pendingExtra = null;
    return extra;
  }
}
