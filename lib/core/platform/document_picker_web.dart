import 'dart:async';
import 'dart:js_interop';

import 'selected_document.dart';

@JS('document.createElement')
external _FileInput _createElement(String tag);

@JS()
extension type _FileInput(JSObject _) implements JSObject {
  external set type(String value);
  external set accept(String value);
  external set onchange(JSFunction? callback);
  external set oncancel(JSFunction? callback);
  external _Files? get files;
  external void click();
  external void remove();
}

@JS()
extension type _Files(JSObject _) implements JSObject {
  external _File? item(int index);
}

@JS()
extension type _File(JSObject _) implements JSObject {
  external String get name;
  external int get size;
  external JSPromise<JSArrayBuffer> arrayBuffer();
}

abstract final class DocumentPicker {
  static Future<SelectedDocument?> pickSpreadsheet() {
    final completer = Completer<SelectedDocument?>();
    final input = _createElement('input');
    input.type = 'file';
    input.accept = '.xls,application/vnd.ms-excel';
    void finish(SelectedDocument? file) {
      input.onchange = null;
      input.oncancel = null;
      input.remove();
      completer.complete(file);
    }

    input.oncancel = (() => finish(null)).toJS;
    input.onchange = (() {
      final file = input.files?.item(0);
      if (file == null) {
        finish(null);
      } else if (file.size > 102400) {
        input.remove();
        completer.completeError(StateError('file-too-large'));
      } else {
        file.arrayBuffer().toDart.then(
          (buffer) {
            finish(
              SelectedDocument(
                name: file.name,
                bytes: buffer.toDart.asUint8List(),
              ),
            );
          },
          onError: (Object error, StackTrace stack) {
            input.remove();
            completer.completeError(error, stack);
          },
        );
      }
    }).toJS;
    input.click();
    return completer.future;
  }
}
