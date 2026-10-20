import 'package:flutter/services.dart';

import 'selected_document.dart';

abstract final class DocumentPicker {
  static const _channel = MethodChannel('pishkhan/document_picker');
  static Future<SelectedDocument?> pickSpreadsheet() async {
    final file = await _channel.invokeMapMethod<String, Object?>(
      'pickSpreadsheet',
    );
    return file == null
        ? null
        : SelectedDocument(
            name: file['name']! as String,
            bytes: file['bytes']! as Uint8List,
          );
  }
}
