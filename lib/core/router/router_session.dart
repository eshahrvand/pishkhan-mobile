import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Prototype session only. This marker never represents bank authentication.
class RouterSession extends ChangeNotifier {
  RouterSession([this._authenticated = false]) : _preferences = null;

  RouterSession._remembered(SharedPreferences preferences)
    : _preferences = preferences,
      _authenticated = preferences.getBool(_prototypeLoginKey) ?? false;

  static const _prototypeLoginKey = 'prototype.authenticated.v1';
  final SharedPreferences? _preferences;

  /// Only the app startup uses disk persistence; isolated router scopes stay
  /// in memory. Replace this marker when the bank login adapter is connected.
  static Future<RouterSession> restorePrototype() async {
    return RouterSession._remembered(await SharedPreferences.getInstance());
  }

  bool _authenticated;
  Object? pendingExtra;
  bool get isAuthenticated => _authenticated;
  Future<void> signIn() async {
    if (_preferences != null) {
      await _preferences.setBool(_prototypeLoginKey, true);
    }
    _authenticated = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    _authenticated = false;
    pendingExtra = null;
    notifyListeners();
    await _preferences?.remove(_prototypeLoginKey);
  }

  Object? takePendingExtra() {
    final extra = pendingExtra;
    pendingExtra = null;
    return extra;
  }
}
