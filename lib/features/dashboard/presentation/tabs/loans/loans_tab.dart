import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/repositories/dashboard_repositories.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_async_view.dart';

import 'cubit/loans_cubit.dart';
import 'cubit/loans_state.dart';

import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_loan.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/tabs/loans/loan_actions.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_loan_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_primary_navigation.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_artwork_tile.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_grid_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

/// Loan fetching, persistence, details and service execution are caller-owned.
class LoansTab extends StatefulWidget {
  const LoansTab({
    super.key,
    required this.repository,
    this.onActionRequested,
    this.onSelectedLoanChanged,
    this.onCopyNumber,
    this.onDetailsRequested,
    this.onTabSelected,
    this.onMenuPressed,
    this.onAssistantPressed,
  });
  final DashboardLoansRepository repository;
  final ValueChanged<LoanActionRequest>? onActionRequested;
  final ValueChanged<BankLoan>? onSelectedLoanChanged;
  final ValueChanged<String>? onCopyNumber;
  final ValueChanged<BankLoan>? onDetailsRequested;
  final ValueChanged<AppPrimaryTab>? onTabSelected;
  final VoidCallback? onMenuPressed, onAssistantPressed;
  @override
  State<LoansTab> createState() => _LoansTabState();
}

class _LoansTabState extends State<LoansTab> {
  PageController? _pages;
  double? _viewport;
  late final LoansCubit _cubit;
  String? _controllerItems;
  List<BankLoan> get _items => _cubit.state is DashboardTabLoaded<BankLoan>
      ? (_cubit.state as DashboardTabLoaded<BankLoan>).items
      : const [];
  int get _selected => _cubit.state is DashboardTabLoaded<BankLoan>
      ? (_cubit.state as DashboardTabLoaded<BankLoan>).selectedIndex
      : 0;
  @override
  void initState() {
    super.initState();
    _cubit = LoansCubit(repository: widget.repository)..load();
  }

  BankLoan get _loan => _items[_selected];
  @override
  void didUpdateWidget(covariant LoansTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.repository != oldWidget.repository) {
      _cubit.changeRepository(widget.repository);
    }
  }

  @override
  void dispose() {
    _pages?.dispose();
    _cubit.close();
    super.dispose();
  }

  void _request(LoanAction action) => widget.onActionRequested?.call(
    LoanActionRequest(action: action, loan: _loan),
  );

  Widget _group(
    String key,
    String title,
    List<LoanAction> actions, {
    bool quick = false,
  }) => AppServiceGridCard(
    key: Key(key),
    title: title,
    stretchItems: false,
    itemSpacing: 6,
    type: quick ? AppServiceGridCardType.quick : AppServiceGridCardType.service,
    titleColor: quick
        ? AppDashboardColors.sectionText
        : AppDashboardColors.serviceText,
    headerAction: quick
        ? SvgPicture.asset(AppAssets.depositsQuickAccess)
        : null,
    items: [
      for (final action in actions)
        AppServiceGridItem(
          id: 'loans-${action.id}',
          label: action.label(context.l10n),
          onTap: () => _request(action),
          iconSize: Size.square(quick ? 64 : 32),
          icon: quick
              ? AppServiceArtworkTile(asset: action.asset)
              : SvgPicture.asset(action.asset),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: _cubit,
    child: BlocConsumer<LoansCubit, LoansState>(
      listener: (context, state) {
        if (state is DashboardTabLoading) _controllerItems = null;
        if (state is DashboardTabLoaded<BankLoan> &&
            _pages?.hasClients == true &&
            !_pages!.position.isScrollingNotifier.value &&
            ((_pages!.page ?? 0) - state.selectedIndex).abs() > .01) {
          _pages!.jumpToPage(state.selectedIndex);
        }
      },
      builder: (context, state) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          key: const Key('loans_screen'),
          backgroundColor: context.colors.surfaceSubtle,
          body: SafeArea(
            child: Column(
              children: [
                AppTopBar(
                  title: context.l10n.dashboardMyLoans,
                  showLeadingActions: false,
                  onMenuPressed: widget.onMenuPressed,
                ),
                if (_items.isNotEmpty) _carousel(),
                Expanded(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        key: const Key('loans_services_scroll'),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 126),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (state is DashboardTabInitial ||
                                state is DashboardTabLoading)
                              const DashboardAsyncView(
                                key: Key("loans_loading"),
                                loading: true,
                              )
                            else if (state is DashboardTabError)
                              DashboardAsyncView(
                                key: const Key("loans_error"),
                                onRetry: _cubit.load,
                              )
                            else if (_items.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  context.l10n.loansEmpty,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.bodyMedium,
                                ),
                              ),
                            if (_items.isNotEmpty) ...[
                              _group(
                                'loans_operations',
                                context.l10n.loansOperations,
                                LoanAction.operations,
                              ),
                              const SizedBox(height: 12),
                              _group(
                                'loans_quick_access',
                                context.l10n.cardsQuickAccess,
                                LoanAction.quick,
                                quick: true,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 84,
                        child: AppAssistantButton(
                          key: const Key('loans_assistant_button'),
                          onPressed: widget.onAssistantPressed ?? () {},
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: AppPrimaryNavigation(
                          key: const Key('loans_navigation'),
                          selectedTab: AppPrimaryTab.loans,
                          onSelected: (tab) => widget.onTabSelected?.call(tab),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  Widget _carousel() => LayoutBuilder(
    builder: (context, constraints) {
      final single = _items.length == 1;
      final nativeWidth = single ? 335.0 : 316.0;
      const nativeHeight = 236.0;
      final width = math.min(
        nativeWidth,
        constraints.maxWidth - (single ? 40 : 59),
      );
      // Fit the existing component as a whole; its design is deliberately unchanged.
      final height = nativeHeight * width / nativeWidth;
      final fraction = (width + 12) / constraints.maxWidth;
      if (!single &&
          (_pages == null ||
              _viewport != fraction ||
              _controllerItems != _items.map((item) => item.id).join("|"))) {
        _pages?.dispose();
        _pages = PageController(
          initialPage: _selected,
          keepPage: false,
          viewportFraction: fraction,
        );
        _viewport = fraction;
        _controllerItems = _items.map((item) => item.id).join("|");
      }
      return SizedBox(
        height: height + 46,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 122,
              child: SvgPicture.asset(
                AppAssets.loansPatternUp,
                fit: BoxFit.fill,
              ),
            ),
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              height: height,
              child: single
                  ? Center(child: _loanCard(0, width, height))
                  : KeyedSubtree(
                      key: ObjectKey(_pages),
                      child: PageView.builder(
                        key: const Key('loans_carousel'),
                        controller: _pages,
                        itemCount: _items.length,
                        onPageChanged: (index) {
                          _cubit.select(index);
                          widget.onSelectedLoanChanged?.call(_loan);
                        },
                        itemBuilder: (context, index) =>
                            Center(child: _loanCard(index, width, height)),
                      ),
                    ),
            ),
            if (!single)
              Positioned(
                top: 16 + height + 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var index = 0; index < _items.length; index++) ...[
                      if (index > 0) const SizedBox(width: 6),
                      Semantics(
                        button: true,
                        selected: index == _selected,
                        label: _items[index].number,
                        child: InkWell(
                          key: Key('loans_indicator_$index'),
                          onTap: () => _pages!.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          ),
                          child: Container(
                            width: index == _selected ? 14 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: index == _selected
                                  ? AppDashboardColors.navActive
                                  : context.colors.border,
                              borderRadius: AppRadius.borderFull,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      );
    },
  );

  Widget _loanCard(int index, double width, double height) {
    final loan = _items[index];
    return SizedBox(
      width: width,
      height: height,
      child: FittedBox(
        child: AppLoanCard(
          key: ValueKey('loan_card_${loan.id}'),
          size: _items.length == 1
              ? AppLoanCardSize.single
              : AppLoanCardSize.multi,
          cardName: loan.title ?? context.l10n.loansDefaultName,
          loanNumber: loan.number,
          loanTotal: loan.total,
          installmentAmount: loan.installmentAmount,
          installmentsPaid: loan.installmentsPaid,
          nextInstallment: loan.nextInstallment,
          progress: loan.progress,
          onArrowPressed: () => widget.onDetailsRequested?.call(loan),
          onCopyLoanNumber: () => widget.onCopyNumber != null
              ? widget.onCopyNumber!(loan.number)
              : Clipboard.setData(ClipboardData(text: loan.number)),
        ),
      ),
    );
  }
}
