import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pishkhan_mobile/core/platform/platform_share.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

Future<void> shareWalletReceipt(BuildContext context, String text) async {
  try {
    await PlatformShare.shareText(text);
  } on PlatformException {
    if (context.mounted) {
      avpSnackBar(
        context: context,
        type: AvpSnackBarType.error,
        message: S.current.chequeShareUnavailable,
      );
    }
  } on MissingPluginException {
    if (context.mounted) {
      avpSnackBar(
        context: context,
        type: AvpSnackBarType.error,
        message: S.current.chequeShareUnavailable,
      );
    }
  }
}
