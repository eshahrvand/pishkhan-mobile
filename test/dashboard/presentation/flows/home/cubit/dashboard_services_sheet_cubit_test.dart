import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/cubit/dashboard_services_sheet_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';

void main() {
  const labels = {
    DashboardService.issue: 'صدور کارت',
    DashboardService.cardDeposit: 'تغییر سپرده کارت',
    DashboardService.statement: 'میانگین موجودی',
  };

  test('search prepares matching groups and normalizes Arabic characters', () {
    final cubit = DashboardServicesSheetCubit(category: labels.keys.toList())
      ..loadServices(labels);
    addTearDown(cubit.close);

    expect(cubit.state.groups.map((group) => group.category), [
      DashboardCategory.cards,
      DashboardCategory.deposits,
    ]);
    cubit.updateQuery('  كارت  ');
    expect(cubit.state.query, '  كارت  ');
    expect(cubit.state.isSearching, isTrue);
    expect(cubit.state.groups.single.category, DashboardCategory.cards);
    expect(cubit.state.groups.single.choices.map((choice) => choice.service), [
      DashboardService.issue,
      DashboardService.cardDeposit,
    ]);
    cubit.updateQuery('not-found');
    expect(cubit.state.groups, isEmpty);
    cubit.updateQuery('');
    expect(cubit.state.groups, hasLength(2));
    expect(cubit.state.isSearching, isFalse);
  });

  test('selection rejects excluded, disallowed and nonmatching services', () {
    final cubit = DashboardServicesSheetCubit(
      excluded: [DashboardService.issue.id],
      category: [DashboardService.issue, DashboardService.statement],
    )..loadServices(labels);
    addTearDown(cubit.close);

    expect(cubit.state.groups.first.choices.single.canSelect, isFalse);
    expect(cubit.selectService(DashboardService.issue), isNull);
    expect(cubit.selectService(DashboardService.cardDeposit), isNull);
    expect(
      cubit.selectService(DashboardService.statement),
      DashboardService.statement,
    );
    cubit.updateQuery('کارت');
    expect(cubit.selectService(DashboardService.statement), isNull);
    expect(cubit.selectService(DashboardService.issue), isNull);
  });

  test('search expands groups temporarily and preserves collapse on clear', () {
    final cubit = DashboardServicesSheetCubit(
      category: [DashboardService.issue],
    )..loadServices(labels);
    addTearDown(cubit.close);

    cubit.toggleCategory(DashboardCategory.cards);
    expect(cubit.state.groups.single.isCollapsed, isTrue);
    cubit.updateQuery('کارت');
    expect(cubit.state.groups.single.isCollapsed, isFalse);
    expect(cubit.state.groups.single.canToggle, isFalse);
    cubit.toggleCategory(DashboardCategory.cards);
    cubit.updateQuery('');
    expect(cubit.state.groups.single.isCollapsed, isTrue);
    expect(cubit.state.groups.single.canToggle, isTrue);
  });

  test('initial query and label replacement recalculate results', () {
    final cubit = DashboardServicesSheetCubit(
      initialState: const DashboardServicesSheetState.initial(query: 'کارت'),
      category: [DashboardService.issue],
    )..loadServices(labels);
    addTearDown(cubit.close);

    expect(cubit.state.groups.single.category, DashboardCategory.cards);
    cubit.loadServices({DashboardService.issue: 'Card issuance'});
    expect(cubit.state.groups, isEmpty);
    cubit.updateQuery('Card');
    expect(cubit.state.groups.single.choices.single.canSelect, isTrue);
  });
}
