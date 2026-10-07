import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/cubit/dashboard_cubit.dart';

void main() {
  test('draft edits are unique, limited to eight, and transactional', () async {
    final cubit = DashboardCubit(favorites: ['one']);
    cubit.add('ignored');
    cubit.edit();
    for (final id in [
      'one',
      'two',
      'three',
      'four',
      'five',
      'six',
      'seven',
      'eight',
      'nine',
    ]) {
      cubit.add(id);
    }
    expect(cubit.state.draft, [
      'one',
      'two',
      'three',
      'four',
      'five',
      'six',
      'seven',
      'eight',
    ]);
    expect(cubit.state.favorites, ['one']);
    cubit.remove('two');
    cubit.add('nine');
    cubit.confirm();
    expect(cubit.state.favorites, [
      'one',
      'three',
      'four',
      'five',
      'six',
      'seven',
      'eight',
      'nine',
    ]);
    cubit.edit();
    cubit.remove('one');
    cubit.cancel();
    expect(cubit.state.favorites.length, 8);
    cubit.reset();
    expect(cubit.state.favorites, isEmpty);
    expect(cubit.state.isEditing, isFalse);
    await cubit.close();
  });
  test('suggestions remain uncommitted until confirmation', () async {
    final cubit = DashboardCubit();
    cubit.edit(suggestions: ['a', 'b', 'c']);
    expect(cubit.state.favorites, isEmpty);
    expect(cubit.state.draft, ['a', 'b', 'c']);
    cubit.cancel();
    expect(cubit.state.favorites, isEmpty);
    cubit.edit(suggestions: ['a']);
    cubit.confirm();
    cubit.edit(suggestions: ['b']);
    expect(cubit.state.draft, ['a']);
    await cubit.close();
  });
}
