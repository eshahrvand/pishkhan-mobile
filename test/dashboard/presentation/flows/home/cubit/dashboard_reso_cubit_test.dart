import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/cubit/dashboard_reso_cubit.dart';

void main() {
  test('prompt eligibility and normalized submission are owned by Cubit', () {
    final cubit = DashboardResoCubit();
    addTearDown(cubit.close);

    expect(cubit.submitPrompt(), isNull);
    cubit.updatePrompt('   ');
    expect(cubit.state.prompt, '   ');
    expect(cubit.state.hasInput, isTrue);
    expect(cubit.state.canSubmitPrompt, isFalse);
    expect(cubit.submitPrompt(), isNull);
    cubit.updatePrompt('  سوال من  ');
    expect(cubit.state.canSubmitPrompt, isTrue);
    expect(cubit.submitPrompt(), 'سوال من');
    expect(cubit.state.prompt, '  سوال من  ');
    cubit.updatePrompt('');
    expect(cubit.state.hasInput, isFalse);
    expect(cubit.state.canSubmitPrompt, isFalse);
  });

  test('typing pauses for input and focus and stops after disposal', () async {
    final cubit = DashboardResoCubit()..configurePhrases(['Example']);
    cubit.updateMotion(enabled: true, hasFocus: false);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(cubit.state.typedHint, isNotEmpty);
    cubit.updatePrompt('question');
    final pausedHint = cubit.state.typedHint;
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(cubit.state.typedHint, pausedHint);
    cubit.updatePrompt('');
    cubit.updateMotion(enabled: true, hasFocus: true);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(cubit.state.typedHint, pausedHint);
    await cubit.close();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(cubit.state.typedHint, pausedHint);
  });
}
