import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_sheet.dart';

Future<void> showWalletTerms(BuildContext context, String text) =>
    showAppServiceSheet<void>(context, WalletTermsSheet(text: text));

class WalletTermsSheet extends StatelessWidget {
  const WalletTermsSheet({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBottomSheetHeader(
          title: S.current.walletTerms,
          showRightIcon: false,
          onLeftAction: () => Navigator.of(context).pop(),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(text, style: AppTypography.bodyMedium),
        ),
      ],
    );
  }
}
