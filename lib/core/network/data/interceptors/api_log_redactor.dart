import 'dart:convert';

/// Diagnostic fields are allowlisted; identity, credentials and banking data
/// remain masked even when the backend introduces a new response field.
abstract final class ApiLogRedactor {
  static const _diagnosticFields = {
    'status',
    'statuscode',
    'code',
    'errorcode',
    'message',
    'error',
    'errors',
    'detail',
    'details',
    'title',
    'success',
    'timestamp',
  };

  static String url(Uri uri) => uri
      .replace(
        userInfo: '',
        pathSegments: uri.pathSegments.map(_text),
        queryParameters: uri.hasQuery
            ? {for (final key in uri.queryParameters.keys) key: '[REDACTED]'}
            : null,
        fragment: '',
      )
      .toString();

  static String body(Object? value) {
    if (value is String) {
      final text = value;
      try {
        value = jsonDecode(text);
      } on FormatException {
        return '[non-JSON response: ${text.length} characters]';
      }
    }
    if (value is List<int>) return '[binary response: ${value.length} bytes]';
    final text = const JsonEncoder.withIndent('  ').convert(_value(value));
    return text.length <= 6000
        ? text
        : '${text.substring(0, 6000)}\n[truncated]';
  }

  static Object? _value(Object? value) => switch (value) {
    Map() => {
      for (final entry in value.entries)
        _text(entry.key.toString()):
            _diagnosticFields.contains(
              entry.key.toString().toLowerCase().replaceAll(
                RegExp(r'[^a-z]'),
                '',
              ),
            )
            ? _value(entry.value)
            : '[REDACTED]',
    },
    List() => value.take(30).map(_value).toList(),
    String() => _text(value),
    num() || bool() || null => value,
    _ => '[REDACTED]',
  };

  static String _text(String value) => value
      .replaceAll(
        RegExp(r'Bearer\s+\S+', caseSensitive: false),
        'Bearer [REDACTED]',
      )
      .replaceAll(RegExp(r'[0-9۰-۹٠-٩]{6,}'), '[REDACTED]')
      .replaceAll(RegExp(r'[A-Za-z0-9!@#\$%&*._~+/=\-]{20,}'), '[REDACTED]')
      .replaceAll(RegExp(r'[^\s@]+@[^\s@]+\.[^\s@]+'), '[REDACTED]');
}
