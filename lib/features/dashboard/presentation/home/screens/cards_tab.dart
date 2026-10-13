import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/repositories/dashboard_repositories.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_async_view.dart';

import '../cubit/cards_cubit.dart';

import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/app_primary_navigation.dart';
import 'package:pishkhan_mobile/shared/widgets/app_resalat_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_grid_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_artwork_tile.dart';

import '../../shared/card_actions.dart';
export '../../shared/card_actions.dart';

/// Second primary tab. Service execution and card fetching belong to the caller.
class CardsTab extends StatefulWidget {
  const CardsTab({
    super.key,
    required this.repository,
    this.onActionRequested,
    this.onMorePressed,
    this.onCopyNumber,
    this.onCopyIban,
    this.onSelectedCardChanged,
    this.onTabSelected,
    this.onMenuPressed,
    this.onAssistantPressed,
  });
  final DashboardCardsRepository repository;
  final ValueChanged<CardActionRequest>? onActionRequested;
  final ValueChanged<BankCard>? onMorePressed, onSelectedCardChanged;
  final ValueChanged<String>? onCopyNumber, onCopyIban;
  final ValueChanged<AppPrimaryTab>? onTabSelected;
  final VoidCallback? onMenuPressed, onAssistantPressed;
  @override
  State<CardsTab> createState() => _CardsTabState();
}

class _CardsTabState extends State<CardsTab> {
  PageController? _pages;
  double? _viewport;
  late final CardsCubit _cubit;
  String? _controllerItems;
  @override
  void initState() {
    super.initState();
    _cubit = CardsCubit(
      initialState: const CardsState(),
      repository: widget.repository,
    )..load();
  }

  @override
  void didUpdateWidget(covariant CardsTab oldWidget) {
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

  void _request(CardAction action) => widget.onActionRequested?.call(
    CardActionRequest(action: action, card: _cubit.state.selectedCard!),
  );
  String _label(CardAction action) => switch (action) {
    CardAction.reissue => context.l10n.cardsReissue,
    CardAction.changeDeposit => context.l10n.changeCardDeposit,
    CardAction.block => context.l10n.blockCard,
    CardAction.changeFirstPin => context.l10n.cardsChangeFirst,
    CardAction.setSecondPin => context.l10n.cardsSetSecond,
    CardAction.forgotFirstPin => context.l10n.cardsForgotFirst,
    CardAction.forgotSecondPin => context.l10n.cardsForgotSecond,
    CardAction.issue => context.l10n.issueResalatCard,
    CardAction.virtualCard => context.l10n.cardsVirtual,
    CardAction.giftPurchase => context.l10n.cardsBuyGift,
    CardAction.giftBalance => context.l10n.cardsGiftBalance,
  };
  String _asset(CardAction action) => switch (action) {
    CardAction.reissue => AppAssets.cardsActionReissue,
    CardAction.changeDeposit => AppAssets.cardsActionDeposit,
    CardAction.block => AppAssets.cardsActionBlock,
    CardAction.changeFirstPin => AppAssets.cardsActionChangeFirst,
    CardAction.setSecondPin => AppAssets.cardsActionSetSecond,
    CardAction.forgotFirstPin => AppAssets.cardsActionForgotFirst,
    CardAction.forgotSecondPin => AppAssets.cardsActionForgotSecond,
    CardAction.issue => AppAssets.cardsQuickIssue,
    CardAction.virtualCard => AppAssets.cardsQuickVirtual,
    CardAction.giftPurchase => AppAssets.cardsQuickGiftBuy,
    CardAction.giftBalance => AppAssets.cardsQuickGiftBalance,
  };
  Widget _group(
    String key,
    String title,
    List<CardAction> actions, {
    bool quick = false,
  }) => AppServiceGridCard(
    key: Key(key),
    title: title,
    itemSpacing: 6,
    stretchItems: false,
    titleColor: quick
        ? AppDashboardColors.sectionText
        : AppDashboardColors.serviceText,
    type: quick ? AppServiceGridCardType.quick : AppServiceGridCardType.service,
    headerAction: quick ? SvgPicture.asset(AppAssets.cardsQuickAccess) : null,
    items: [
      for (final action in actions)
        AppServiceGridItem(
          id: action.id,
          label: _label(action),
          onTap: () => _request(action),
          iconSize: Size.square(quick ? 64 : 32),
          icon: quick
              ? AppServiceArtworkTile(asset: _asset(action))
              : SvgPicture.asset(_asset(action)),
        ),
    ],
  );
  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: _cubit,
    child: BlocConsumer<CardsCubit, CardsState>(
      listener: (context, state) {
        if (state.status == RequestStatus.loading) _controllerItems = null;
        if (state.status == RequestStatus.success && state.items != null) {
          final selectedIndex = state.selectedIndex;
          if (_pages?.hasClients == true &&
              !_pages!.position.isScrollingNotifier.value &&
              ((_pages!.page ?? 0) - selectedIndex).abs() > .01) {
            _pages!.jumpToPage(selectedIndex);
          }
        }
      },
      builder: (context, state) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: context.colors.surfaceSubtle,
          body: SafeArea(
            child: Column(
              children: [
                AppTopBar(
                  title: context.l10n.cardsMyTitle,
                  showLeadingActions: false,
                  onMenuPressed: widget.onMenuPressed,
                ),
                if (_cubit.state.visibleItems.isNotEmpty) _carousel(),
                Expanded(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        key: const Key('cards_services_scroll'),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (state.status == RequestStatus.initial ||
                                state.status == RequestStatus.loading)
                              const DashboardAsyncView(
                                key: Key("cards_loading"),
                                loading: true,
                              )
                            else if (state.status == RequestStatus.failure)
                              DashboardAsyncView(
                                key: const Key("cards_error"),
                                onRetry: _cubit.load,
                              )
                            else if (_cubit.state.visibleItems.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  context.l10n.cardsEmpty,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.bodyMedium,
                                ),
                              ),
                            if (_cubit.state.visibleItems.isNotEmpty) ...[
                              _group(
                                'cards_operations',
                                context.l10n.cardsOperations,
                                [
                                  CardAction.reissue,
                                  CardAction.changeDeposit,
                                  CardAction.block,
                                ],
                              ),
                              const SizedBox(height: 16),
                              _group(
                                'cards_pin_operations',
                                context.l10n.cardsPinOperations,
                                [
                                  CardAction.changeFirstPin,
                                  _cubit.state.selectedCard!.canSetSecondPin
                                      ? CardAction.setSecondPin
                                      : CardAction.forgotSecondPin,
                                  CardAction.forgotFirstPin,
                                ],
                              ),
                              const SizedBox(height: 16),
                              _group(
                                'cards_quick_access',
                                context.l10n.cardsQuickAccess,
                                [
                                  CardAction.issue,
                                  CardAction.virtualCard,
                                  CardAction.giftPurchase,
                                  CardAction.giftBalance,
                                ],
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
                          key: const Key('cards_assistant_button'),
                          onPressed: widget.onAssistantPressed ?? () {},
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: AppPrimaryNavigation(
                          key: const Key('cards_navigation'),
                          selectedTab: AppPrimaryTab.cards,
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
      final single = _cubit.state.visibleItems.length == 1;
      final width = math.min(
        single ? 335.0 : 316.0,
        constraints.maxWidth - (single ? 40 : 59),
      );
      final extra =
          math.max(0.0, MediaQuery.textScalerOf(context).scale(1) - 1) * 50;
      final height = (single ? 202.0 : 191.0) + extra;
      final fraction = (width + 12) / constraints.maxWidth;
      if (!single &&
          (_pages == null ||
              _viewport != fraction ||
              _controllerItems !=
                  _cubit.state.visibleItems.map((item) => item.id).join("|"))) {
        _pages?.dispose();
        _pages = PageController(
          initialPage: _cubit.state.selectedIndex,
          keepPage: false,
          viewportFraction: fraction,
        );
        _viewport = fraction;
        _controllerItems = _cubit.state.visibleItems
            .map((item) => item.id)
            .join("|");
      }
      return SizedBox(
        height: 237 + extra,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 122,
              child: SvgPicture.asset(
                AppAssets.cardsPatternUp,
                fit: BoxFit.fill,
              ),
            ),
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              height: height,
              child: single
                  ? Center(child: _bankCard(0, width))
                  : KeyedSubtree(
                      key: ObjectKey(_pages),
                      child: PageView.builder(
                        clipBehavior: Clip.none,
                        key: const Key('cards_carousel'),
                        controller: _pages,
                        itemCount: _cubit.state.visibleItems.length,
                        onPageChanged: (index) {
                          _cubit.select(index);
                          widget.onSelectedCardChanged?.call(
                            _cubit.state.selectedCard!,
                          );
                        },
                        itemBuilder: (context, index) =>
                            Center(child: _bankCard(index, width)),
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
                    for (
                      var index = 0;
                      index < _cubit.state.visibleItems.length;
                      index++
                    ) ...[
                      if (index > 0) const SizedBox(width: 6),
                      Semantics(
                        button: true,
                        selected: index == _cubit.state.selectedIndex,
                        label: _cubit.state.visibleItems[index].id,
                        child: InkWell(
                          key: Key('cards_indicator_$index'),
                          onTap: () => _pages!.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          ),
                          child: Container(
                            width: index == _cubit.state.selectedIndex ? 14 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: index == _cubit.state.selectedIndex
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
  Widget _bankCard(int index, double width) {
    final card = _cubit.state.visibleItems[index];
    final visible =
        _cubit.state.visibility[card.id] ??
        _cubit.state.visibleItems.length == 1;
    return AppResalatCard(
      key: ValueKey('bank_card_${card.id}'),
      width: width,
      size: _cubit.state.visibleItems.length == 1
          ? AppResalatCardSize.single
          : AppResalatCardSize.multi,
      cardType: card.kind == BankCardKind.current
          ? context.l10n.cardsCurrent
          : context.l10n.cardsQarz,
      cardNumberParts: card.numberParts,
      iban: card.iban,
      expiry: card.expiry,
      cvv2: card.cvv2,
      isVisible: visible,
      expiryLabel: context.l10n.cardsExpiry,
      visibilityLabel: visible
          ? context.l10n.cardsHideDetails
          : context.l10n.cardsShowDetails,
      moreLabel: context.l10n.cardsMore,
      copyNumberLabel: context.l10n.cardsCopyNumber,
      copyIbanLabel: context.l10n.cardsCopyIban,
      onMorePressed: () => widget.onMorePressed?.call(card),
      onVisibilityChanged: (value) => _cubit.setVisibility(card.id, value),
      onCopyCardNumber: () => widget.onCopyNumber != null
          ? widget.onCopyNumber!(card.number)
          : Clipboard.setData(ClipboardData(text: card.number)),
      onCopyIban: () => widget.onCopyIban != null
          ? widget.onCopyIban!(card.iban)
          : Clipboard.setData(ClipboardData(text: card.iban)),
    );
  }
}
