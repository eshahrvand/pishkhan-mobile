import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/home_cubit.dart';
import '../../shared/dashboard_service_group.dart';
import '../../shared/dashboard_services.dart';
import '../../shared/widgets/dashboard_category_heading.dart';
import '../../shared/widgets/dashboard_service_option.dart';

class DashboardServiceGroupSection extends StatelessWidget {
  const DashboardServiceGroupSection({
    super.key,
    required this.group,
    required this.isSearching,
    required this.onSelected,
  });

  final DashboardServiceGroup group;
  final bool isSearching;
  final ValueChanged<DashboardService> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardCategoryHeading(
          category: group.category,
          compact: true,
          collapsed: group.isCollapsed,
          active: group.canToggle,
          search: isSearching,
          onTap: group.canToggle
              ? () {
                  context.read<HomeCubit>().toggleServicePickerCategory(
                    group.category,
                  );
                }
              : null,
        ),
        if (isSearching) ...[
          const SizedBox(height: 16),
          for (final choice in group.choices) ...[
            DashboardServiceOption(
              service: choice.service,
              enabled: choice.canSelect,
              plain: true,
              onSelected: onSelected,
            ),
            if (choice != group.choices.last) const SizedBox(height: 16),
          ],
        ] else if (!group.isCollapsed) ...[
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final choice in group.choices)
                    SizedBox(
                      width:
                          choice.service == DashboardService.cardDeposit ||
                              choice.service == DashboardService.expiredGift ||
                              (group.choices.length.isOdd &&
                                  choice == group.choices.last)
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 8) / 2,
                      child: DashboardServiceOption(
                        service: choice.service,
                        enabled: choice.canSelect,
                        onSelected: onSelected,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}
