import 'package:pishkhan_mobile/core/result/failure.dart';

/// Prepared request-error text; no State publication or Flutter dependency.
String getRequestErrorMessage(Failure failure) {
  switch (failure.code) {
    case 'platform.share.unavailable':
      return 'اشتراک‌گذاری در این دستگاه در دسترس نیست.';
    case 'platform.browser.unavailable':
      return 'باز کردن مرورگر در این دستگاه امکان‌پذیر نیست.';
    case 'wallet.recipient.not-found':
      return 'کیف مقصد یافت نشد.';
    case 'wallet.recipient.self':
      return 'کیف مقصد باید با کیف مبدأ متفاوت باشد.';
    case 'wallet.amount.invalid':
      return 'مبلغ تراکنش معتبر نیست.';
    case 'wallet.deposit.invalid':
      return 'سپرده انتخاب‌شده برای اتصال به کیف پول معتبر نیست.';

    case 'wallet.otp.invalid':
    case 'profile.otp.invalid':
      return 'رمز تأیید صحیح نیست.';
    case 'wallet.otp.expired':
    case 'profile.otp.expired':
      return 'اعتبار رمز تأیید تمام شده است. دوباره درخواست دهید.';
    case 'wallet.balance.insufficient':
    case 'profile.wallet.insufficient':
    case 'deposit-restriction.wallet-insufficient':
    case 'card-restriction.wallet-insufficient':
      return 'موجودی کیف پول کافی نیست.';
    case 'card-restriction.ineligible':
      return 'کارت انتخاب‌شده برای این عملیات در دسترس نیست. اطلاعات را به‌روزرسانی کنید.';
    case 'card-restriction.quote-expired':
      return 'اطلاعات یا هزینه درخواست تغییر کرده است. اطلاعات را به‌روزرسانی کنید.';
    case 'cheque.not-found':
      return 'چک موردنظر یافت نشد.';
    case 'transfer.file.invalid':
      return 'فایل انتخاب‌شده معتبر نیست. دوباره انتخاب کنید.';
    case 'profile.address.required':
    case 'chequebook.address.last-or-unavailable':
      return 'حداقل یک آدرس باید باقی بماند.';
    case 'profile.occupation.required':
      return 'حداقل یک شغل باید باقی بماند.';
    case 'proxy.already-registered':
      return 'این نمایندگی قبلاً ثبت شده است.';
    case 'password.request.ineligible':
      return 'شرایط ثبت این درخواست فراهم نیست.';
    case final code when code.startsWith('network.'):
      return 'ارتباط با سرور برقرار نشد. دوباره تلاش کنید.';
    default:
      return 'درخواست انجام نشد. دوباره تلاش کنید.';
  }
}
