import 'package:pishkhan_mobile/core/result/failure.dart';

/// Prepared request-error text; no State publication or Flutter dependency.
String getRequestErrorMessage(Failure failure) {
  switch (failure.code) {
    case 'profile.otp.invalid':
      return 'رمز تأیید صحیح نیست.';
    case 'profile.otp.expired':
      return 'اعتبار رمز تأیید تمام شده است. دوباره درخواست دهید.';
    case 'profile.wallet.insufficient':
    case 'deposit-restriction.wallet-insufficient':
      return 'موجودی کیف پول کافی نیست.';
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
