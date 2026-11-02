/// Shared asset prefix, API addresses and network timeouts.
abstract final class AppConstants {
  // Temporary owner-requested diagnostics, including Release test builds.
  // Disable with --dart-define=API_LOGS=false.
  static const apiLoggingEnabled = bool.fromEnvironment(
    'API_LOGS',
    defaultValue: true,
  );

  static const baseImage = 'assets/images/';
  static const bankBaseUrl = 'https://apii.rqbank.ir';

  static const connectTimeout = Duration(seconds: 15);
  static const sendTimeout = Duration(seconds: 20);
  static const receiveTimeout = Duration(seconds: 20);
}
