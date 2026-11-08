import 'package:pishkhan_mobile/core/validators/code_validator.dart';
import 'package:pishkhan_mobile/core/validators/phone_number_validator.dart';

import 'dart:math';

import 'entities/wallet.dart';

abstract final class WalletRules {
  static String normalize(String text) =>
      text.replaceAllMapped(RegExp('[۰-۹٠-٩]'), (m) {
        final c = m[0]!.codeUnitAt(0);
        return String.fromCharCode(48 + c - (c >= 0x06f0 ? 0x06f0 : 0x0660));
      });
  static int? amount(String text) {
    final value = normalize(text).replaceAll(RegExp('[,٬ ]'), '');
    return RegExp(r'^\d{1,15}$').hasMatch(value) ? int.tryParse(value) : null;
  }

  static bool validAmount(int? amount, {int? balance}) =>
      amount != null && amount > 0 && (balance == null || amount <= balance);
  static bool validRecipient(String value) =>
      PhoneNumberValidator.isValid(value) ||
      RegExp(r'^\d{8,20}$').hasMatch(value);
  static bool validOtp(String value, int length) =>
      CodeValidator.isValid(value, length: length);
  static String requestKey() =>
      'wallet-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';
  static int remaining(DateTime expiry) =>
      max(0, (expiry.difference(DateTime.now()).inMilliseconds / 1000).ceil());
  static (DateTime?, DateTime?) dateRange(
    WalletDatePeriod? period,
    DateTime now,
    DateTime? from,
    DateTime? to,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    return switch (period) {
      null => (null, null),
      WalletDatePeriod.today => (today, today),
      WalletDatePeriod.lastWeek => (
        today.subtract(const Duration(days: 6)),
        today,
      ),
      WalletDatePeriod.lastMonth => (
        today.subtract(const Duration(days: 29)),
        today,
      ),
      WalletDatePeriod.lastThreeMonths => (
        today.subtract(const Duration(days: 89)),
        today,
      ),
      WalletDatePeriod.custom => (from, to),
    };
  }
}
