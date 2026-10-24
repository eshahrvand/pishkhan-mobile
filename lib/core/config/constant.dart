/// Shared API addresses and network timeouts.
abstract final class AppConstants {
  static const bankBaseUrl = 'https://apii.rqbank.ir';

  static const connectTimeout = Duration(seconds: 15);
  static const sendTimeout = Duration(seconds: 20);
  static const receiveTimeout = Duration(seconds: 20);
}
