import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_drawer.dart';

import '../../shared/dashboard_drawer_group.dart';
import '../../shared/dashboard_services.dart';
import '../cubit/home_cubit.dart';

Future<DashboardDrawerSelection?> showDashboardDrawer(BuildContext context) {
  final cubit = context.read<HomeCubit>();
  FocusManager.instance.primaryFocus?.unfocus();
  return showGeneralDialog<DashboardDrawerSelection>(
    context: context,
    barrierDismissible: true,
    barrierLabel: S.current.backLabel,
    barrierColor: Colors.transparent,
    transitionDuration: Duration.zero,
    pageBuilder: (context, animation, secondaryAnimation) =>
        BlocProvider.value(value: cubit, child: const DashboardDrawer()),
  );
}

class DashboardDrawer extends StatefulWidget {
  const DashboardDrawer({super.key});

  @override
  State<DashboardDrawer> createState() => _DashboardDrawerState();
}

class _DashboardDrawerState extends State<DashboardDrawer> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: context.read<HomeCubit>().state.drawerQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listenWhen: (previous, current) =>
          previous.drawerSelection != current.drawerSelection &&
          current.drawerSelection != null,
      listener: (context, state) =>
          Navigator.of(context).pop(state.drawerSelection),
      buildWhen: (previous, current) =>
          previous.drawerGroups != current.drawerGroups ||
          previous.expandedDrawerSection != current.expandedDrawerSection ||
          previous.selectedDrawerSection != current.selectedDrawerSection,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: AppDrawer(
            isOpen: true,
            title: S.current.appTitle,
            logo: AppDrawerIcons.resalat(),
            searchHint: S.current.dashboardSearchHint,
            searchController: _searchController,
            onSearchChanged: context.read<HomeCubit>().updateDrawerSearchQuery,
            expandedItemId: state.expandedDrawerSection?.name,
            selectedItemId: state.selectedDrawerSection.name,
            onOpenChanged: (_) => Navigator.of(context).pop(),
            onItemSelected: (item) => context
                .read<HomeCubit>()
                .selectDrawerSection((item as DashboardDrawerItem).section),
            onSubItemSelected: (item) => context
                .read<HomeCubit>()
                .selectDrawerService((item as DashboardDrawerSubItem).service),
            items: [
              for (final group in state.drawerGroups)
                DashboardDrawerItem(
                  section: group.section,
                  label: dashboardDrawerSectionLabel(group.section),
                  icon: dashboardDrawerSectionIcon(group.section),
                  selectedIcon: dashboardDrawerSelectedIcon(group.section),
                  children: [
                    for (final service in group.services)
                      DashboardDrawerSubItem(
                        service: service,
                        label: dashboardDrawerServiceLabel(service),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

// Preserve the rendered typed values across the shared component's callbacks.
class DashboardDrawerItem extends AppDrawerItem {
  DashboardDrawerItem({
    required this.section,
    required super.label,
    required super.icon,
    super.selectedIcon,
    super.children,
  }) : super(id: section.name);

  final DashboardDrawerSection section;
}

class DashboardDrawerSubItem extends AppDrawerSubItem {
  DashboardDrawerSubItem({required this.service, required super.label})
    : super(id: service.id);

  final DashboardService service;
}

Map<DashboardDrawerSection, String> dashboardDrawerSectionLabels() => {
  for (final section in DashboardDrawerSection.values)
    section: dashboardDrawerSectionLabel(section),
};

Map<DashboardService, String> dashboardDrawerServiceLabels() => {
  for (final service in DashboardService.values)
    service: dashboardDrawerServiceLabel(service),
};

String dashboardDrawerServiceLabel(DashboardService service) =>
    switch (service) {
      DashboardService.password => S.current.cardPasswordIssue.replaceAll(
        RegExp(r'\s*/\s*'),
        ' | ',
      ),
      _ => service.catalogLabel(),
    };

String dashboardDrawerSectionLabel(DashboardDrawerSection section) =>
    switch (section) {
      DashboardDrawerSection.home => S.current.dashboardTab,
      DashboardDrawerSection.modern => S.current.dashboardModernBanking,
      DashboardDrawerSection.cards => S.current.dashboardCardsTab,
      DashboardDrawerSection.cheques => S.current.dashboardChequeServices,
      DashboardDrawerSection.transfers => S.current.dashboardTransferServices,
      DashboardDrawerSection.loans => S.current.dashboardLoansTab,
      DashboardDrawerSection.deposits => S.current.dashboardDepositsTab,
      DashboardDrawerSection.wallet => S.current.dashboardWalletServices,
      DashboardDrawerSection.identity => S.current.dashboardIdentityServices,
      DashboardDrawerSection.requests => S.current.dashboardRequestServices,
    };

Widget dashboardDrawerSectionIcon(DashboardDrawerSection section) =>
    switch (section) {
      DashboardDrawerSection.home => AppDrawerIcons.home(),
      DashboardDrawerSection.modern => AppDrawerIcons.modernBanking(),
      DashboardDrawerSection.cards => AppDrawerIcons.card(),
      DashboardDrawerSection.cheques => AppDrawerIcons.cheque(),
      DashboardDrawerSection.transfers => AppDrawerIcons.moneyTransfer(),
      DashboardDrawerSection.loans => AppDrawerIcons.loan(),
      DashboardDrawerSection.deposits => AppDrawerIcons.deposit(),
      DashboardDrawerSection.wallet => AppDrawerIcons.wallet(),
      DashboardDrawerSection.identity =>
        AppDrawerIcons.personalInformationDeselected(),
      DashboardDrawerSection.requests => const AvpImage(
        image: AppAssets.drawerMyRequestsDeselected,
        width: 20,
        height: 20,
      ),
    };

Widget? dashboardDrawerSelectedIcon(DashboardDrawerSection section) =>
    switch (section) {
      DashboardDrawerSection.identity => AppDrawerIcons.personalInformation(),
      DashboardDrawerSection.requests => AppDrawerIcons.myRequests(),
      _ => null,
    };
