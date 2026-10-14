import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/validators/validators.dart';

void main() {
  test('mobile-number format accepts normalized Iranian numbers only', () {
    expect(PhoneNumberValidator.isValid('09121234567'), isTrue);
    for (final value in [
      '',
      '0912123456',
      '091212345678',
      '02121234567',
      '+989121234567',
      '09abcdefghi',
      '۰۹۱۲۱۲۳۴۵۶۷',
      '09121234567 ',
    ]) {
      expect(PhoneNumberValidator.isValid(value), isFalse, reason: value);
    }
  });
  test(
    'national-code checksum covers remainder zero, one and greater than one',
    () {
      for (final value in ['1000000060', '1234567891', '0081234562']) {
        expect(NationalCodeValidator.isValid(value), isTrue, reason: value);
      }
      for (final value in [
        '',
        '123456789',
        '12345678912',
        '1234567892',
        '0081234563',
        '0000000000',
        '1111111111',
        'abcdefghij',
        '۰۰۸۱۲۳۴۵۶۲',
        '0081234562 ',
      ]) {
        expect(NationalCodeValidator.isValid(value), isFalse, reason: value);
      }
    },
  );
  test('postal validation is ten-digit format, retaining leading zeroes', () {
    for (final value in ['1234567890', '0123456789']) {
      expect(PostalCodeValidator.isValid(value), isTrue);
    }
    for (final value in [
      '',
      '123456789',
      '12345678901',
      '12345abcde',
      '۱۲۳۴۵۶۷۸۹۰',
      '1234567890 ',
    ]) {
      expect(PostalCodeValidator.isValid(value), isFalse, reason: value);
    }
  });
  test('card validation checks length, digits and Luhn', () {
    for (final value in ['4111111111111111', '5555555555554444']) {
      expect(CardValidator.isValid(value), isTrue);
    }
    for (final value in [
      '',
      '411111111111111',
      '41111111111111111',
      '4111111111111112',
      '4111-1111-1111-1111',
      '411111111111111x',
      '۴۱۱۱۱۱۱۱۱۱۱۱۱۱۱۱',
    ]) {
      expect(CardValidator.isValid(value), isFalse, reason: value);
    }
  });
  test('Iranian IBAN checks format and mod-97 without integer overflow', () {
    const valid = 'IR062960000000100324200001';
    expect(IbanValidator.isValid(valid), isTrue);
    for (final value in [
      '',
      'IR072960000000100324200001',
      'IR06296000000010032420000',
      'IR0629600000001003242000011',
      'ir062960000000100324200001',
      'IRAB2960000000100324200001',
      'GB82WEST12345698765432',
    ]) {
      expect(IbanValidator.isValid(value), isFalse, reason: value);
    }
  });
  test('OTP and captcha codes require the requested positive length and Latin digits', () {
    expect(CodeValidator.isValid('0123', length: 4), isTrue);
    expect(CodeValidator.isValid('123456', length: 6), isTrue);
    expect(CodeValidator.isValid('', length: 0), isFalse);
    expect(CodeValidator.isValid('1234', length: -1), isFalse);
    expect(CodeValidator.isValid('123', length: 4), isFalse);
    expect(CodeValidator.isValid('12a4', length: 4), isFalse);
    expect(CodeValidator.isValid('۱۲۳۴', length: 4), isFalse);
  });
}
