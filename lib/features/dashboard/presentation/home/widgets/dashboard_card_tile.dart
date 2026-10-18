import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_card.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_resalat_card.dart';

export '../../shared/card_actions.dart';

/// Second primary tab. Service execution and card fetching belong to the caller.
class DashboardCardTile extends StatelessWidget {
  const DashboardCardTile({
    super.key,
    required this.card,
    required this.width,
    required this.isSingle,
    this.onCopyNumber,
    this.onCopyIban,
    this.onMorePressed,
    required this.isVisible,
    required this.onVisibilityChanged,
  });
  final BankCard card;
  final double width;
  final bool isSingle;
  final ValueChanged<String>? onCopyNumber;
  final ValueChanged<String>? onCopyIban;
  final ValueChanged<BankCard>? onMorePressed;
  final bool isVisible;
  final ValueChanged<bool> onVisibilityChanged;

  @override
  Widget build(BuildContext context) {
    return AppResalatCard(
      width: width,
      size: isSingle ? AppResalatCardSize.single : AppResalatCardSize.multi,
      cardType: card.kind == BankCardKind.current
          ? S.current.cardsCurrent
          : S.current.cardsQarz,
      cardNumberParts: card.numberParts,
      iban: card.iban,
      expiry: card.expiry,
      cvv2: card.cvv2,
      isVisible: isVisible,
      expiryLabel: S.current.cardsExpiry,
      visibilityLabel: isVisible
          ? S.current.cardsHideDetails
          : S.current.cardsShowDetails,
      moreLabel: S.current.cardsMore,
      copyNumberLabel: S.current.cardsCopyNumber,
      copyIbanLabel: S.current.cardsCopyIban,
      onMorePressed: () => onMorePressed?.call(card),
      onVisibilityChanged: onVisibilityChanged,
      onCopyCardNumber: () => onCopyNumber != null
          ? onCopyNumber!(card.number)
          : Clipboard.setData(ClipboardData(text: card.number)),
      onCopyIban: () => onCopyIban != null
          ? onCopyIban!(card.iban)
          : Clipboard.setData(ClipboardData(text: card.iban)),
    );
  }
}
