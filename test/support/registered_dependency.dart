import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';

/// Installs a test dependency before the real Cubit constructor reads GetIt.
/// Each Cubit keeps its resolved instance, so later replacements are isolated.
R withRegisteredDependency<T extends Object, R>(
  T dependency,
  R Function() action,
) {
  addTearDown(() => getIt.reset());
  final previous = getIt.allowReassignment;
  getIt.allowReassignment = true;
  try {
    getIt.registerSingleton<T>(dependency);
    return action();
  } finally {
    getIt.allowReassignment = previous;
  }
}
