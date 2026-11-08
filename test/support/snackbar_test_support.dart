import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_test/flutter_test.dart';

/// Clears feedback without waiting for unrelated request/loading animations.
Future<void> dismissAvpSnackBar(WidgetTester tester) async {
  final notification = find.byType(AvpSnackBar);
  if (notification.evaluate().isEmpty) return;
  // Invoke the public close action directly: cleanup may happen mid-entrance,
  // while the animated notification is still outside the hit-test area.
  tester.widget<AvpSnackBar>(notification).onDismiss();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump();
}
