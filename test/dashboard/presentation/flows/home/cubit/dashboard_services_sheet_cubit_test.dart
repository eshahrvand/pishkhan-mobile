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
      ..resolveServices(labels);
    addTearDown(cubit.close);

    expect(cubit.state.groups.map((group) => group.category), [
      DashboardCategory.cards,
      DashboardCategory.deposits,
    ]);
    cubit.updateSearchQuery('  كارت  ');
    expect(cubit.state.query, '  كارت  ');
    expect(cubit.state.isSearching, isTrue);
    expect(cubit.state.groups.single.category, DashboardCategory.cards);
    expect(cubit.state.groups.single.choices.map((choice) => choice.service), [
      DashboardService.issue,
      DashboardService.cardDeposit,
    ]);
    cubit.updateSearchQuery('not-found');
    expect(cubit.state.groups, isEmpty);
    cubit.updateSearchQuery('');
    expect(cubit.state.groups, hasLength(2));
    expect(cubit.state.isSearching, isFalse);
  });

  test('excluded services are disabled and valid choices publish repeatable selection', () {
    final cubit = DashboardServicesSheetCubit(
      excluded: [DashboardService.issue.id],
      category: [DashboardService.issue, DashboardService.statement],
    )..resolveServices(labels);
    addTearDown(cubit.close);
    expect(cubit.state.groups.first.choices.single.canSelect, isFalse);
    expect(
      cubit.state.groups.last.choices.single.service,
      DashboardService.statement,
    );
    cubit.selectService(cubit.state.groups.last.choices.single.service);
    expect(cubit.state.selectedService, DashboardService.statement);
    final selectionId = cubit.state.selectionId;
    cubit.selectService(cubit.state.groups.last.choices.single.service);
    expect(cubit.state.selectionId, selectionId + 1);
    cubit.updateSearchQuery('کارت');
    expect(cubit.state.groups, hasLength(1));
    expect(cubit.state.groups.single.choices.single.canSelect, isFalse);
  });

  test('search expands groups temporarily and preserves collapse on clear', () {
    final cubit = DashboardServicesSheetCubit(
      category: [DashboardService.issue],
    )..resolveServices(labels);
    addTearDown(cubit.close);

    cubit.toggleCategory(DashboardCategory.cards);
    expect(cubit.state.groups.single.isCollapsed, isTrue);
    cubit.updateSearchQuery('کارت');
    expect(cubit.state.groups.single.isCollapsed, isFalse);
    expect(cubit.state.groups.single.canToggle, isFalse);
    cubit.updateSearchQuery('');
    expect(cubit.state.groups.single.isCollapsed, isTrue);
    expect(cubit.state.groups.single.canToggle, isTrue);
  });

  test('initial query and label replacement recalculate results', () {
    final cubit = DashboardServicesSheetCubit(
      initialState: const DashboardServicesSheetState.initial(query: 'کارت'),
      category: [DashboardService.issue],
    )..resolveServices(labels);
    addTearDown(cubit.close);

    expect(cubit.state.groups.single.category, DashboardCategory.cards);
    cubit.resolveServices({DashboardService.issue: 'Card issuance'});
    expect(cubit.state.groups, isEmpty);
    cubit.updateSearchQuery('Card');
    expect(cubit.state.groups.single.choices.single.canSelect, isTrue);
  });
}
