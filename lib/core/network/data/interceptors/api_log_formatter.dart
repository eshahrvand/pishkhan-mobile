import 'dart:convert';

import 'package:dio/dio.dart';

/// Formats complete Debug diagnostics without changing transport payloads.
abstract final class ApiLogFormatter {
  static String headers(Map<String, dynamic> headers) => _format(headers);

  static String body(Object? value) {
    if (value is String) return value;
    if (value is FormData) {
      return _format({
        'fields': [
          for (final field in value.fields)
            {'name': field.key, 'value': field.value},
        ],
        'files': [
          for (final file in value.files)
            {
              'field': file.key,
              'filename': file.value.filename,
              'length': file.value.length,
              'contentType': file.value.contentType?.toString(),
            },
        ],
      });
    }
    // Streaming payloads must remain available to their actual consumer.
    if (value is Stream || value is ResponseBody) {
      return '[stream body: not buffered by logger]';
    }
    return _format(value);
  }

  static String _format(Object? value) {
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } on JsonUnsupportedObjectError {
      return value.toString();
    }
  }
}
