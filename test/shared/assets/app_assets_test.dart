import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AppAssets contains unique paths', () {
    expect(AppAssets.all.toSet(), hasLength(AppAssets.all.length));
  });

  test('every registered image asset is bundled and non-empty', () async {
    for (final path in AppAssets.all) {
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(0), reason: path);
    }
  });
}
