import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/repositories/dashboard_repositories.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/home_cubit.dart';

import '../../../../../support/registered_dependency.dart';
import '../../../../support/dashboard_test_repositories.dart';

HomeCubit createHome() {
  final cubit = withRegisteredDependency<DashboardRepositories, HomeCubit>(
    homeRepositories(),
    () => HomeCubit(),
  );
  return cubit;
}

void main() {
  test(
    'typing pauses for input and focus and owned timer stops on disposal',
    () async {
      final cubit = createHome()..updateHintPhrases(['Example']);
      cubit.updateMotion(
        enabled: true,
        animationsDisabled: false,
        tickerEnabled: true,
        hasFocus: false,
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.typedHint, isNotEmpty);
      cubit.updatePrompt('question');
      final hint = cubit.state.typedHint;
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(cubit.state.typedHint, hint);
      cubit.updatePrompt('');
      cubit.updateMotion(
        enabled: true,
        animationsDisabled: false,
        tickerEnabled: true,
        hasFocus: true,
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.typedHint, hint);
      await cubit.close();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.typedHint, hint);
    },
  );

  test(
    'foreground changes pause and resume typing without a second UI decision',
    () async {
      final cubit = createHome()..updateHintPhrases(['Example']);
      addTearDown(cubit.close);
      cubit.updateMotion(
        enabled: true,
        animationsDisabled: false,
        tickerEnabled: true,
        hasFocus: false,
      );
      cubit.updateForeground(false);
      expect(cubit.state.isMotionEnabled, isFalse);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.typedHint, isEmpty);
      cubit.updateForeground(true);
      expect(cubit.state.isMotionEnabled, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.typedHint, isNotEmpty);
      cubit.updateMotion(
        enabled: true,
        animationsDisabled: true,
        tickerEnabled: true,
        hasFocus: false,
      );
      expect(cubit.state.isHintTyping, isFalse);
    },
  );
}
