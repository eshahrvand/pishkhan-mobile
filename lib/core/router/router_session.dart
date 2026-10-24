import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/network/access_token_store.dart';

/// Android may resume a saved token; its server validity is not checked yet.
class RouterSession extends ChangeNotifier {
  /// Isolated router scope; also used by navigation tests.
  RouterSession([this._authenticated = false]) : _tokens = null;

  RouterSession.managed()
    : _authenticated = false,
      _tokens = getIt<AccessTokenStore>();

  final AccessTokenStore? _tokens;

  /// Restore Android credentials; the obsolete prototype marker is never trusted.
  static Future<RouterSession> restore() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('prototype.authenticated.v1');
    final session = RouterSession.managed();
    await session._tokens!.restore();
    session._authenticated = session._tokens.accessToken != null;
    return session;
  }

  bool _authenticated;
  Object? pendingExtra;
  bool get isAuthenticated => _authenticated;

  Future<void> signIn() async {
    if (_tokens != null && _tokens.accessToken == null) {
      throw StateError('No bank login token is available');
    }
    _authenticated = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _tokens?.clear();
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
