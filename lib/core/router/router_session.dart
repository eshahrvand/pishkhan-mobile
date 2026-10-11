import 'package:flutter/foundation.dart';

/// In-memory prototype session; a bank authentication adapter can replace it.
class RouterSession extends ChangeNotifier {
  RouterSession([this._authenticated = false]);
  bool _authenticated;
  Object? pendingExtra;
  bool get isAuthenticated => _authenticated;
  void signIn() {
    _authenticated = true;
    notifyListeners();
  }

  void signOut() {
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
