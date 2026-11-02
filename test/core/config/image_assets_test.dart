import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'image paths used by application code are bundled and non-empty',
    () async {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final bundled = manifest.listAssets().toSet();
      final references = <String>{};
      final imagePath = RegExp(
        r'''\$\{AppConstants\.baseImage\}([^'"\r\n]+)''',
      );
      for (final file in Directory(
        'lib',
      ).listSync(recursive: true).whereType<File>()) {
        if (!file.path.endsWith('.dart') ||
            file.path.endsWith('.freezed.dart')) {
          continue;
        }
        for (final match in imagePath.allMatches(file.readAsStringSync())) {
          references.add('${AppConstants.baseImage}${match.group(1)}');
        }
      }
      expect(references, isNotEmpty);
      expect(bundled, containsAll(references));
      for (final path in references) {
        expect(
          (await rootBundle.load(path)).lengthInBytes,
          greaterThan(0),
          reason: path,
        );
      }
    },
  );
}
