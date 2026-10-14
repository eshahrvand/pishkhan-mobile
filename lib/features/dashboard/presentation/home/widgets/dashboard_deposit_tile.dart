import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_deposit.dart';
import 'package:pishkhan_mobile/shared/widgets/app_deposit_card.dart';

/// Deposit fetching, persistence and service execution are caller-owned.
class DashboardDepositTile extends StatelessWidget {
  const DashboardDepositTile({
    super.key,
    required this.deposit,
    required this.width,
    required this.isSingle,
    required this.height,
    this.onCopyNumber,
    this.onCopyIban,
  });
  final BankDeposit deposit;
  final double width;
  final bool isSingle;
  final double height;
  final ValueChanged<String>? onCopyNumber;
  final ValueChanged<String>? onCopyIban;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: FittedBox(
        child: AppDepositCard(
          key: ValueKey('deposit_card_${deposit.id}'),
          size: isSingle ? AppDepositCardSize.single : AppDepositCardSize.multi,
          cardType: deposit.typeLabel,
          depositNumber: deposit.number,
          iban: deposit.iban,
          openingDate: deposit.openingDate,
          // The neighboring cards in the Figma frame retain their full color.
          isSelected: true,
          onCopyDepositNumber: () => onCopyNumber != null
              ? onCopyNumber!(deposit.number)
              : Clipboard.setData(ClipboardData(text: deposit.number)),
          onCopyIban: () => onCopyIban != null
              ? onCopyIban!(deposit.iban)
              : Clipboard.setData(ClipboardData(text: deposit.iban)),
        ),
      ),
    );
  }
}
