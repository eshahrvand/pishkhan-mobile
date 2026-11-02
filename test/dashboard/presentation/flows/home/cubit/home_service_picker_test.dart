import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/home_effect.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/home_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';

void main() {
  const labels = {
    DashboardService.issue: 'صدور کارت',
    DashboardService.cardDeposit: 'تغییر سپرده کارت',
    DashboardService.statement: 'میانگین موجودی',
  };
  setUp(configureDependencies);
  tearDown(getIt.reset);

  HomeCubit create() {
    final cubit = HomeCubit(servicePickerLabels: labels);
    addTearDown(cubit.close);
    cubit.requestFavoritePicker();
    cubit.consumeHomeInteraction();
    return cubit;
  }

  test('Home prepares picker search and normalizes Arabic characters', () {
    final cubit = create();
    cubit.updateServicePickerQuery('  كارت  ');
    expect(cubit.state.servicePickerQuery, '  كارت  ');
    expect(cubit.state.isServicePickerSearching, isTrue);
    expect(
      cubit.state.servicePickerGroups.single.category,
      DashboardCategory.cards,
    );
    expect(
      cubit.state.servicePickerGroups.single.choices.map(
        (choice) => choice.service,
      ),
      [DashboardService.issue, DashboardService.cardDeposit],
    );
    cubit.updateServicePickerQuery('not-found');
    expect(cubit.state.servicePickerGroups, isEmpty);
    cubit.updateServicePickerQuery('');
    expect(cubit.state.servicePickerGroups, isNotEmpty);
    expect(cubit.state.isServicePickerSearching, isFalse);
  });

  test(
    'favorites are disabled and the next opening clears the previous selection',
    () {
      final cubit = HomeCubit(
        servicePickerLabels: labels,
        initialState: const HomeState.initial(
          favoriteServices: [DashboardService.issue],
        ),
      );
      addTearDown(cubit.close);
      cubit.requestFavoritePicker();
      final issue = cubit.state.servicePickerGroups
          .expand((group) => group.choices)
          .singleWhere((choice) => choice.service == DashboardService.issue);
      expect(issue.canSelect, isFalse);
      cubit.consumeHomeInteraction();
      cubit.selectPickerService(DashboardService.statement);
      expect(cubit.state.pickedService, DashboardService.statement);
      cubit.requestFavoritePicker();
      expect(cubit.state.pickedService, isNull);
      expect(cubit.state.effect, isA<HomeFavoritePickerRequested>());
    },
  );

  test(
    'search expands categories temporarily and preserves collapse on clear',
    () {
      final cubit = create();
      cubit.toggleServicePickerCategory(DashboardCategory.cards);
      expect(
        cubit.state.servicePickerGroups
            .singleWhere((group) => group.category == DashboardCategory.cards)
            .isCollapsed,
        isTrue,
      );
      cubit.updateServicePickerQuery('کارت');
      expect(cubit.state.servicePickerGroups.single.isCollapsed, isFalse);
      expect(cubit.state.servicePickerGroups.single.canToggle, isFalse);
      cubit.updateServicePickerQuery('');
      expect(
        cubit.state.servicePickerGroups
            .singleWhere((group) => group.category == DashboardCategory.cards)
            .isCollapsed,
        isTrue,
      );
    },
  );

  test('each opening resets search and collapse in the same Home scope', () {
    final cubit = create();
    cubit.toggleServicePickerCategory(DashboardCategory.cards);
    cubit.updateServicePickerQuery('کارت');
    cubit.requestFavoritePicker();
    expect(cubit.state.servicePickerQuery, isEmpty);
    expect(cubit.state.isServicePickerSearching, isFalse);
    expect(cubit.state.servicePickerCollapsedCategories, isEmpty);
  });
}
