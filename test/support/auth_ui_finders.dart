import 'package:pishkhan_mobile/features/auth/presentation/password_services/widgets/password_request_status.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/widgets/password_flow_footer.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/widgets/auth_services_sheet.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

// Identify controls by their public content and widget type, without adding
// production keys solely for tests. Names keep the existing frame scenarios readable.
Finder authControl(WidgetTester tester, String name) {
  Finder button(String label) => find.byWidgetPredicate(
    (widget) => widget is AppButton && widget.label == label,
  );
  Finder input(Iterable<String> hints) => find.byWidgetPredicate(
    (widget) => widget is AppTextField && hints.contains(widget.hintText),
  );
  Finder select(String hint) => find.byWidgetPredicate(
    (widget) => widget is AppSelect && widget.hintText == hint,
  );
  Finder badge(String asset) => find
      .ancestor(
        of: find.byWidgetPredicate(
          (widget) =>
              widget is SvgPicture &&
              widget.bytesLoader is SvgAssetLoader &&
              (widget.bytesLoader as SvgAssetLoader).assetName == asset,
        ),
        matching: find.byType(SizedBox),
      )
      .first;

  if (name.endsWith('-national-id')) {
    return input([
      S.current.loginNationalIdHint,
      S.current.changeNationalIdHint,
    ]);
  }
  if (name.endsWith('-phone')) {
    return input([S.current.loginPhoneHint, S.current.changePhoneHint]);
  }
  if (name.endsWith('-captcha')) return input([S.current.captchaHint]);
  if (name.endsWith('-otp')) return input([S.current.otpHint]);
  if (name.startsWith('password_option_')) {
    final label = switch (name.substring('password_option_'.length)) {
      'PasswordCardKind.resalat' => S.current.cardFeatureResalat,
      'second' => S.current.passwordSecond,
      'PasswordOperation.changePassword' => S.current.passwordChange,
      'PasswordOperation.forgotPassword' => S.current.passwordForgot,
      'password-card-1' => '5041721456783407',
      final value => throw ArgumentError('Unknown password option: $value'),
    };
    // The underlying select can display the same label behind the open sheet.
    return find.text(label).last;
  }
  return switch (name) {
    'auth_menu_button' => find.byWidgetPredicate(
      (widget) =>
          widget is AppButton &&
          widget.semanticLabel == S.current.servicesMenuLabel,
    ),
    'auth_captcha_image' =>
      find
          .ancestor(
            of: find.byWidgetPredicate(
              (widget) =>
                  widget is Image &&
                  widget.image is AssetImage &&
                  (widget.image as AssetImage).assetName == AuthAssets.captcha,
            ),
            matching: find.byType(Container),
          )
          .first,
    'auth_services_sheet' => find.byType(AuthServicesSheet),
    'change_phone_button' =>
      find
          .ancestor(
            of: find.text(S.current.changePhoneAction),
            matching: find.byType(InkWell),
          )
          .first,
    'request_otp_button' => button(S.current.requestOtp),
    'submit_otp_button' => button(S.current.enterDashboard),
    'otp_timer_button' => find.byWidgetPredicate(
      (widget) =>
          widget is AppButton &&
          (widget.label == S.current.resendOtp ||
              (widget.label?.startsWith('00:') ?? false)),
    ),
    'password_card_kind' => select(S.current.passwordCardTypeHint),
    'password_card_number' => select(S.current.passwordCardNumberHint),
    'password_type' => select(S.current.passwordTypeHint),
    'password_operation' => select(S.current.passwordOperationHint),
    'password_current' => input([S.current.passwordCurrentHint]),
    'password_value' => input([
      S.current.passwordValueHint,
      S.current.passwordNewHint,
    ]),
    'password_confirmation' => input([
      S.current.passwordConfirmationHint,
      S.current.passwordNewConfirmationHint,
    ]),
    'password_serial' => input([S.current.passwordSerialHint]),
    'password_next' => find.byWidgetPredicate(
      (widget) =>
          widget is AppButton &&
          [
            S.current.issuanceNext,
            S.current.passwordStartKyc,
            S.current.passwordSubmit,
            S.current.passwordChangeSubmit,
          ].contains(widget.label),
    ),
    'password_retry' => button(S.current.dashboardRetry),
    'password_terms' => find.byWidgetPredicate(
      (widget) => widget is AppCheckbox && widget.label == null,
    ),
    'password_confirm_mock' => find.byWidgetPredicate(
      (widget) =>
          widget is AppCheckbox &&
          widget.label == S.current.passwordConfirmMock,
    ),
    'password_tracking' => find.byType(SelectableText),
    'password_result_badge' => badge(AppAssets.passwordApproved),
    'password_status_badge' => badge(AppAssets.passwordStatusSuccess),
    'password_status_page' => find.byType(PasswordStatusContent),
    'password_record_dismiss' => find.descendant(
      of: find.byType(PasswordRecordSheet),
      matching: button(S.current.passwordUnderstood),
    ),
    'password_status_dismiss' => find.descendant(
      of: find.byType(PasswordFlowFooter),
      matching: button(S.current.passwordUnderstood),
    ),
    _ => throw ArgumentError('Unknown auth control: $name'),
  };
}
