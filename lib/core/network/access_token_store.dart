/// Access tokens stay in memory on every platform. No refresh endpoint exists yet.
class AccessTokenStore {
  String? _accessToken;

  String? get accessToken => _accessToken;

  void replace(String token) => _accessToken = token;

  void clear() => _accessToken = null;
}
