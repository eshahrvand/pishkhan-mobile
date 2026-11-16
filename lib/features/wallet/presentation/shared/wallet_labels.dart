import 'package:avp_ui/avp_ui.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../domain/entities/wallet.dart';

String walletTypeLabel(WalletTransactionType type) => switch (type) {
  WalletTransactionType.charge => S.current.walletCharge,
  WalletTransactionType.withdraw => S.current.walletWithdraw,
  WalletTransactionType.transfer => S.current.walletTransfer,
  WalletTransactionType.shopping => S.current.walletShopping,
};
String walletSuccessTitle(WalletTransactionType type) => switch (type) {
  WalletTransactionType.charge => S.current.walletChargeSuccess,
  WalletTransactionType.withdraw => S.current.walletWithdrawSuccess,
  WalletTransactionType.transfer => S.current.walletTransferSuccess,
  WalletTransactionType.shopping => S.current.walletShopping,
};
String walletSuccessDescription(WalletTransactionType type) => switch (type) {
  WalletTransactionType.charge => S.current.walletChargeComplete,
  WalletTransactionType.withdraw => S.current.walletWithdrawComplete,
  WalletTransactionType.transfer => S.current.walletTransferComplete,
  WalletTransactionType.shopping => S.current.walletShopping,
};
String walletPeriodLabel(WalletDatePeriod period) => switch (period) {
  WalletDatePeriod.today => S.current.walletToday,
  WalletDatePeriod.lastWeek => S.current.walletLastWeek,
  WalletDatePeriod.lastMonth => S.current.walletLastMonth,
  WalletDatePeriod.lastThreeMonths => S.current.walletLastThreeMonths,
  WalletDatePeriod.custom => S.current.walletCustomDate,
};
String walletDateLabel(DateTime date) =>
    '${JalaliDateFormatter.format(date)} - ${CurrencyFormatter.toPersianDigits('${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}')}';
String walletCountdownLabel(int seconds) => CurrencyFormatter.toPersianDigits(
  '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}',
);
String walletReceiptShareText(WalletReceipt receipt) =>
    '${walletTypeLabel(receipt.type)}\n${S.current.walletAmount}: ${CurrencyFormatter.format(receipt.amountRial)} ${S.current.rialCurrency}\n${S.current.walletTransactionDate}: ${walletDateLabel(receipt.createdAt)}\n${S.current.walletReceiptSource}: ${receipt.source}\n${S.current.walletReceiptDestination}: ${receipt.destination}\n${S.current.walletTrackingId}: ${receipt.trackingId}\n${S.current.walletBalanceAfter}: ${CurrencyFormatter.format(receipt.balanceRial)} ${S.current.rialCurrency}';
