import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/deposits/models/bank_deposit.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/shared/deposit_actions.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_deposit_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_primary_navigation.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_artwork_tile.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_grid_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

/// Deposit fetching, persistence and service execution are caller-owned.
class DepositsScreen extends StatefulWidget {
  const DepositsScreen({
    super.key,
    this.deposits = BankDeposit.examples,
    this.onActionRequested,
    this.onSelectedDepositChanged,
    this.onCopyNumber,
    this.onCopyIban,
    this.onTabSelected,
    this.onMenuPressed,
    this.onAssistantPressed,
  });
  final List<BankDeposit> deposits;
  final ValueChanged<DepositActionRequest>? onActionRequested;
  final ValueChanged<BankDeposit>? onSelectedDepositChanged;
  final ValueChanged<String>? onCopyNumber, onCopyIban;
  final ValueChanged<AppPrimaryTab>? onTabSelected;
  final VoidCallback? onMenuPressed, onAssistantPressed;
  @override
  State<DepositsScreen> createState() => _DepositsScreenState();
}

class _DepositsScreenState extends State<DepositsScreen> {
  PageController? _pages;
  double? _viewport;
  int _selected = 0;
  BankDeposit get _deposit => widget.deposits[_selected];
  @override
  void didUpdateWidget(covariant DepositsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selectedId = oldWidget.deposits.isEmpty
        ? null
        : oldWidget
              .deposits[math.min(_selected, oldWidget.deposits.length - 1)]
              .id;
    final found = widget.deposits.indexWhere(
      (deposit) => deposit.id == selectedId,
    );
    final next = found < 0 ? 0 : found;
    if (next != _selected ||
        oldWidget.deposits.length != widget.deposits.length) {
      _selected = next;
      _pages?.dispose();
      _pages = null;
      _viewport = null;
    }
  }

  @override
  void dispose() {
    _pages?.dispose();
    super.dispose();
  }

  void _request(DepositAction action) => widget.onActionRequested?.call(
    DepositActionRequest(action: action, deposit: _deposit),
  );

  Widget _group(
    String key,
    String title,
    List<DepositAction> actions, {
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
          id: 'deposits-${action.id}',
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
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      key: const Key('deposits_screen'),
      backgroundColor: context.colors.surfaceSubtle,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              title: context.l10n.depositsMyTitle,
              showLeadingActions: false,
              onMenuPressed: widget.onMenuPressed,
            ),
            if (widget.deposits.isNotEmpty) _carousel(),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    key: const Key('deposits_services_scroll'),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 126),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.deposits.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              context.l10n.depositsEmpty,
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyMedium,
                            ),
                          ),
                        if (widget.deposits.isNotEmpty) ...[
                          _group(
                            'deposits_operations',
                            context.l10n.depositsOperations,
                            DepositAction.operations,
                          ),
                          const SizedBox(height: 16),
                          if (_deposit.hasChequeOperations) ...[
                            _group(
                              'deposits_cheque_operations',
                              context.l10n.depositsChequeOperations,
                              DepositAction.cheques,
                            ),
                            const SizedBox(height: 16),
                          ],
                          _group(
                            'deposits_quick_access',
                            context.l10n.cardsQuickAccess,
                            DepositAction.quick,
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
                      key: const Key('deposits_assistant_button'),
                      onPressed: widget.onAssistantPressed ?? () {},
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: AppPrimaryNavigation(
                      key: const Key('deposits_navigation'),
                      selectedTab: AppPrimaryTab.deposits,
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
  );

  Widget _carousel() => LayoutBuilder(
    builder: (context, constraints) {
      final single = widget.deposits.length == 1;
      final nativeWidth = single ? 335.0 : 316.0;
      final nativeHeight = single ? 202.0 : 191.0;
      final width = math.min(
        nativeWidth,
        constraints.maxWidth - (single ? 40 : 59),
      );
      // Fit the existing component as a whole; its design is deliberately unchanged.
      final height = nativeHeight * width / nativeWidth;
      final fraction = (width + 12) / constraints.maxWidth;
      if (!single && (_pages == null || _viewport != fraction)) {
        _pages?.dispose();
        _pages = PageController(
          initialPage: _selected,
          keepPage: false,
          viewportFraction: fraction,
        );
        _viewport = fraction;
      }
      return SizedBox(
        height: single ? height + 35 : height + 46,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 122,
              child: SvgPicture.asset(
                AppAssets.depositsPatternUp,
                fit: BoxFit.fill,
              ),
            ),
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              height: height,
              child: single
                  ? Center(child: _depositCard(0, width, height))
                  : PageView.builder(
                      key: const Key('deposits_carousel'),
                      controller: _pages,
                      itemCount: widget.deposits.length,
                      onPageChanged: (index) {
                        setState(() => _selected = index);
                        widget.onSelectedDepositChanged?.call(_deposit);
                      },
                      itemBuilder: (context, index) =>
                          Center(child: _depositCard(index, width, height)),
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
                    for (
                      var index = 0;
                      index < widget.deposits.length;
                      index++
                    ) ...[
                      if (index > 0) const SizedBox(width: 6),
                      Semantics(
                        button: true,
                        selected: index == _selected,
                        label: widget.deposits[index].number,
                        child: InkWell(
                          key: Key('deposits_indicator_$index'),
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

  Widget _depositCard(int index, double width, double height) {
    final deposit = widget.deposits[index];
    return SizedBox(
      width: width,
      height: height,
      child: FittedBox(
        child: AppDepositCard(
          key: ValueKey('deposit_card_${deposit.id}'),
          size: widget.deposits.length == 1
              ? AppDepositCardSize.single
              : AppDepositCardSize.multi,
          cardType: deposit.typeLabel,
          depositNumber: deposit.number,
          iban: deposit.iban,
          openingDate: deposit.openingDate,
          // The neighboring cards in the Figma frame retain their full color.
          isSelected: true,
          onCopyDepositNumber: () => widget.onCopyNumber != null
              ? widget.onCopyNumber!(deposit.number)
              : Clipboard.setData(ClipboardData(text: deposit.number)),
          onCopyIban: () => widget.onCopyIban != null
              ? widget.onCopyIban!(deposit.iban)
              : Clipboard.setData(ClipboardData(text: deposit.iban)),
        ),
      ),
    );
  }
}
