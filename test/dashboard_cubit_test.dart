import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/cubit/dashboard_cubit.dart';

void main() {
  test(
    'draft changes are isolated, unique and limited to four services',
    () async {
      final cubit = DashboardCubit(favorites: ['one']);
      cubit.add('ignored');
      expect(cubit.state.favorites, ['one']);
      cubit.edit();
      for (final id in ['one', 'two', 'three', 'four', 'five']) {
        cubit.add(id);
      }
      expect(cubit.state.draft, ['one', 'two', 'three', 'four']);
      expect(cubit.state.favorites, ['one']);
      cubit.remove('two');
      cubit.add('five');
      expect(cubit.state.draft, ['one', 'three', 'four', 'five']);
      cubit.confirm();
      expect(cubit.state.favorites, ['one', 'three', 'four', 'five']);
      cubit.edit();
      cubit.remove('one');
      cubit.cancel();
      expect(cubit.state.favorites, ['one', 'three', 'four', 'five']);
      cubit.reset();
      expect(cubit.state.favorites, isEmpty);
      expect(cubit.state.isEditing, isFalse);
      await cubit.close();
    },
  );
}
